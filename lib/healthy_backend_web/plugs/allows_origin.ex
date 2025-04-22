defmodule Restrict.AllowsOrigin do
  @moduledoc """
  Allows affected ressources to be open in iframe.
  """

  alias Plug.Conn
  # import Plug.Conn

  def init(opts \\ %{}), do: Enum.into(opts, %{})

  def call(conn, _opts) do
    whitelist =
      (Application.get_env(:healthy_backend, HealthyBackendWeb.Endpoint)[:allow_check_origin] || "")
      |> String.split(",")

    conn = conn |> IO.inspect(label: ">> connconnconnconn")

    # with [host_request] <- Conn.get_req_header(conn, "origin"),
    #      {:ok, %URI{host: host}} <- URI.new(host_request),
    #   true <- Enum.any?(whitelist, &Regex.match?(~r"^([A-Za-z0-9-]+.)?(#{&1})$", host)) do
    #     conn
    # else
    #   _ ->
    #     conn
    #     |> halt()
    # end
  end
end
