defmodule ChallengeGov.Messages.Message do
  @moduledoc """
  Message schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Messages.MessageContext

  @valid_statuses [
    "draft",
    "sent"
  ]

  @type t :: %__MODULE__{}
  schema "messages" do
    belongs_to(:author, User)
    belongs_to(:context, MessageContext, foreign_key: :message_context_id)

    field(:content, :string)
    field(:content_delta, :string)

    field(:status, :string, default: "sent")

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :content,
      :content_delta,
      :status
    ])
    |> validate_inclusion(:status, @valid_statuses)
  end

  def create_changeset(struct, user, context, params \\ %{}) do
    struct
    |> changeset(params)
    |> put_change(:author_id, user.id)
    |> put_change(:message_context_id, context.id)
    |> foreign_key_constraint(:author)
    |> foreign_key_constraint(:message_context)
  end
end
