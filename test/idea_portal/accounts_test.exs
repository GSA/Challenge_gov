defmodule ChallengeGov.AccountsTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Accounts
  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Emails
  alias ChallengeGov.Recaptcha.Mock, as: Recaptcha

  doctest Accounts

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

    test "sends a verification email" do
      {:ok, account} =
        Accounts.register(%{
          email: "user@example.com",
          first_name: "John",
          last_name: "Smith",
          phone_number: "123-123-1234",
          password: "password",
          password_confirmation: "password"
        })

      assert account.email_verification_token
      assert_delivered_email(Emails.verification_email(account))
    end

    test "uploading an avatar" do
      {:ok, account} =
        Accounts.register(%{
          email: "user@example.com",
          first_name: "John",
          last_name: "Smith",
          phone_number: "123-123-1234",
          avatar: %{path: "test/fixtures/test.png"},
          password: "password",
          password_confirmation: "password"
        })

      assert account.avatar_extension == ".png"
      assert account.avatar_key
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

    test "recaptcha token is invalid" do
      Recaptcha.set_valid_token_response(false)

      {:error, changeset} =
        Accounts.register(%{
          email: "user@example.com",
          first_name: "John",
          last_name: "Smith",
          phone_number: "123-123-1234",
          password: "password",
          password_confirmation: "password",
          recaptcha_token: "invalid"
        })

      assert changeset.errors[:recaptcha_token]
    end
  end

  describe "inviting a user" do
    test "successfully" do
      user = TestHelpers.create_user()

      {:ok, invited_user} =
        Accounts.invite(user, %{
          email: "invitee@example.com"
        })

      assert invited_user.email == "invitee@example.com"
      refute invited_user.finalized
      assert_delivered_email(Emails.invitation_email(invited_user, user))
    end

    test "failure" do
      user = TestHelpers.create_user()

      {:error, changeset} = Accounts.invite(user, %{})

      assert changeset.errors[:email]
    end

    test "recaptcha token is invalid" do
      user = TestHelpers.create_user()

      Recaptcha.set_valid_token_response(false)

      {:error, changeset} =
        Accounts.invite(user, %{
          email: "user@example.com",
          recaptcha_token: "invalid"
        })

      assert changeset.errors[:recaptcha_token]
    end
  end

  describe "accepting an invite" do
    test "successfully" do
      user = TestHelpers.create_user()
      {:ok, invited_user} = Accounts.invite(user, %{email: "invitee@example.com"})

      {:ok, invited_user} =
        Accounts.finalize_invitation(invited_user.email_verification_token, %{
          first_name: "User",
          last_name: "Example",
          phone_number: "123-123-1234",
          password: "password",
          password_confirmation: "password"
        })

      assert invited_user.first_name == "User"
      assert invited_user.finalized
    end

    test "with an avatar" do
      user = TestHelpers.create_user()
      {:ok, invited_user} = Accounts.invite(user, %{email: "invitee@example.com"})

      {:ok, invited_user} =
        Accounts.finalize_invitation(invited_user.email_verification_token, %{
          first_name: "User",
          last_name: "Example",
          phone_number: "123-123-1234",
          avatar: %{path: "test/fixtures/test.png"},
          password: "password",
          password_confirmation: "password"
        })

      assert invited_user.avatar_extension == ".png"
      assert invited_user.avatar_key
    end

    test "failure" do
      user = TestHelpers.create_user()
      {:ok, invited_user} = Accounts.invite(user, %{email: "invitee@example.com"})

      {:error, changeset} =
        Accounts.finalize_invitation(invited_user.email_verification_token, %{
          first_name: "User",
          phone_number: "123-123-1234",
          password: "password",
          password_confirmation: "password"
        })

      assert changeset.errors[:last_name]
    end
  end

  describe "starting password reset" do
    test "starts reset" do
      user = TestHelpers.create_user()

      Accounts.start_password_reset(user.email)

      user = Repo.get(Accounts.User, user.id)
      assert_delivered_email(Emails.password_reset(user))
    end

    test "does not let you reset an invited user" do
      user = TestHelpers.create_invited_user()

      Accounts.start_password_reset(user.email)

      user = Repo.get(Accounts.User, user.id)
      refute_delivered_email(Emails.password_reset(user))
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

  describe "editing an account" do
    test "updated successfully" do
      user = TestHelpers.create_user()

      {:ok, updated_user} =
        Accounts.update(user, %{
          first_name: "Jonathan",
          last_name: "Smyth",
          phone_number: "321-321-4321",
          password: "password",
          password_confirmation: "password"
        })

      assert updated_user.first_name == "Jonathan"
      assert updated_user.last_name == "Smyth"
      assert updated_user.phone_number == "321-321-4321"
    end

    test "with an avatar" do
      user = TestHelpers.create_user()

      {:ok, updated_user} =
        Accounts.update(user, %{
          avatar: %{path: "test/fixtures/test.png"}
        })

      assert updated_user.avatar_extension == ".png"
      assert updated_user.avatar_key
    end

    test "sends a verification email if email changed" do
      user = TestHelpers.create_user()
      {:ok, user} = Accounts.verify_email(user.email_verification_token)

      {:ok, updated_user} =
        Accounts.update(user, %{
          email: "updated_user@example.com",
          password: "password",
          password_confirmation: "password"
        })

      assert updated_user.email_verification_token
      assert updated_user.email_verification_token != user.email_verification_token
      assert updated_user.email_verified_at == nil
      assert_delivered_email(Emails.verification_email(updated_user))
    end
  end
end
