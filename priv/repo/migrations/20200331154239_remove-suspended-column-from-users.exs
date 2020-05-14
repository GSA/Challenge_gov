defmodule :"Elixir.ChallengeGov.Repo.Migrations.Remove-suspended-column-from-users" do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove(:suspended)
    end
  end
end
