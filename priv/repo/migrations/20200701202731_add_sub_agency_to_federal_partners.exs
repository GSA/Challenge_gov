defmodule ChallengeGov.Repo.Migrations.AddSubAgencyToFederalPartners do
  use Ecto.Migration

  def change do
    alter table(:federal_partners) do
      add :sub_agency_id, references(:agencies)
    end
  end
end
