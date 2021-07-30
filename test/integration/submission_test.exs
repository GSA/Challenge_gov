defmodule ChallengeGov.SubmissionTest do
  use Web.FeatureCase, async: true

  feature "example test", %{session: session} do
    session
    |> visit("/public")
    |> assert_text("Explore challenges")
  end
end
