defmodule ChallengeGov.Reports.DAPReport do
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
    field(:deleted_at, :utc_datetime)

    timestamps(type: :utc_datetime_usec)
  end

  def create_changeset(struct, file, key, custom_name \\ "") do
    name =
      if is_nil(custom_name) or String.trim(custom_name) === "",
        do: file.filename,
        else: custom_name

    struct
    |> change()
    |> put_change(:filename, name)
    |> put_change(:key, key)
    |> put_change(:extension, file.extension)
  end
end
