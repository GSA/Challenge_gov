defmodule ChallengeGov.Repo.Migrations.RenameSolutionsToSubmissions do
  use Ecto.Migration

  def up do
    rename table(:solutions), to: table(:submissions)
    rename table(:solution_documents), to: table(:submission_documents)

    rename table(:submission_documents), :solution_id, to: :submission_id
    rename table(:submission_invites), :solution_id, to: :submission_id

    execute "ALTER SEQUENCE solutions_id_seq RENAME TO submissions_id_seq;"
    execute "ALTER SEQUENCE solution_documents_id_seq RENAME TO submission_documents_id_seq;"

    execute "ALTER INDEX solutions_pkey RENAME TO submissions_pkey;"
    execute "ALTER INDEX solution_documents_pkey RENAME TO submission_documents_pkey;"
  end

  def down do
    rename table(:submissions), to: table(:solutions)
    rename table(:submission_documents), to: table(:solution_documents)

    rename table(:solution_documents), :submission_id, to: :solution_id
    rename table(:submission_invites), :submission_id, to: :solution_id

    execute "ALTER SEQUENCE submissions_id_seq RENAME TO solutions_id_seq;"
    execute "ALTER SEQUENCE submission_documents_id_seq RENAME TO solution_documents_id_seq;"

    execute "ALTER INDEX solutions_pkey RENAME TO submissions_pkey;"
    execute "ALTER INDEX solution_documents_pkey RENAME TO submission_documents_pkey;"
  end
end
