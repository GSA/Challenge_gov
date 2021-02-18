defmodule ChallengeGov.Repo.Migrations.AddPhaseWinners do
  use Ecto.Migration

  def change do
    create table(:winners) do
      add(:phase_id, references(:phases))
      add(:uuid, :uuid, null: false)
      add(:status, :string)
      add(:overview, :string)

      add(:winner_overview_img_url, :string)

      add(:winners, :map)
    end

    create unique_index(:winners, [:phase_id])
  end
end
