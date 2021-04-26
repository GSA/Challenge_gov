defmodule ChallengeGov.Repo.Migrations.RestructurePhaseWinnersAndWinners do
  use Ecto.Migration

  def change do
    execute "TRUNCATE TABLE winners", ""

    rename table("winners"), to: table("phase_winners")

    alter table("phase_winners") do
      add(:overview_image_path, :string)

      modify(:overview, :text, from: :string)
      modify(:overview_delta, :text, from: :string)

      remove(:winners, :map)
      remove(:winner_overview_img_url, :string)

      timestamps()
    end

    create table("winners") do
      add(:phase_winner_id, references(:phase_winners))
      add(:name, :string)
      add(:place_title, :string)
      add(:image_path, :string)

      timestamps()
    end
  end
end
