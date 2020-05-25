defmodule ChallengeGov.Repo.Migrations.CreateChallengeVirtualFields do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:upload_logo, :boolean)
      add(:is_multi_phase, :boolean)
    end
  end
end
