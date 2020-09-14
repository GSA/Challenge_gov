defmodule ChallengeGov.Repo.Migrations.AddArchiveDateToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :archive_date, :utc_datetime
    end
  end
end
