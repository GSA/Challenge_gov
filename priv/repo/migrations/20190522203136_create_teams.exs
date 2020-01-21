defmodule ChallengeGov.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add(:name, :string, null: false)
      add(:description, :text)

      timestamps()
    end

    create table(:team_members) do
      add(:user_id, references(:users), null: false)
      add(:team_id, references(:teams), null: false)

      timestamps()
    end

    create index(:team_members, :user_id, unique: true)
  end
end
