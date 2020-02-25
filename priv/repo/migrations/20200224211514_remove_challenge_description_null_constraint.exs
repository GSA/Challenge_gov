defmodule ChallengeGov.Repo.Migrations.RemoveChallengeDescriptionNullConstraint do
  use Ecto.Migration

  def up do
    alter table(:challenges) do
      modify :description, :text, null: true
      modify :eligibility_requirements, :text
    end
  end

  def down do
    alter table(:challenges) do
      modify :description, :text, null: false
      modify :eligibility_requirements, :string
    end
  end
end
