defmodule ChallengeGov.Repo.Migrations.AddShortUrlsToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:short_url, :string)
    end
  end
end
