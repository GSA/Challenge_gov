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
  secret_key_base: "gQktXSHmqFhwR5a0rTW/SGWrvpUYZ1FaRELQsGoctIOiSlQ9qIoe2KYO1i8wDVR5",
  render_errors: [view: Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ChallengeGov.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
config :bamboo, :json_library, Jason

config :challenge_gov, :recaptcha, module: ChallengeGov.Recaptcha.Implementation

config :stein_storage,
  backend: :file,
  file_backend_folder: "uploads/"

# Sets the session timeout interval in minutes
config :challenge_gov, :session_timeout_in_minutes, 15

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
