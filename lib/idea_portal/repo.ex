defmodule IdeaPortal.Repo do
  use Ecto.Repo,
    otp_app: :idea_portal,
    adapter: Ecto.Adapters.Postgres
end
