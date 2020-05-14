defmodule ChallengeGov.Repo.Migrations.AddSecurityLogTable do
  use Ecto.Migration

  def change do
    create table(:security_log) do
      add(:user_id, references(:users))
      add(:type, :string)
      add(:data, :map)

      timestamps()
    end
  end
end
