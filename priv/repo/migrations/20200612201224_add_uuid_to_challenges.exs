defmodule ChallengeGov.Repo.Migrations.AddUuidToChallenges do
  use Ecto.Migration

  def up do
    alter table(:challenges) do
      add(:uuid, :uuid, default: Ecto.UUID.generate())
    end
  end

  def down do
    alter table(:challenges) do
      remove(:uuid, :uuid)
    end
  end
end
