defmodule ChallengeGov.Challenges.Phases.Winner do
  @moduledoc """
  Challenge phase winner schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Challenges.Phase

  @type t :: %__MODULE__{}

  @statuses [
    "draft",
    "published"
  ]

  schema "winners" do
    belongs_to(:phase, Phase)

    field(:uuid, Ecto.UUID, autogenerate: true)
    field(:status, :string)
    field(:overview, :string)

    # Images
    field(:winner_image_key, Ecto.UUID)
    field(:winner_image_extension, :string)

    #field :winners, {:array, :map}
    embeds_many :winners, __MODULE__.SingleWinner
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
          :status,
          :overview,
          :winner_image_extension,
        ])
    |> cast_embed(:winners)
  end

  def winner_image_changeset(struct, key, extension) do
    struct
    |> change()
    |> put_change(:winner_image_key, key)
    |> put_change(:winner_image_extension, extension)
  end
end

defmodule ChallengeGov.Challenges.Phases.Winner.SingleWinner do
  use Ecto.Schema

  embedded_schema do
    field :winner_image_key, Ecto.UUID
    field :winner_image_extension, :string
    field :place_title, :string
    field :name, :string
    field :temp_id, :string, virtual: true
  end

  """
  def changeset(struct, params) do
    struct
    |> cast(params, [
          :winner_image_key,
          :winner_image_extension,
          :place_title,
          :name,
          :temp_id
        ])
  end
  """
end
