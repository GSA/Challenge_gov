defmodule ChallengeGov.Repo.Migrations.AddSubscribersToChallenge do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:gov_delivery_subscribers, :integer, null: false, default: 0)
    end
  end
end
