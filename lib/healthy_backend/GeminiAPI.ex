defmodule HealthyBackend.GeminiAPI do
  require Logger

  def call_api(prompt) do
    # Kiểm tra và chuyển đổi chuỗi thành danh sách câu hỏi nếu cần
    prompt = if is_bitstring(prompt) do
      prompt
      |> String.split("\n")  # Tách chuỗi thành danh sách nếu prompt là chuỗi
      |> Enum.filter(fn line -> String.trim(line) != "" end)  # Loại bỏ các dòng trống
    else
      prompt  # Nếu prompt đã là danh sách, giữ nguyên
    end

    # Loại bỏ phần "Câu hỏi X:" trong các câu hỏi
    prompt_without_questions = Enum.map(prompt, fn question ->
      String.replace(question, ~r/^Câu hỏi \d+: /, "")  # Loại bỏ "Câu hỏi X: "
    end)

    # Loại bỏ các câu hỏi trùng lặp
    prompt_without_questions = Enum.uniq(prompt_without_questions)

    prompt_with_format = """
     [
        {
          Giới thiệu: (Mở đầu bằng cách nhấn mạnh tầm quan trọng của chủ đề, lý do người đọc nên quan tâm. Hãy gợi sự đồng cảm và kết nối cảm xúc)
        }
        {
          Mô tả: (Giải thích ngắn gọn, dễ hiểu về vấn đề. Đưa ra ví dụ cụ thể trong đời sống hằng ngày để người đọc dễ hình dung)
        },
        {
          Dấu hiệu nhận biết: (Nêu rõ những biểu hiện phổ biến để người đọc có thể tự đánh giá tình trạng của bản thân)
        },
        {
          Cách cải thiện: (Đưa ra các phương pháp thực tế, dễ thực hiện, phù hợp với lối sống hằng ngày. Tránh lý thuyết suông. Mục tiêu là giúp người đọc có thể áp dụng ngay)
        },
        {
          Lầm tưởng phổ biến: (Nêu 1-2 hiểu lầm hay gặp và giải thích rõ)
        },
        {
          Kết luận và lời khuyên: (Tổng kết nội dung một cách nhẹ nhàng và truyền cảm hứng. Đưa ra lời khuyên chân thành, khuyến khích người đọc chăm sóc bản thân và chủ động thay đổi tích cực.)
        }
      ]

    #{Enum.join(prompt_without_questions, "\n")}
    """
    api_key = Application.get_env(:healthy_backend, :API_KEY_GEMINI)
    url_gemini = Application.get_env(:healthy_backend, :URL_GEMINI)

    url = "#{url_gemini}#{api_key}"
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(%{
      "contents" => [
        %{
          "parts" => [
            %{
              "text" => prompt_with_format
            }
          ]
        }
      ]
    })

    options = [timeout: 15_000, recv_timeout: 15_000]

    case HTTPoison.post(url, body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->

        case Jason.decode(response_body) do
          {:ok, %{"candidates" => [%{"content" => %{"parts" => [%{"text" => response_text} | _]}}]}} ->
            {:ok, parse_response_text(response_text)}  # Gọi hàm parse_response_text

          {:ok, _decoded_response} ->
            Logger.error("Unexpected JSON structure")
            {:error, :unexpected_structure}

          {:error, %Jason.DecodeError{}} ->
            Logger.error("Response body is not valid JSON: #{response_body}")
            {:error, :invalid_json}

          {:error, error} ->
            Logger.error("JSON Decode Error: #{inspect(error)}")
            {:error, :json_decode_error}
        end
      {:ok, %HTTPoison.Response{status_code: status_code, body: error_body}} ->
        Logger.error("API: #{status_code} - #{error_body}")
        {:error, {:api_error, status_code, error_body}}
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison: #{inspect(reason)}")
        {:error, {:httpoison_error, reason}}
    end
  end

  # Định nghĩa hàm parse_response_text để xử lý chuỗi response_text trả về
  defp parse_response_text(response_text) do
    response_text
    |> String.replace("```json", "")
    |> String.replace("```", "")
    |> String.split("\n")
    |> Enum.filter(fn line ->
      String.trim(line) != ""  # Loại bỏ các dòng trống
    end)
    |> Enum.map(fn line ->
      line
      |> String.replace(~r/^Câu hỏi \d+:\s*/, "")  # Loại bỏ "Câu hỏi X:" với khoảng trắng sau dấu ":"
      |> String.trim()  # Loại bỏ khoảng trắng thừa
    end)
    |> Enum.join("\n")  # Kết hợp lại các dòng đã xử lý
  end

end
