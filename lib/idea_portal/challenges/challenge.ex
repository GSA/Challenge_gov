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
    field(:published_on, :date)
    field(:focus_area, :string)
    field(:name, :string)
    field(:description, :string)
    field(:why, :string)
    field(:fixed_looks_like, :string)
    field(:technology_example, :string)
    field(:neighborhood, :string)

    field(:champion_name, :string)
    field(:champion_email, :string)

    field(:submitter_first_name, :string)
    field(:submitter_last_name, :string)
    field(:submitter_email, :string)
    field(:submitter_phone, :string)

    field(:notes, :string)

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

  def create_changeset(struct, params, user) do
    struct
    |> cast(params, [
      :focus_area,
      :name,
      :description,
      :why,
      :fixed_looks_like,
      :technology_example,
      :neighborhood
    ])
    |> put_change(:submitter_first_name, user.first_name)
    |> put_change(:submitter_last_name, user.last_name)
    |> put_change(:submitter_email, user.email)
    |> put_change(:submitter_phone, user.phone_number)
    |> put_change(:captured_on, Date.utc_today())
    |> validate_required([
      :captured_on,
      :focus_area,
      :name,
      :description,
      :why,
      :fixed_looks_like,
      :technology_example
    ])
    |> validate_inclusion(:focus_area, @focus_areas)
    |> validate_inclusion(:status, @statuses)
  end

  def update_changeset(struct, params) do
    struct
    |> cast(params, [
      :status,
      :captured_on,
      :published_on,
      :focus_area,
      :name,
      :description,
      :why,
      :fixed_looks_like,
      :technology_example,
      :neighborhood,
      :champion_name,
      :champion_email,
      :submitter_first_name,
      :submitter_last_name,
      :submitter_email,
      :submitter_phone,
      :notes
    ])
    |> validate_required([
      :status,
      :captured_on,
      :focus_area,
      :name,
      :description,
      :why,
      :fixed_looks_like,
      :technology_example
    ])
    |> validate_inclusion(:focus_area, @focus_areas)
    |> validate_inclusion(:status, @statuses)
    |> validate_format(:champion_email, ~r/.+@.+\..+/)
  end

  def admin_changeset(struct, params, user) do
    struct
    |> create_changeset(params, user)
    |> cast(params, [
      :captured_on,
      :published_on,
      :submitter_first_name,
      :submitter_last_name,
      :submitter_email,
      :submitter_phone,
      :notes
    ])
  end

  def publish_changeset(struct) do
    struct
    |> change()
    |> put_change(:status, "created")
    |> put_change(:published_on, Date.utc_today())
  end
end
