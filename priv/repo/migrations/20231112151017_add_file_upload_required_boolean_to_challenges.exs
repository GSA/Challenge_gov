defmodule ChallengeGov.Repo.Migrations.AddFileUploadRequiredBooleanToChallenges do
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
        AND column_name = 'file_upload_required'
      ) THEN
        ALTER TABLE challenges ADD file_upload_required BOOLEAN;
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
        AND column_name = 'file_upload_required'
      ) THEN
        ALTER TABLE challenges DROP COLUMN file_upload_required;
      END IF;
    END
    $$ LANGUAGE plpgsql;
    """)
  end
end
