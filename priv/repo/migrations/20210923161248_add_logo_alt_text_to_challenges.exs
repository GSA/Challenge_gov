defmodule ChallengeGov.Repo.Migrations.AddLogoAltTextToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:logo_alt_text, :string)
    end
  end
end
