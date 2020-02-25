use Mix.Config

config :challenge_gov, ChallengeGov.Repo,
  username: "postgres",
  password: "postgres",
  database: "challenge_gov_test",
  hostname: "database",
  pool: Ecto.Adapters.SQL.Sandbox
