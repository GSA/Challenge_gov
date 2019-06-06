defmodule IdeaPortal.Challenges.Challenge do
  @moduledoc """
  User schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias IdeaPortal.Accounts.User
  alias IdeaPortal.SupportingDocuments.Document
  alias IdeaPortal.Timeline.Event

  @type t :: %__MODULE__{}

  @focus_areas [
    "Housing",
    "Education",
    "Transportation",
    "Public Safety",
    "Health & Wellness",
    "Workforce Development"
  ]

  @statuses [
    "pending",
    "created",
    "archived",
    "champion assigned",
    "design",
    "vetted"
  ]

  schema "challenges" do
    field(:status, :string, default: "pending")
    field(:captured_on, :date)
    field(:focus_area, :string)
    field(:name, :string)
    field(:description, :string)
    field(:why, :string)
    field(:fixed_looks_like, :string)
    field(:technology_example, :string)
    field(:neighborhood, :string)

    field(:champion_name, :string)
    field(:champion_email, :string)

    belongs_to(:user, User)

    has_many(:events, Event)
    has_many(:supporting_documents, Document)

    timestamps()
  end

  @doc """
  List of all focus areas
  """
  def focus_areas(), do: @focus_areas

  @doc """
  List all available statuses
  """
  def statuses(), do: @statuses

  def create_changeset(struct, params) do
    struct
    |> cast(params, [
      :captured_on,
      :focus_area,
      :name,
      :description,
      :why,
      :fixed_looks_like,
      :technology_example,
      :neighborhood
    ])
    |> put_change(:captured_on, Date.utc_today())
    |> validate_required([:captured_on, :focus_area, :name, :description, :why])
    |> validate_inclusion(:focus_area, @focus_areas)
    |> validate_inclusion(:status, @statuses)
  end

  def update_changeset(struct, params) do
    struct
    |> cast(params, [
      :status,
      :captured_on,
      :focus_area,
      :name,
      :description,
      :why,
      :champion_name,
      :champion_email
    ])
    |> validate_required([:status, :captured_on, :focus_area, :name, :description, :why])
    |> validate_inclusion(:focus_area, @focus_areas)
    |> validate_inclusion(:status, @statuses)
    |> validate_format(:champion_email, ~r/.+@.+\..+/)
  end
end
