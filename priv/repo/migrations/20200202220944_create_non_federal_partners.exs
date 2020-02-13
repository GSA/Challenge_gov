defmodule ChallengeGov.Repo.Migrations.CreateNonFederalPartners do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      remove(:non_federal_partners)
    end

    create table(:non_federal_partners) do
      add(:challenge_id, references(:challenges), null: false)
      add(:name, :string)
    end
  end
end
