defmodule ChallengeGov.Repo.Migrations.AddBriefDescriptionDeltaToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :brief_description_delta, :text
    end
  end
end
