defmodule ChallengeGov.Repo.Migrations.AddNewFieldsToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:fixed_looks_like, :text)
      add(:technology_example, :text)
      add(:neighborhood, :text)
    end
  end
end
