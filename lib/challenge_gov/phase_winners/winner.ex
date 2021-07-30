defmodule ChallengeGov.PhaseWinners.Winner do
  @moduledoc """
  Individual Winners
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.PhaseWinners.PhaseWinner

  schema "winners" do
    # Associations
    belongs_to(:phase_winner, PhaseWinner)

    # Fields
    field :name, :string
    field :place_title, :string

    # Uploads
    field(:image_key, Ecto.UUID)
    field(:image_extension, :string)

    # Timestamps
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :phase_winner_id,
      :name,
      :place_title,
      :image_key,
      :image_extension
    ])
  end

  def image_changeset(struct, key, extension) do
    struct
    |> change()
    |> put_change(:image_key, key)
    |> put_change(:image_extension, extension)
  end
end
