defmodule ChallengeGov.Repo.Migrations.AddChallengeOwners do
  use Ecto.Migration

  def change do
    create table(:challenge_owners) do
      add(:challenge_id, references(:challenges))
      add(:user_id, references(:users))
    end
  end
end
