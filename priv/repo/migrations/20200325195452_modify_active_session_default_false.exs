defmodule ChallengeGov.Repo.Migrations.ModifyActiveSessionDefaultFalse do
  use Ecto.Migration
  alias ChallengeGov.Repo
  alias ChallengeGov.Accounts.User

  def up do
    alter table(:users) do
      modify :active_session, :boolean, default: false
    end

    flush()

    Repo.update_all(User, set: [active_session: false])
  end

  def down do
    alter table(:users) do
      modify :active_session, :boolean
    end
  end
end
