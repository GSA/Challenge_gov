defmodule ChallengeGov.Repo.Migrations.CreateDapReports do
  use Ecto.Migration

  def change do
    create table(:dap_reports) do
      add(:filename, :string, null: false)
      add(:key, :uuid, null: false)
      add(:extension, :string, null: false)
      add(:deleted_at, :utc_datetime)
      timestamps()
    end
  end
end
