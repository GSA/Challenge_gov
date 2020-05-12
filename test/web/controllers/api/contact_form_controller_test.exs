defmodule Web.Api.ContactFormControllerTest do
  use Web.ConnCase
  use Bamboo.Test

  alias ChallengeGov.Emails
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "sending an email through contact form" do
    test "successfully", %{conn: conn} do
      public_email = "user@example.com"
      body = "This is test contact form content"
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: user.id, poc_email: "poc@example.com"})

      params = %{
        "email" => public_email,
        "body" => body
      }

      conn = post(conn, Routes.api_contact_form_path(conn, :send_email, challenge.id), params)
      assert json_response(conn, 200)["message"] === "Your message has been received"
      assert_delivered_email(Emails.contact(challenge.poc_email, challenge, public_email, body))
      assert_delivered_email(Emails.contact_confirmation(public_email, challenge, body))
    end

    test "missing email", %{conn: conn} do
      body = "This is test contact form content"
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: user.id, poc_email: "poc@example.com"})

      params = %{
        "body" => body
      }

      conn = post(conn, Routes.api_contact_form_path(conn, :send_email, challenge.id), params)
      assert json_response(conn, 422)["errors"]["email"] === ["can't be blank"]
      assert_no_emails_delivered()
    end

    test "malformed email", %{conn: conn} do
      public_email = "userexample"
      body = "This is test contact form content"
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: user.id, poc_email: "poc@example.com"})

      params = %{
        "email" => public_email,
        "body" => body
      }

      conn = post(conn, Routes.api_contact_form_path(conn, :send_email, challenge.id), params)
      assert json_response(conn, 422)["errors"]["email"] === ["has invalid format"]
      assert_no_emails_delivered()
    end

    test "missing body", %{conn: conn} do
      public_email = "user@example.com"
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: user.id, poc_email: "poc@example.com"})

      params = %{
        "email" => public_email
      }

      conn = post(conn, Routes.api_contact_form_path(conn, :send_email, challenge.id), params)
      assert json_response(conn, 422)["errors"]["body"] === ["can't be blank"]
      assert_no_emails_delivered()
    end

    test "missing email and body", %{conn: conn} do
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: user.id, poc_email: "poc@example.com"})

      params = %{}

      conn = post(conn, Routes.api_contact_form_path(conn, :send_email, challenge.id), params)
      assert json_response(conn, 422)["errors"]["email"] === ["can't be blank"]
      assert json_response(conn, 422)["errors"]["body"] === ["can't be blank"]
      assert_no_emails_delivered()
    end
  end
end
