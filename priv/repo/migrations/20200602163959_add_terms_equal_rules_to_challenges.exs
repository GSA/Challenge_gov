defmodule ChallengeGov.Repo.Migrations.AddTermsEqualRulesToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :terms_equal_rules, :boolean
    end
  end
end
