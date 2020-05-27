defmodule ChallengeGov.Repo.Migrations.AddExternalChallengeLogoUrl do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:external_logo_url, :string)
    end
  end
end
