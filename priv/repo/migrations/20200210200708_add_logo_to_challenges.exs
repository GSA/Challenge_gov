defmodule ChallengeGov.Repo.Migrations.AddLogoToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:logo_key, :uuid)
      add(:logo_extension, :string)
    end
  end
end
