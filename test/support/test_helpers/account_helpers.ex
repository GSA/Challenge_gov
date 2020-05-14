defmodule ChallengeGov.TestHelpers.AccountHelpers do
  @moduledoc """
  Helper factory functions for accounts
  """
  alias ChallengeGov.Accounts
  alias ChallengeGov.Repo

  defp default_attributes(attributes) do
    Map.merge(
      %{
        email: "user@example.com",
        first_name: "John",
        last_name: "Smith",
        phone_number: "123-123-1234",
        password: "password",
        password_confirmation: "password",
        token: UUID.uuid4(),
        role: "solver",
        status: "active"
      },
      attributes
    )
  end

  def create_user(attributes \\ %{}) do
    {:ok, user} =
      %Accounts.User{}
      |> Accounts.User.create_changeset(default_attributes(attributes))
      |> Repo.insert()

    user
  end
end
