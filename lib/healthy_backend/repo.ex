defmodule HealthyBackend.Repo do
  use Ecto.Repo,
    otp_app: :healthy_backend,
    adapter: Ecto.Adapters.Postgres
end
