defmodule ChallengeGov.Repo.Migrations.ShiftArchiveDates3Months do
  use Ecto.Migration

  def up do
    execute """
    UPDATE challenges
    SET archive_date = archive_date + INTERVAL '3 months'
    WHERE archive_date IS NOT NULL;
    """

    flush()

    execute """
    UPDATE challenges
    SET sub_status = 'closed'
    WHERE archive_date >= NOW() AND end_date <= NOW()
    AND archive_date IS NOT NULL AND end_date IS NOT NULL;
    """
  end

  def down do
    execute """
    UPDATE challenges
    SET archive_date = archive_date - INTERVAL '3 months'
    WHERE archive_date IS NOT NULL;
    """

    flush()

    execute """
    UPDATE challenges
    SET sub_status = 'archived'
    WHERE archive_date <= NOW()
    AND archive_date IS NOT NULL;
    """
  end
end
