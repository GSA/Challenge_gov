defmodule ChallengeGov.Repo.Migrations.AddUploadInstructionNoteToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :upload_instruction_note, :string, null: true
    end
  end
end
