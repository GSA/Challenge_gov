defmodule ChallengeGov.Repo.Migrations.AddStatusToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:status, :string, default: "pending", null: false)
    end
  end
end
