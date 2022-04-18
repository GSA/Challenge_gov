defmodule ChallengeGov.Repo.Migrations.AddPdfReferenceToSubmissionsTable do
  use Ecto.Migration

  def up do
    alter table("submissions") do
      add :pdf_reference, :string
    end
  end

  def down do
    alter table("submissions") do
      remove :pdf_reference
    end
  end
end
