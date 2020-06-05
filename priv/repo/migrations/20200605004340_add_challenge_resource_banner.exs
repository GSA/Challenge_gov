defmodule ChallengeGov.Repo.Migrations.AddChallengeResourceBanner do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:resource_banner_key, :uuid)
      add(:resource_banner_extension, :string)
    end
  end
end
