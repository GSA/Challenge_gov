# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :challenge_gov,
  namespace: Web,
  ecto_repos: [ChallengeGov.Repo]

# Configures the endpoint
config :challenge_gov, Web.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: Web.ErrorView, accepts: ~w(html json)],
  pubsub_server: ChallengeGov.PubSub,
  live_view: [signing_salt: "SECRET_SALT"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger_json, :backend, metadata: :all

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
config :bamboo, :json_library, Jason

config :challenge_gov, :recaptcha, module: ChallengeGov.Recaptcha.Implementation
config :challenge_gov, :gov_delivery, module: ChallengeGov.GovDelivery.Implementation

config :stein_storage,
  backend: :file,
  file_backend_folder: "uploads/"

config :challenge_gov,
  session_timeout_in_minutes: 15,
  account_deactivation_in_days: 90,
  account_deactivation_warning_one_in_days: 10,
  account_deactivation_warning_two_in_days: 5,
  account_decertify_in_days: 365,
  log_retention_in_days: 180,
  challenge_manager_assumed_tlds: [".mil"]

config :challenge_gov, Oban,
  repo: ChallengeGov.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10]

jobs = [
  {"0 5 * * *", {ChallengeGov.Accounts, :check_all_last_actives, []}},
  {"0 5 * * *", {ChallengeGov.SecurityLogs, :check_expired_records, []}},
  {"* * * * *", {ChallengeGov.SecurityLogs, :check_for_timed_out_sessions, []}},
  {"0 0 * * *", {ChallengeGov.CertificationLogs, :check_for_expired_certifications, []}},
  {"0 0 * * *", {ChallengeGov.CertificationLogs, :email_upcoming_expired_certifications, []}},
  {"* * * * *", {ChallengeGov.Challenges, :check_for_auto_publish, []}},
  {"* * * * *", {ChallengeGov.GovDelivery, :check_topics, []}},
  {"0 * * * *", {ChallengeGov.GovDelivery, :update_subscriber_counts, []}},
  {"* * * * *", {ChallengeGov.Challenges, :set_sub_statuses, []}}
]

# Figure out if we are the first CF instance running
cf_instance = System.get_env("CF_INSTANCE_INDEX")

case cf_instance do
  nil ->
    config :challenge_gov, ChallengeGov.Scheduler, jobs: jobs

  "0" ->
    config :challenge_gov, ChallengeGov.Scheduler, jobs: jobs

  _ ->
    config :challenge_gov, ChallengeGov.Scheduler, jobs: []
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
