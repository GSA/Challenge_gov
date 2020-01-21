defmodule ChallengeGov.Repo.Migrations.AddStatusToTeamMembers do
  use Ecto.Migration

  def change do
    alter table(:team_members) do
      add(:status, :text, default: "invited", null: false)
    end

    drop index(:team_members, [:user_id])
    create index(:team_members, [:user_id], unique: true, where: "status = 'accepted'")
    create index(:team_members, [:team_id, :user_id], unique: true)
  end

  def down do
    drop index(:team_members, [:user_id])
    drop index(:team_members, [:team_id, :user_id])
    create index(:team_members, [:user_id], unique: true)

    alter table(:team_members) do
      remove(:status)
    end
  end
end
