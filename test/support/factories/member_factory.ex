defmodule ChallengeGov.MemberFactory do
  @moduledoc """
  Allows us to create a `ChallengeGov.Agencies.Member` in tests, seeds or manually in iex.
  """
  # credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
  defmacro __using__(_opts) do
    quote do
      def member_factory(attrs) do
        user = attrs[:user] || build(:user)
        agency = attrs[:agency] || build(:agency)

        %ChallengeGov.Agencies.Member{
          user: user,
          agency: agency
        }
      end
    end
  end
end
