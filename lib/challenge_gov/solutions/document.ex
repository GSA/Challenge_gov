defmodule ChallengeGov.Solutions.Document do
  @moduledoc """
  Solution document schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Solutions.Solution

  @type t :: %__MODULE__{}

  schema "solution_documents" do
    belongs_to(:user, User)
    belongs_to(:solution, Solution)

    field(:filename, :string)
    field(:key, Ecto.UUID)
    field(:extension, :string)
    field(:name, :string)

    timestamps()
  end

  def create_changeset(struct, file, key) do
    struct
    |> change()
    |> put_change(:filename, file.filename)
    |> put_change(:key, key)
    |> put_change(:extension, file.extension)
  end

  def solution_changeset(struct, solution, name) do
    struct
    |> change()
    |> put_change(:solution_id, solution.id)
    |> put_change(:name, name)
    |> foreign_key_constraint(:challenge_id)
  end
end
