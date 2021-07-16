defmodule ChallengeGov.Repo.Migrations.AddStartEndDatesToSiteContent do
  use Ecto.Migration

  def up do
    alter table(:site_content) do
      add(:start_date, :utc_datetime)
      add(:end_date, :utc_datetime)
    end
  end

  def down do
    alter table(:site_content) do
      remove(:start_date, :utc_datetime)
      remove(:end_date, :utc_datetime)
    end
  end
end
