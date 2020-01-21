defmodule ChallengeGov.Repo.Migrations.AddSubmitterInfoToChallenge do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:submitter_first_name, :text)
      add(:submitter_last_name, :text)
      add(:submitter_email, :text)
      add(:submitter_phone, :text)
    end
  end
end
