defmodule ChallengeGov.Repo.Migrations.AddAvatarFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:avatar_key, :uuid)
      add(:avatar_extension, :string)
    end
  end
end
