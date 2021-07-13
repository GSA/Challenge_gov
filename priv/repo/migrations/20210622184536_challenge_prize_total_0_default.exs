defmodule ChallengeGov.Repo.Migrations.ChallengePrizeTotal0Default do
  use Ecto.Migration

  def change do
    execute "update challenges set prize_total = 0 where prize_total is null;", ""

    alter table(:challenges) do
      modify(:prize_total, :integer, null: false)
    end
  end
end
