defmodule ChallengeGov.Repo.Migrations.AddKeyExtensionToPhaseWinners do
  use Ecto.Migration

  def up do
    alter table(:phase_winners) do
      remove(:overview_image_path)
      add(:overview_image_key, :uuid)
      add(:overview_image_extension, :string)
    end
  end

  def down do
    raise "Sorry this is a one way migration"
  end
end
