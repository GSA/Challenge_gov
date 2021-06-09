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

  @type t :: %__MODULE__{}
  schema "message_contexts" do
    has_many(:messages, Message)
    has_many(:statuses, MessageContextStatus)

    field(:context, :string)
    field(:context_id, :integer)

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :context,
      :context_id
    ])
    |> validate_inclusion(:context, @valid_contexts)
  end
end
