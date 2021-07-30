defmodule ChallengeGov.PhaseWinners.PhaseWinner do
  @moduledoc """
  Challenge phase winner schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Challenges.Phase
  alias ChallengeGov.PhaseWinners.Winner

  @type t :: %__MODULE__{}

  @statuses [
    "draft",
    "review",
    "published"
  ]

  schema "phase_winners" do
    # Associations
    belongs_to(:phase, Phase)
    has_many(:winners, Winner)

    # Fields
    field(:uuid, Ecto.UUID, autogenerate: true)
    field(:status, :string, default: "draft")

    # Rich text
    field(:overview, :string)
    field(:overview_delta, :string)

    # Uploads
    field(:overview_image_key, Ecto.UUID)
    field(:overview_image_extension, :string)

    # Timestamps
    timestamps(type: :utc_datetime_usec)
  end

  def create_changeset(struct, phase, params \\ %{}) do
    struct
    |> cast(params, [
      :status,
      :overview,
      :overview_delta,
      :overview_image_key,
      :overview_image_extension
    ])
    |> put_change(:phase_id, phase.id)
    |> unique_constraint(:phase_id)
    |> validate_inclusion(:status, @statuses)
  end

  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :status,
      :overview,
      :overview_delta,
      :overview_image_key,
      :overview_image_extension
    ])
    |> validate_inclusion(:status, @statuses)
  end

  def overview_image_changeset(struct, key, extension) do
    struct
    |> change()
    |> put_change(:overview_image_key, key)
    |> put_change(:overview_image_extension, extension)
  end
end
