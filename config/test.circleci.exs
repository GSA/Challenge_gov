use Mix.Config

config :challenge_gov, Web.Endpoint, secret_key_base: System.get_env("SECRET_KEY_BASE")

config :challenge_gov, ChallengeGov.Repo,
  username: "postgres",
  password: "postgres",
  database: "challenge_gov_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
