defmodule ChallengeGov.ContactForms do
  @moduledoc """
  Context for contact forms
  """

  alias ChallengeGov.ContactForms.ContactForm
  alias ChallengeGov.Emails
  alias ChallengeGov.Mailer

  def send_email(challenge, params) do
    changeset = ContactForm.changeset(%ContactForm{}, params)

    if changeset.valid? do
      %{"email" => email, "body" => body} = params
      
      challenge.poc_email
      |> Emails.contact(challenge, email, body)
      |> Mailer.deliver_later()

      email
      |> Emails.contact_confirmation(challenge, body)
      |> Mailer.deliver_later()

      {:ok, changeset}
    else
      {:error, changeset}
    end
  end
end
