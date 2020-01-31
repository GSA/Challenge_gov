defmodule ChallengeGov.Repo.Migrations.AddAgencyToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :agency_id, references(:agencies)
    end
  end
end
