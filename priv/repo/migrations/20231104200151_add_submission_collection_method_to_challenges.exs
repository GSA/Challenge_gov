defmodule ChallengeGov.Repo.Migrations.AddSubmissionCollectionMethodToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :submission_collection_method, :string
    end
  end
end
