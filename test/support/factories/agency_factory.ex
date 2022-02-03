defmodule ChallengeGov.AgencyFactory do
  @moduledoc """
  Allows us to create a `ChallengeGov.Agencies.Agency` in tests, seeds or manually in iex.
  """
  # credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
  defmacro __using__(_opts) do
    quote do
      def agency_factory(attrs) do
        acronym = attrs[:acronym] || "UMAD"
        created_on_import = attrs[:created_on_import] || false
        description = attrs[:description] || "Not My Money"
        deleted_at = attrs[:deleted_at] || nil
        name = attrs[:name] || "Congress"


        %ChallengeGov.Agencies.Agency{
          acronym: acronym,
          created_on_import: created_on_import,
          description: description,
          deleted_at: deleted_at,
          name: name
        }
      end
    end
  end
end
