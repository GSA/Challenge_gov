use Mix.Config

config :ex_venture, Data.Repo,
  username: "idea_portal",
  password: "password",
  database: "idea_portal_test",
  hostname: "localhost",
  port: 5433,
  pool: Ecto.Adapters.SQL.Sandbox
