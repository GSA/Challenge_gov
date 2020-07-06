defmodule ChallengeGov.Repo.Migrations.FixChallengeUuidGeneration do
  use Ecto.Migration

  def up do
    alter table(:challenges) do
      remove(:uuid, :uuid)
      add(:uuid, :uuid)
    end
  end

  def down do
    alter table(:challenges) do
      remove(:uuid, :uuid)
      add(:uuid, :uuid)
    end
  end
end
