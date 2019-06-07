defmodule Web.Admin.UserView do
  use Web, :view

  alias Web.AccountView
  alias Web.SharedView

  def phone_number(%{phone_number: nil}), do: "Not Provided"

  def phone_number(user), do: user.phone_number

  def email_verified?(user) do
    case is_nil(user.email_verified_at) do
      true ->
        "Not verified"

      false ->
        "Verified"
    end
  end
end
