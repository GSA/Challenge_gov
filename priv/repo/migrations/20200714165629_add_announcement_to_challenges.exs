defmodule ChallengeGov.Repo.Migrations.AddAnnouncementToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :announcement, :text
      add :announcement_datetime, :utc_datetime
    end
  end
end
