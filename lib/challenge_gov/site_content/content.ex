defmodule ChallengeGov.SiteContent.Content do
  @moduledoc """
  Security Log schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "site_content" do
    field(:section, :string)
    field(:content, :string)
    field(:content_delta, :string)
    field(:start_date, :utc_datetime)
    field(:end_date, :utc_datetime)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :section,
      :content,
      :content_delta,
      :start_date,
      :end_date
    ])
    |> unique_constraint(:section)
  end
end
