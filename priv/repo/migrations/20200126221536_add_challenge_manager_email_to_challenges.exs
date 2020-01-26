defmodule ChallengeGov.Repo.Migrations.AddChallengeManagerEmailToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:challenge_manager_email, :string)
    end
  end
end
