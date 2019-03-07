defmodule IdeaPortal.TestHelpers do
  @moduledoc """
  Helper factory functions
  """

  alias IdeaPortal.Accounts

  def create_user(attributes \\ %{}) do
    attributes =
      Map.merge(
        %{
          email: "user@example.com",
          first_name: "John",
          last_name: "Smith",
          phone_number: "123-123-1234",
          password: "password",
          password_confirmation: "password"
        },
        attributes
      )

    {:ok, user} = Accounts.register(attributes)

    user
  end
end
