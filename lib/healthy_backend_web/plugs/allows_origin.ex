defmodule Restrict.AllowsOrigin do
  @moduledoc """
  Allows affected ressources to be open in iframe.
  """

  alias Plug.Conn

  def init(opts \\ %{}), do: Enum.into(opts, %{})

  def call(conn, _opts) do
    whitelist =
      (Application.get_env(:k_web, KWebWeb.Endpoint)[:allow_check_origin] || "")
      |> String.split(",")

    origin = get_req_header(conn, "origin") |> List.first()
    IO.inspect(origin, label: ">> Origin received")

    if origin in whitelist do
      conn
    else
      IO.puts(">> Blocked Origin: #{inspect(origin)}")

      conn
      |> send_resp(403, "Forbidden origin")
      |> halt()
    end
  end
end
