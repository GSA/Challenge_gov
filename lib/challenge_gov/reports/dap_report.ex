defmodule ChallengeGov.Reports.DapReport do
  @moduledoc """
  DAP Report schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "dap_reports" do
    field(:filename, :string)
    field(:key, Ecto.UUID)
    field(:extension, :string)

    timestamps(type: :utc_datetime_usec)
  end

  def create_changeset(struct, file, key, custom_name \\ "") do
    name = Web.DocumentView.name(file, custom_name)

    struct
    |> change()
    |> put_change(:filename, name)
    |> put_change(:key, key)
    |> put_change(:extension, file.extension)
  end
end
