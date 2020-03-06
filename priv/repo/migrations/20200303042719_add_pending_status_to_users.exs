defmodule ChallengeGov.Repo.Migrations.AddPendingStatusToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:pending, :boolean)
    end
  end
end
