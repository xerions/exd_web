use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :exd_web, ExdWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :exd_web, ExdWeb.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "exd_web_test",
  size: 1 # Use a single connection for transactional tests
