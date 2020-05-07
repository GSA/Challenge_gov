defmodule ChallengeGov.ContactForms.ContactForm do
  @moduledoc """
  ContactForm schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}
  schema "" do
    field :email, :string, virtual: true
    field :body, :binary, virtual: true
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :email,
      :body
    ])
    |> validate_required([
      :email,
      :body
    ])
    |> validate_format(:email, ~r/.+@.+\..+/)
  end
end
