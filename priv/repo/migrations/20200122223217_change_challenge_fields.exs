defmodule ChallengeGov.Repo.Migrations.ChangeChallengeFields do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      remove(:focus_area)
      remove(:name)
      remove(:why)
      remove(:fixed_looks_like)
      remove(:technology_example)
      remove(:neighborhood)
      remove(:champion_name)
      remove(:champion_email)
      remove(:notes)
      remove(:submitter_first_name)
      remove(:submitter_last_name)
      remove(:submitter_email)
      remove(:submitter_phone)

      add(:title, :string)
      add(:tagline, :string)
      add(:poc_email, :string)
      add(:agency_name, :string)
      add(:how_to_enter, :text)
      add(:rules, :text)
      add(:external_url, :string)
      add(:custom_url, :string)
      add(:start_date, :utc_datetime)
      add(:end_date, :utc_datetime)
      add(:fiscal_year, :integer)
      add(:type, :string)
      add(:prize_total, :integer)
      add(:prize_description, :text)
      add(:judging_criteria, :text)
      add(:challenge_manager, :string)
      add(:legal_authority, :string)
    end
  end
end
