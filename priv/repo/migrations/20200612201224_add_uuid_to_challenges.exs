defmodule ChallengeGov.Repo.Migrations.AddUuidToChallenges do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")

    alter table(:challenges) do
      add(:uuid, :uuid, default: fragment("uuid_generate_v4()"))
    end
  end

  def down do
    alter table(:challenges) do
      remove(:uuid, :uuid, default: fragment("uuid_generate_v4()"))
    end
  end
end
