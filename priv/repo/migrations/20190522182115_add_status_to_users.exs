defmodule ChallengeGov.Repo.Migrations.AddStatusToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:finalized, :boolean, default: true, null: false)
    end
  end
end
