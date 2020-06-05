defmodule ChallengeGov.Repo.Migrations.AddPrizeTypeToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:prize_type, :string)
    end
  end
end
