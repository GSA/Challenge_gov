defmodule ChallengeGov.Repo do
  use Ecto.Repo,
    otp_app: :challenge_gov,
    adapter: Ecto.Adapters.Postgres
end
