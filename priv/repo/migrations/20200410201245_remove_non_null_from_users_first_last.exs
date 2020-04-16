defmodule :"Elixir.ChallengeGov.Repo.Migrations.Remove_non_null_from_users_first_last" do
  use Ecto.Migration

  def up do
    alter table(:users) do
      modify :first_name, :string, null: true
      modify :last_name, :string, null: true
    end
  end

  def down do
    alter table(:users) do
      modify :first_name, :string, null: false
      modify :last_name, :string, null: false
    end
  end
end
