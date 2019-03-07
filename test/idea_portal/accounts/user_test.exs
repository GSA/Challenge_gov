defmodule IdeaPortal.Accounts.UserTest do
  use ExUnit.Case

  alias IdeaPortal.Accounts.User

  describe "validations" do
    test "email format" do
      changeset = User.create_changeset(%User{}, %{email: "user@example.com"})
      refute changeset.errors[:email]

      changeset = User.create_changeset(%User{}, %{email: "userexample.com"})
      assert changeset.errors[:email]
    end
  end
end
