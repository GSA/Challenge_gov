defmodule ChallengeGov.Repo.Migrations.ChallengePrizeTotal0Default do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      modify(:prize_total, :integer, null: false)
    end

    execute "update challenges set prize_total = 0 where prize_total = null;"
  end
end
