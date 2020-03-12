defmodule ChallengeGov.Repo.Migrations.AddDeletedAtToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:deleted_at, :utc_datetime)
    end
  end
end
