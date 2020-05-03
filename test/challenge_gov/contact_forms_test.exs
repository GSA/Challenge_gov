defmodule ChallengeGov.ContactFormsTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.ContactForms
  alias ChallengeGov.Emails
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "sending an email" do
    test "successfully" do
      public_email = "user@example.com"
      body = "This is test contact form content"
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: user.id, poc_email: "poc@example.com"})

      params = %{
        "email" => public_email,
        "body" => body
      }

      ContactForms.send_email(challenge, params)
      assert_delivered_email(Emails.contact(challenge.poc_email, challenge, public_email, body))
      assert_delivered_email(Emails.contact_confirmation(public_email, challenge, body))
    end

    test "missing email field" do
      body = "This is test contact form content"
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      params = %{
        "body" => body
      }

      {:error, changeset} = ContactForms.send_email(challenge, params)
      assert changeset.errors[:email]
      assert_no_emails_delivered()
    end

    test "malformed email field" do
      public_email = "userexample"
      body = "This is test contact form content"
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      params = %{
        "email" => public_email,
        "body" => body
      }

      {:error, changeset} = ContactForms.send_email(challenge, params)
      assert changeset.errors[:email]
      assert_no_emails_delivered()
    end

    test "missing body field" do
      public_email = "user@example.com"
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      params = %{
        "email" => public_email
      }

      {:error, changeset} = ContactForms.send_email(challenge, params)
      assert changeset.errors[:body]
      assert_no_emails_delivered()
    end
  end
end
