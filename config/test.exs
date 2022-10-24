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
  from: "challenge_gov@example.com",
  adapter: Bamboo.TestAdapter

config :wallaby,
  otp_app: :challenge_gov,
  js_logger: nil,
  max_wait_time: 8_000,
  screenshot_on_failure: true

config :waffle,
  storage: Waffle.Storage.Local,
  storage_dir_prefix: Path.expand("../priv/waffle/uploads", __DIR__)

config :challenge_gov, :sql_sandbox, true

config :challenge_gov, Web.Endpoint, server: true

config :bcrypt_elixir, :log_rounds, 4

config :challenge_gov, :recaptcha, module: ChallengeGov.Recaptcha.Mock
config :challenge_gov, :gov_delivery, module: ChallengeGov.GovDelivery.Mock

config :challenge_gov, ChallengeGov.GovDelivery,
  username: "user@domain.com",
  password: "password",
  url: "https://stage-api.govdelivery.com",
  account_code: "USGSATTS",
  challenge_category_code: "CHAL_ALL_TEST",
  challenge_topic_prefix_code: "CHAL_TEST",
  news_topic_code: "CHAL_NEWS_TEST",
  public_subscribe_base:
    "https://stage-public.govdelivery.com/accounts/USGSATTS/subscriber/new?topic_id="

config :stein_storage, backend: :test

config :challenge_gov, Oban, crontab: false, queues: false, plugins: false

config :challenge_gov, :public_root_url, "http://localhost:4001"

config :wallaby, driver: Wallaby.Chrome

if File.exists?("config/test.local.exs") do
  import_config("test.local.exs")
end
