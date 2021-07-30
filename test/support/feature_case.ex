defmodule Web.FeatureCase do
  @moduledoc """
  ExUnit case for writing Wallaby feature tests

  Imports everything required along with some helper functions.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature

      import Wallaby.Query
      import Wallaby.Browser

      alias Web.Endpoint
      alias ChallengeGov.Repo
      alias Web.Router.Helpers, as: Routes

      @moduletag :integration
    end
  end
end
