defmodule :"Elixir.ChallengeGov.Repo.Migrations.Remove-pending-column-from-users" do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove(:pending)
    end
  end
end
