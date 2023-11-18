defmodule ChallengeGov.Repo.Migrations.AddUploadInstructionNoteToChallenges do
  use Ecto.Migration

  def up do
    execute("""
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'challenges'
        AND column_name = 'upload_instruction_note'
      ) THEN
        ALTER TABLE challenges ADD upload_instruction_note TEXT;
      END IF;
    END
    $$ LANGUAGE plpgsql;
    """)
  end

  def down do
    execute("""
    DO $$
    BEGIN
      IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'challenges'
        AND column_name = 'upload_instruction_note'
      ) THEN
        ALTER TABLE challenges DROP COLUMN upload_instruction_note;
      END IF;
    END
    $$ LANGUAGE plpgsql;
    """)
  end
end
