defmodule ChallengeGov.Repo.Migrations.AddWinnerOverviewDelta do
  use Ecto.Migration

  def change do
    alter table(:winners) do
      add(:overview_delta, :string)
    end
  end
end
