defmodule ChallengeGov.Repo.Migrations.AddRolesToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:role, :string, default: "user", null: false)
    end
  end
end
