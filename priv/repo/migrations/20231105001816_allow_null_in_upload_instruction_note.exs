defmodule ChallengeGov.Repo.Migrations.AllowNullInUploadInstructionNote do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      modify :upload_instruction_note, :string, null: true
    end
  end
end
