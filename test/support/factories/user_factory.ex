defmodule ChallengeGov.UserFactory do
  @moduledoc """
  Allows us to create a `ChallengeGov.Accounts.User` in tests, seeds or manually in iex.
  """
  # credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
  defmacro __using__(_opts) do
    quote do
      def user_factory(attrs) do
        email = attrs[:email] || "#{Ecto.UUID.generate()}@example.com"
        first_name = attrs[:first_name] || "Tiny"
        last_name = attrs[:last_name] || "Tim"
        phone_number = attrs[:phone_number] || "5558675309"
        role = attrs[:role] || "solver"
        token = attrs[:token] || Ecto.UUID.generate()
        display = attrs[:display] || true
        terms_of_use = attrs[:terms_of_use] || DateTime.utc_now()
        privacy_guidelines = attrs[:privacy_guidelines] || DateTime.utc_now()
        agency = attrs[:agency] || build(:agency)
        status = attrs[:status] || "pending"
        active_session = attrs[:active_session] || true
        renewal_request = attrs[:renewal_request] || "hello"

        %ChallengeGov.Accounts.User{
          email: email,
          first_name: first_name,
          last_name: last_name,
          phone_number: phone_number,
          role: role,
          token: token,
          display: display,
          terms_of_use: terms_of_use,
          privacy_guidelines: privacy_guidelines,
          agency_id: agency.id,
          status: status,
          active_session: active_session,
          renewal_request: renewal_request,
        }
      end
    end
  end
end
