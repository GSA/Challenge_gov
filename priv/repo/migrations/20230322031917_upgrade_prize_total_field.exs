defmodule ChallengeGov.Repo.Migrations.UpgradePrizeTotalField do
  use Ecto.Migration

  # changed the size of the field to allow bigger prizes

  def change do
    alter table(:challenges) do
      modify(:prize_total, :bigint, null: false)
    end
  end
end
