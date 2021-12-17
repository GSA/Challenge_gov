defmodule Web.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      alias Web.Router.Helpers, as: Routes
      alias ChallengeGov.TestHelpers

      # The default endpoint for testing
      @endpoint Web.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ChallengeGov.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(ChallengeGov.Repo, {:shared, self()})
    end

    # TODO: Fix test failures due to changes in session_timeout code by adding one globally
    # Possibly refactor this later to be used in more specific tests or a test helper
    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Test.init_test_session(
        session_timeout_at:
          Web.SessionController.new_session_timeout_at(ChallengeGov.Security.timeout_interval())
      )

    {:ok, conn: conn}
  end
end
