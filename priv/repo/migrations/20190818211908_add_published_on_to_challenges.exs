defmodule ChallengeGov.Repo.Migrations.AddPublishedOnToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:published_on, :date)
    end
  end
end
