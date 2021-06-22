defmodule ChallengeGov.Messages.MessageContext do
  @moduledoc """
  MessageContext schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Messages.Message
  alias ChallengeGov.Messages.MessageContextStatus

  @valid_contexts [
    "challenge",
    "submission"
  ]

  # @valid_audiences [
  #   "admins",
  #   "challenge_owners",
  #   "solvers"
  # ]

  @type t :: %__MODULE__{}
  schema "message_contexts" do
    has_many(:messages, Message)
    has_many(:statuses, MessageContextStatus)

    field(:context, :string)
    field(:context_id, :integer)
    field(:audience, {:array, :string})

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :context,
      :context_id,
      :audience
    ])
    |> validate_inclusion(:context, @valid_contexts)
  end
end
