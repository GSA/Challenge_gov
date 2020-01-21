defmodule ChallengeGov.Repo.Migrations.AddCapturedOnToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:captured_on, :date)
    end
  end
end
