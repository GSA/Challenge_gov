defmodule ChallengeGov.Challenges.Phases.Winner do
  @moduledoc """
  Challenge phase winner schema
  """

  use Ecto.Schema

  alias ChallengeGov.Repo
  alias Stein.Storage

  import Ecto.Changeset

  alias ChallengeGov.Challenges.Phase

  @type t :: %__MODULE__{}

  @statuses [
    "draft",
    "review",
    "published"
  ]

  schema "winners" do
    belongs_to(:phase, Phase)

    field(:uuid, Ecto.UUID, autogenerate: true)
    field(:status, :string)
    field(:overview, :string)

    # Images
    field(:winner_overview_img_url, :string)

    # field :winners, {:array, :map}
    embeds_many :winners, __MODULE__.SingleWinner
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :status,
      :overview,
      :winner_overview_img_url,
      :phase_id
    ])
    |> cast_embed(:winners)
    |> unique_constraint(:phase_id)
  end

  def update_winners(%__MODULE__{} = winner, attrs) do
    IO.inspect(winner)
    IO.inspect(attrs)
  end

  # def winner_image_changeset(struct, key, extension) do
  #  struct
  #  |> change()
  #  |> put_change(:winner_image_key, key)
  #  |> put_change(:winner_image_extension, extension)
  # end
end

defmodule ChallengeGov.Challenges.Phases.Winner.SingleWinner do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :winner_img_url, :string
    field :place_title, :string
    field :name, :string
    field :temp_id, :string, virtual: true
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :winner_img_url,
      :place_title,
      :name,
      :temp_id
    ])
  end
end
