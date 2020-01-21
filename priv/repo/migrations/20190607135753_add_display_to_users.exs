defmodule ChallengeGov.Repo.Migrations.AddDisplayToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:display, :boolean, default: true, null: false)
    end
  end
end
