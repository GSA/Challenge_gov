defmodule ChallengeGov.Repo.Migrations.AddAutoPublishDateToChallenge do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :auto_publish_date, :utc_datetime
    end
  end
end
