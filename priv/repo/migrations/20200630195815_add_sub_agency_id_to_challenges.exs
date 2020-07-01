defmodule ChallengeGov.Repo.Migrations.AddSubAgencyIdToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :sub_agency_id, references(:agencies)
    end
  end
end
