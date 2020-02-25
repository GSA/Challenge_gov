use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :challenge_gov, Web.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :challenge_gov, ChallengeGov.Repo,
  username: "postgres",
  password: "postgres",
  database: "challenge_gov_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :challenge_gov, ChallengeGov.Mailer,
  from: "idea-portal@example.com",
  adapter: Bamboo.TestAdapter

config :bcrypt_elixir, :log_rounds, 4

config :challenge_gov, :recaptcha, module: ChallengeGov.Recaptcha.Mock

config :stein_storage, backend: :test

if File.exists?("config/test.extra.exs") do
  import_config("test.extra.exs")
end

if File.exists?("config/test.local.exs") do
  import_config("test.local.exs")
end
