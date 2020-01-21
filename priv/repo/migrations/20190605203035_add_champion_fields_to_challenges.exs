defmodule ChallengeGov.Repo.Migrations.AddChampionFieldsToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:champion_name, :text)
      add(:champion_email, :string)
    end
  end
end
