defmodule ChallengeGov.Submissions.Document do
  @moduledoc """
  Submission document schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Submissions.Submission

  @type t :: %__MODULE__{}

  schema "submission_documents" do
    belongs_to(:user, User)
    belongs_to(:submission, Submission)

    field(:filename, :string)
    field(:key, Ecto.UUID)
    field(:extension, :string)
    field(:name, :string)

    timestamps(type: :utc_datetime_usec)
  end

  def create_changeset(struct, file, key, name \\ "") do
    struct
    |> change()
    |> put_change(:filename, file.filename)
    |> put_change(:key, key)
    |> put_change(:extension, file.extension)
    |> put_change(:name, name)
  end

  def submission_changeset(struct, submission) do
    struct
    |> change()
    |> put_change(:submission_id, submission.id)
    |> foreign_key_constraint(:challenge_id)
  end
end
