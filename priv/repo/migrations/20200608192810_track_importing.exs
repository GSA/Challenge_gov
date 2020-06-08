defmodule ChallengeGov.Repo.Migrations.TrackImporting do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:imported, :boolean, default: false, null: false)
    end

    alter table(:agencies) do
      add(:created_on_import, :boolean, default: false, null: false)
    end
  end
end
