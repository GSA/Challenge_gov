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
end
