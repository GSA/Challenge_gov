defmodule ChallengeGov.Repo.Migrations.NewFields do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:faq, :text)
      add(:winner_information, :text)
      add(:number_of_phases, :text)
      add(:phase_descriptions, :text)
      add(:phase_dates, :text)
    end
  end
end
