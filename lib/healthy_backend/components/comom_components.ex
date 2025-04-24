defmodule CommonComponents do
  def batch_string(string) do
    (string || "")
    |> String.downcase()
    |> String.normalize(:nfd)
    |> String.replace("đ", "d")
    |> String.replace(~r/\p{Mn}/u, "")       # Bỏ dấu tiếng Việt
    |> String.replace(~r/[^a-z0-9\s]/u, "")  # Bỏ dấu câu và ký tự đặc biệt
    |> String.replace(~r/\s+/, "-")
  end
end
