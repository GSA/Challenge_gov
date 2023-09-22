defmodule ChallengeGov.Repo.Migrations.AddRecertificationField do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :recertification_expired_at, :utc_datetime
    end
  end
end
