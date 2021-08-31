defmodule ChallengeGov.ContactForms do
  @moduledoc """
  Context for contact forms
  """

  alias ChallengeGov.ContactForms.ContactForm
  alias ChallengeGov.Emails
  alias ChallengeGov.Mailer
  alias ChallengeGov.Recaptcha

  def send_email(challenge, params) do
    changeset =
      %ContactForm{}
      |> ContactForm.changeset(params)
      |> check_recaptcha(params)

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

  defp check_recaptcha(changeset, params) do
    recaptcha_token = Map.get(params, "recaptchaToken")

    case Recaptcha.valid_token?(recaptcha_token) do
      {:ok, _score} ->
        changeset

      {:error, reason} ->
        Ecto.Changeset.add_error(
          changeset,
          :recaptcha,
          "Invalid reCaptcha token (#{reason}). Please try again"
        )
    end
  end
end
