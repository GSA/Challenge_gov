defmodule ChallengeGov.Challenges.Bulletin do
  @moduledoc """
  Challenge bulletin schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  schema "" do
    field :body, :string, virtual: true
    field :subject, :string, virtual: true
  end

  def create_changeset(struct, params) do
    struct
    |> cast(params, [:subject, :body])
  end
end
