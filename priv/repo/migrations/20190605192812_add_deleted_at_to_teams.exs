defmodule ChallengeGov.Repo.Migrations.AddDeletedAtToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:deleted_at, :utc_datetime)
    end
  end
end
