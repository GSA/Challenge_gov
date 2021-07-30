defmodule ChallengeGov.Messages.MessageContext do
  @moduledoc """
  MessageContext schema

  -----------------------------
  - Types of Message Contexts -
  -----------------------------
  Gives a description of each context type and the relevant params, permissions, and reply functionality
  If a param is not listed assume nil

  Broadcast Contexts
  ------------------
  Thread Type: B-1
  Description: Single admin created thread that broadcasts messages to all users.
  Audience: all
  Who can create: 
    - Admin
  Who can see: 
    - Admin: All
    - Challenge Owner: All
    - Solver: All
  What happens on reply:
    - Admin: Sends another broadcast message in same thread
    - Challenge Owner: Can't reply
    - Solver: Can't reply

  Thread Type: B-2
  Description: Admin created thread that broadcasts messages to all challenge owners
  Audience: challenge_owners
  Who can create: 
    - Admin
  Who can see: 
    - Admin: All 
    - Challenge Owner: All
  What happens on reply:
    - Admin: Sends another broadcast message in same thread
    - Challenge Owner: Creates a new message context of type I-1

  Thread Type: B-3
  Description: Admin or challenge owner created thread that broadcasts messages to all users related to challenge
  Context: challenge
  Context ID: challenge_id
  Audience: all
  Who can create: 
    - Admin
    - Challenge Owner
  Who can see: 
    - Admin: All 
    - Challenge Owner: An owner of the challenge referenced
    - Solver: Has a submission on the challenge referenced
  What happens on reply:
    - Admin: Sends another broadcast message in same thread
    - Challenge Owner: Sends another broadcast message in same thread
    - Solver: Creates a new message context of type I-2

  Group Contexts
  --------------
  Thread Type: G-1
  Description: Single admin created thread for group discussion with all admins
  Audience: admins
  Who can create: 
    - Admin
  Who can see: 
    - Admin: All
  What happens on reply:
    - Admin: Sends another message in same thread

  Thread Type: G-2
  Description: Admin or challenge owner created group thread around a challenge
  Context: challenge
  Context ID: challenge_id
  Audience: challenge_owners
  Who can create: 
    - Admin
    - Challenge Owner
  Who can see: 
    - Admin: All
    - Challenge Owner: Related to the challenge referenced by context_id
  What happens on reply:
    - Admin: Sends another message in same thread
    - Challenge Owner: Sends another message in same thread

  Isolated Contexts
  -----------------
  Thread Type: I-1
  Description: Thread spawned from a challenge owner responding to thread type B-2
  Parent ID: ID of the broadcast message context this context spawned from
  Context: challenge_owner
  Context ID: ID of the challenge owner being messaged
  Audience: all
  Who can create:
    - Challenge Owner: By replying to a thread type B-2
  Who can see:
    - Admin: All 
    - Challenge Owner: Referenced by context_id
  What happens on reply:
    - Admin: Sends another message in same thread
    - Challenge Owner: Sends another message in same thread

  Thread Type: I-2
  Description: Thread spawned from a solver responding to thread type B-3
  Parent ID: ID of the broadcast message context this context spawned from
  Context: submission
  Context ID: ID of the submission being messaged
  Audience: all
  Who can create: 
    - Admin: Messaging a solver/submission or group of them making individual contexts for each
    - Challenge Owner: Messaging a solver/submission or group of them making individual contexts for each
    - Solver: By replying to a thread type B-3
  Who can see: 
    - Admin: All
    - Challenge Owner: Related to the parent context challenge, 
    - Solver: Related to submission being referenced by context_id
  What happens on reply:
    - Admin: Sends another message in same thread
    - Challenge Owner: Sends another message in same thread
    - Solver: Sends another message in same thread
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Messages.Message
  alias ChallengeGov.Messages.MessageContext
  alias ChallengeGov.Messages.MessageContextStatus

  @valid_contexts [
    "challenge",
    "challenge_owner",
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
    has_many(:contexts, MessageContext, foreign_key: :parent_id)
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
      :audience,
      :parent_id
    ])
    |> foreign_key_constraint(:parent_id)
    |> validate_inclusion(:context, [nil | @valid_contexts])
    |> validate_inclusion(:audience, @valid_audiences)
  end
end
