defmodule ChallengeGov.Repo.Migrations.AddStatusesToUsers do
  use Ecto.Migration
  alias ChallengeGov.Repo
  alias ChallengeGov.Accounts.User

  def change do
    alter table(:users) do
      add(:status, :string)
    end

    flush()

    Repo.update_all(User, set: [status: "active"])
  end
end
