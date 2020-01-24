defmodule ChallengeGov.Repo.Migrations.AdditionalFields do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:faq, :text)
      add(:winner_information, :text)
      add(:number_of_phases, :text)
      add(:phase_descriptions, :text)
      add(:phase_dates, :text)
      add(:brief_description, :text)
    end
  end
end
