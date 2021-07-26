defmodule ChallengeGov.Messages.MessageContext do
  @moduledoc """
  MessageContext schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Messages.Message
  alias ChallengeGov.Messages.MessageContext
  alias ChallengeGov.Messages.MessageContextStatus

  @valid_contexts [
    "challenge",
    "submission"
  ]

  @valid_audiences [
    "all",
    "admins",
    "challenge_owners"
  ]

  @type t :: %__MODULE__{}
  schema "message_contexts" do
    belongs_to(:parent, MessageContext)
    has_many(:contexts, MessageContext)
    has_many(:messages, Message)
    has_many(:statuses, MessageContextStatus)

    belongs_to(:last_message, Message, on_replace: :nilify)

    field(:context, :string)
    field(:context_id, :integer)
    field(:audience, :string)

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :context,
      :context_id,
      :audience
    ])
    |> validate_inclusion(:context, [nil | @valid_contexts])
    |> validate_inclusion(:audience, @valid_audiences)
  end
end
