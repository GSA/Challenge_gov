defmodule ChallengeGov.Repo.Migrations.RenameChallengeOwnersToManagers do
  use Ecto.Migration

  def up do
    rename table("challenge_owners"), to: table("challenge_managers")
    execute "update users set role='challenge_manager' where role='challenge_owner'"
  end

  def down do
    rename table("challenge_managers"), to: table("challenge_owners")
    execute "update users set role='challenge_owner' where role='challenge_manager'"
  end
end
