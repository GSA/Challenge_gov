defmodule ChallengeGov.Repo.Migrations.AddWinnerImageToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:winner_image_key, :uuid)
      add(:winner_image_extension, :string)
    end
  end
end
