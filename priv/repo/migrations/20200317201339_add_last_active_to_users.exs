defmodule ChallengeGov.Repo.Migrations.AddLastActiveToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:last_active, :utc_datetime)
    end
  end
end
