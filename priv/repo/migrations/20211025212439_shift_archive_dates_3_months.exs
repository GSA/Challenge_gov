defmodule ChallengeGov.Repo.Migrations.ShiftArchiveDates3Months do
  use Ecto.Migration

  def up do
    execute """
    UPDATE challenges
    SET archive_date = archive_date + INTERVAL '3 months';
    """

    flush()

    execute """
    UPDATE challenges
    SET sub_status = 'closed'
    WHERE archive_date >= NOW() and end_date <= NOW();
    """
  end

  def down do
    execute """
    UPDATE challenges
    SET archive_date = archive_date - INTERVAL '3 months';
    """

    flush()

    execute """
    UPDATE challenges
    SET sub_status = 'archived'
    WHERE archive_date <= NOW();
    """
  end
end
