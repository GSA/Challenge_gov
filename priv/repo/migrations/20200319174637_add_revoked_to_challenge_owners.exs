defmodule ChallengeGov.Repo.Migrations.AddRevokedToChallengeOwners do
  use Ecto.Migration

  def change do
    alter table(:challenge_owners) do
      add(:revoked_at, :utc_datetime)
    end
  end
end
