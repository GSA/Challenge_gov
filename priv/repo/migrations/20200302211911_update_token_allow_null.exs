defmodule ChallengeGov.Repo.Migrations.UpdateTokenAllowNull do
  use Ecto.Migration

  def up do
    alter table(:users) do
      modify :token, :uuid, null: true
    end
  end

  def down do
    alter table(:users) do
      modify :token, :uuid, null: false
    end
  end
end
