defmodule HealthyBackend.DailyGeminiAPI do
  use GenServer
  alias HealthyBackend.GeminiAPI
  alias HealthyBackend.Diseases



  # Client API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def stop() do
    GenServer.stop(__MODULE__)
  end

  # Server Callbacks
  def init(state) do
    schedule_work()  # Start the periodic task
    {:ok, state}
  end

  def handle_info(:work, state) do
    create_posts()  # Call GeminiAPI and create 3 posts
    schedule_work()  # Schedule the next execution in 5 minutes
    {:noreply, state}
  end

  # Periodic task - schedule to run every 5 minutes
  defp schedule_work do
    timer = Application.get_env(:healthy_backend, :FETCH_DATA_INTERVAL)
    Process.send_after(self(), :work, timer * 60 * 1000)  # 5 minutes in milliseconds
  end

  defp create_posts do
    case GeminiAPI.call_api("Hãy liệt kê 3 câu hỏi phổ biến về sức khỏe hôm nay") do
      {:ok, raw_questions} when is_binary(raw_questions) ->
        IO.puts("✅ Raw questions received: #{raw_questions}")
        raw_questions
        |> parse_questions()
        |> remove_similar_questions()
        |> Enum.take(3)
        |> Enum.each(fn question ->
          if !question_exists?(question) do
            question = name_format(question)
            case GeminiAPI.call_api(question) do
              {:ok, answer} ->
                if String.starts_with?(answer, "[\n{\n\"") do
                  case Diseases.create_diseases(%{
                    title: batch_string(question),
                    name: question,
                    data: answer
                  }) do
                    {:ok, disease} ->
                      disease

                    {:error, changeset} ->
                      IO.puts("❌ DB error: #{inspect(changeset)}")
                  end
                else
                  IO.puts("⚠️ Bỏ qua vì format không đúng")
                end

              {:error, reason} ->
                IO.puts("❌ GeminiAPI answer error: #{reason}")
            end

          else
            IO.puts("❌ Question already exists in DB: #{question}")
          end
        end)

      {:ok, _} ->
        IO.puts("❌ Unexpected structure, expected a string but got a different format.")

      {:error, {:api_error, status_code, error_body}} ->
        error_message = "API error: #{status_code} - #{error_body}"
        IO.puts("❌ #{error_message}")

      {:error, reason} ->
        IO.puts("❌ GeminiAPI question fetch error: #{inspect(reason)}")
    end
  end

  defp question_exists?(question) do
    # Kiểm tra câu hỏi đã có trong DB hay chưa
    case Diseases.get_diseases_names() do
      names when is_list(names) -> Enum.member?(names, question)
      _ -> false  # Nếu không tìm thấy hoặc không có dữ liệu
    end
  end

  defp parse_questions(text) do
    text
    |> String.split("\n")  # Tách chuỗi thành từng dòng
    |> Enum.filter(fn line ->
      String.trim(line) != "" and String.contains?(line, "?")
    end)
    |> Enum.map(fn line ->
      line
      |> String.replace(~r/^\s*Câu hỏi \d+: /, "")  # Loại bỏ "Câu hỏi X:" ở đầu dòng
      |> String.replace(~r/\*\*/, "")               # Loại bỏ dấu sao ** nếu có
      |> String.trim()                             # Loại bỏ khoảng trắng thừa
    end)
    |> Enum.uniq()  # Loại bỏ các câu hỏi trùng lặp
    |> Enum.filter(fn item ->
        String.trim(item)
        |> String.downcase()
        |> String.starts_with?("câu hỏi")
      end)
  end


  defp normalize_question(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^\p{L}\p{N}\s]/u, "") # Bỏ dấu câu
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end

  defp remove_similar_questions(questions) do
    Enum.reduce(questions, [], fn q, acc ->
      norm_q = normalize_question(q)
      if Enum.any?(acc, fn x -> String.jaro_distance(normalize_question(x), norm_q) > 0.9 end) do
        acc
      else
        [q | acc]
      end
    end)
    |> Enum.reverse()
  end

  def batch_string(string) do
    (string || "")
    |> String.downcase()
    |> String.normalize(:nfd)
    |> String.replace("đ", "d")
    |> String.replace(~r/^\s*cau-hoi-\d+-/, "")  # Loại bỏ "cau-hoi-X-" (cả chữ và số)
    |> String.replace(~r/\p{Mn}/u, "")           # Bỏ dấu tiếng Việt
    |> String.replace(~r/[^a-z0-9\s-]/u, "")     # Bỏ dấu câu và ký tự đặc biệt (bao gồm dấu gạch ngang)
    |> String.replace(~r/\s+/, "-")              # Thay thế khoảng trắng bằng dấu -
    |> String.trim()                            # Loại bỏ khoảng trắng thừa cuối chuỗi
  end

  def name_format(string) do
    (string || "")
    |> String.replace(~r/^\s*Câu hỏi \d+: /, "")  # Loại bỏ Câu hỏi X: với khoảng trắng phía trước
    |> String.trim()  # Loại bỏ khoảng trắng dư thừa ở đầu và cuối chuỗi
  end

end
