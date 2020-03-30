defmodule ChallengeGov.Repo.Migrations.ModifySecurityLogLoggedAtTimeFormat do
  use Ecto.Migration

  def up do
    alter table(:security_log) do
      modify :logged_at, :utc_datetime, null: false
    end
  end

  def down do
    alter table(:security_log) do
      modify :logged_at, :naive_datetime, null: false
    end
  end
end
