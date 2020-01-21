defmodule ChallengeGov.Repo.Migrations.AddAvatarFieldsToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:avatar_key, :uuid)
      add(:avatar_extension, :string)
    end
  end
end
