defmodule ChallengeGov.Repo.Migrations.MigrateChallengePhases do
  use Ecto.Migration

  def change do
    create table(:phases) do
      add(:challenge_id, references(:challenges), null: false)

      add(:uuid, :uuid, null: false)

      add(:title, :string)
      add(:start_date, :utc_datetime)
      add(:end_date, :utc_datetime)
      add(:open_to_submissions, :boolean)

      add(:judging_criteria, :text)
      add(:judging_criteria_delta, :text)
      add(:how_to_enter, :text)
      add(:how_to_enter_delta, :text)

      timestamps()
    end
  end
end
