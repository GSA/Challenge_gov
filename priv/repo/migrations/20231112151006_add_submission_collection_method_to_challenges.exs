defmodule ChallengeGov.Repo.Migrations.AddSubmissionCollectionMethodToChallenges do
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
        AND column_name = 'submission_collection_method'
      ) THEN
        ALTER TABLE challenges ADD submission_collection_method VARCHAR;
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
        AND column_name = 'submission_collection_method'
      ) THEN
        ALTER TABLE challenges DROP COLUMN submission_collection_method;
      END IF;
    END
    $$ LANGUAGE plpgsql;
    """)
  end
end
