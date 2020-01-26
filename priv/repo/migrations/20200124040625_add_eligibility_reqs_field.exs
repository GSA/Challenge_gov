defmodule ChallengeGov.Repo.Migrations.AddEligibilityReqsField do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:eligibility_requirements, :string)
    end
  end
end
