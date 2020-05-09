defmodule ChallengeGov.Repo.Migrations.CreateSavedChallenges do
  use Ecto.Migration

  def change do
    create table(:saved_challenges) do
      add(:user_id, references(:users), null: false)
      add(:challenge_id, references(:challenges), null: false)

      timestamps()
    end
  end
end
