defmodule ChallengeGov.Repo.Migrations.CreateChallenges do
  use Ecto.Migration

  def change do
    create table("challenges") do
      add(:user_id, references(:users), null: false)

      add(:focus_area, :string, null: false)
      add(:name, :string, null: false)
      add(:description, :text, null: false)
      add(:why, :text, null: false)

      timestamps()
    end
  end
end
