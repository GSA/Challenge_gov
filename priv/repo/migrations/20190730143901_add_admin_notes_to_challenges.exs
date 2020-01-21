defmodule ChallengeGov.Repo.Migrations.AddAdminNotesToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:notes, :text)
    end
  end
end
