defmodule ChallengeGov.Repo.Migrations.AddTimelineEventsToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:timeline_events, :map)
    end
  end
end
