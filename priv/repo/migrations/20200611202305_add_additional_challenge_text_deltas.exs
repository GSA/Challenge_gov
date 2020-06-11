defmodule ChallengeGov.Repo.Migrations.AddAdditionalChallengeTextDeltas do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :eligibility_requirements_delta, :text
      add :rules_delta, :text
      add :terms_and_conditions_delta, :text
    end
  end
end
