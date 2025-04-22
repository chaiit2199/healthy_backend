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
      conn = conn |> IO.inspect(label: "connconnconnconn")
      IO.inspect(Conn.get_req_header(conn, "referer"), label: "get_req_headerget_req_headerget_req_headerget_req_header")

    with [host_request] <- Conn.get_req_header(conn, "referer"),
         {:ok, %URI{host: host}} <- URI.new(host_request),
      true <- Enum.any?(whitelist, &Regex.match?(~r"^([A-Za-z0-9-]+.)?(#{&1})$", host)) do
      Conn.put_resp_header(conn, "x-frame-options", "ALLOWALL")
    else
      _ ->
        Conn.put_resp_header(conn, "x-frame-options", "DENY")
    end
  end
end
