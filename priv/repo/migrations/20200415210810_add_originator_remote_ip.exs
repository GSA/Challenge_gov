defmodule ChallengeGov.Repo.Migrations.AddOriginatorRemoteIp do
  use Ecto.Migration

  def change do
    alter table(:security_log) do
      add :originator_remote_ip, :string
    end
  end
end
