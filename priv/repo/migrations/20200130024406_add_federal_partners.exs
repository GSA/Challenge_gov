defmodule ChallengeGov.Repo.Migrations.AddFederalPartners do
  use Ecto.Migration

  def change do
    create table(:federal_partners) do
      add(:agency_id, references(:agencies), null: false)
      add(:challenge_id, references(:challenges), null: false)
    end
  end
end
