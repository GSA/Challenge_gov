use Mix.Config

config :challenge_gov, ChallengeGov.Repo,
  username: "challenge_gov",
  password: "password",
  database: "challenge_gov_test",
  hostname: "localhost",
  port: 5433,
  pool: Ecto.Adapters.SQL.Sandbox
