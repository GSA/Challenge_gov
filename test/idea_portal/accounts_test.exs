defmodule IdeaPortal.AccountsTest do
  use IdeaPortal.DataCase

  alias IdeaPortal.Accounts

  describe "registering an account" do
    test "creating successfully" do
      {:ok, account} =
        Accounts.register(%{
          email: "user@example.com",
          first_name: "John",
          last_name: "Smith",
          phone_number: "123-123-1234",
          password: "password",
          password_confirmation: "password"
        })

      assert account.email == "user@example.com"
      assert account.password_hash
    end

    test "unique emails" do
      {:ok, account} =
        Accounts.register(%{
          email: "user@example.com",
          first_name: "John",
          last_name: "Smith",
          phone_number: "123-123-1234",
          password: "password",
          password_confirmation: "password"
        })

      {:error, changeset} =
        Accounts.register(%{
          email: account.email,
          first_name: "John",
          last_name: "Smith",
          password: "password",
          password_confirmation: "password"
        })

      assert changeset.errors[:email]
    end

    test "with errors" do
      {:error, changeset} =
        Accounts.register(%{
          email: "user@example.com",
          phone_number: "123-123-1234",
          password: "password",
          password_confirmation: "password"
        })

      assert changeset.errors[:first_name]
    end
  end

  describe "finding via token" do
    test "user exists" do
      user = TestHelpers.create_user()

      {:ok, found_user} = Accounts.get_by_token(user.token)

      assert found_user.id == user.id
    end

    test "does not exist" do
      {:error, :not_found} = Accounts.get_by_token(UUID.uuid4())
    end

    test "invalid UUID" do
      {:error, :not_found} = Accounts.get_by_token("not a uuid")
    end
  end
end
