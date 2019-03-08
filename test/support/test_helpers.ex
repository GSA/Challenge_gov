defmodule IdeaPortal.TestHelpers do
  @moduledoc """
  Helper factory functions
  """

  alias IdeaPortal.Accounts

  defp user_attributes(attributes) do
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
  end

  def create_user(attributes \\ %{}) do
    attributes = user_attributes(attributes)
    {:ok, user} = Accounts.register(attributes)
    user
  end

  @doc """
  Generate a struct with user data
  """
  def user_struct(attributes \\ %{}) do
    attributes = user_attributes(attributes)
    struct(Accounts.User, attributes)
  end
end
