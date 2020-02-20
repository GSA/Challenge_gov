defmodule ChallengeGov.Repo.Migrations.ChangeTeamsToAgencies do
  use Ecto.Migration

  def up do
    drop table("team_members")
    drop table("teams")

    create table(:agencies) do
      add(:name, :string, null: false)
      add(:description, :text)
      add(:avatar_key, :uuid)
      add(:avatar_extension, :string)
      add(:deleted_at, :utc_datetime)

      timestamps()
    end

    create table(:agency_members) do
      add(:user_id, references(:users), null: false)
      add(:agency_id, references(:agencies), null: false)

      timestamps()
    end

    create index(:agency_members, :user_id, unique: true)
  end

  def down do
    drop table("agency_members")
    drop table("agencies")

    create table(:teams) do
      add(:name, :string, null: false)
      add(:description, :text)
      add(:avatar_key, :uuid)
      add(:avatar_extension, :string)
      add(:deleted_at, :utc_datetime)

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
