defmodule ChallengeGov.Repo.Migrations.CreateTimelineEvents do
  use Ecto.Migration

  def change do
    create table(:timeline_events) do
      add(:challenge_id, references(:challenges), null: false)
      add(:title, :string, null: false)
      add(:body, :text)
      add(:occurs_on, :date, null: false)

      timestamps()
    end
  end
end
