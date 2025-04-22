import Config


if config_env() == :prod do
  host = System.get_env("HOST") || "localhost"
  http_port = String.to_integer(System.get_env("PORT") || "8088")

  secret_key_base = System.get_env("SECRET_KEY_BASE") || raise ("No SECRET_KEY_BASE config.")
  api_key_base = System.get_env("API_KEY_GEMINI") || raise ("No API_KEY_GEMINI config.")
  url_gemini = System.get_env("URL_GEMINI") || raise ("No URL_GEMINI config.")
  fetch_data_interval = System.get_env("FETCH_DATA_INTERVAL")

  config :healthy_backend, HealthyBackend.Repo,
    username: System.get_env("DB_USERNAME") || raise("No DB_USERNAME config."),
    password: System.get_env("DB_PASSWORD") || raise("No DB_PASSWORD config."),
    hostname: System.get_env("DB_HOST") || raise("No DB_HOST config."),
    database: System.get_env("DB") || raise("No DB config."),
    port: System.get_env("DB_PORT") || raise("No DB_PORT config."),
    pool_size:
      String.to_integer(
        System.get_env("DB_POOL_SIZE") || raise("No DB_POOL_SIZE config.")
      ),
    stacktrace: (System.get_env("DB_STACKTRACE") || "false") in ["true"],
    show_sensitive_data_on_connection_error: false,
    log: false

  config :healthy_backend, HealthyBackendWeb.Endpoint,
    server: true,
    check_origin: true,
    url: [host: host, port: 443, scheme: "https"],
    http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}, port: http_port],
    secret_key_base: secret_key_base

  config :healthy_backend,
    env: config_env(),
    API_KEY_GEMINI: api_key_base,
    URL_GEMINI: url_gemini,
    FETCH_DATA_INTERVAL: fetch_data_interval
end
