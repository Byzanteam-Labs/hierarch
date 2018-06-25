use Mix.Config

# Configure your database
config :hierarch, ecto_repos: [Dummy.Repo]

config :hierarch, Dummy.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USER") || "postgres",
  password: System.get_env("POSTGRES_PASSWORD") || "posgtres",
  database: "hierarch_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
