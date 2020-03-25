defmodule ChallengeGov.Repo.Migrations.AddRejectionMessageToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:rejection_message, :text)
    end
  end
end
