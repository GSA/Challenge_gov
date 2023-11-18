defmodule ChallengeGov.Repo.Migrations.AddFileUploadRequiredBooleanToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :file_upload_required, :boolean, default: false
    end
  end
end
