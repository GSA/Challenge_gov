defmodule ChallengeGov.Repo.Migrations.AddPrimaryAndOtherTypeToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :primary_type, :string
      add :other_type, :string
    end
  end
end
