defmodule ChallengeGov.Repo.Migrations.AddKeyExtensionToWinners do
  use Ecto.Migration

  def up do
    alter table(:winners) do
      remove(:image_path)
      add(:image_key, :uuid)
      add(:image_extension, :string)
    end
  end

  def down do
    raise "Sorry this is a one way migration"
  end
end
