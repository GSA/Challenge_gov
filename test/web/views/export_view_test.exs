defmodule Web.ExportViewTest do
  use Web.ConnCase, async: true

  alias ChallengeGov.Challenges
  alias TestHelpers.AccountHelpers
  alias TestHelpers.ChallengeHelpers
  alias Web.ExportView

  describe "export challenge" do
    test "success: as csv" do
      user = AccountHelpers.create_user()

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id}, user)

      {:ok, challenge} = Challenges.get(challenge.id)

      {:ok, content} = ExportView.format_content(challenge, "csv")

      csv_id =
        content
        |> Enum.at(1)
        |> Enum.at(0)
        |> String.to_integer()

      assert length(content) === 2
      assert csv_id === challenge.id
    end

    test "success: as json" do
      user = AccountHelpers.create_user()

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id}, user)

      {:ok, challenge} = Challenges.get(challenge.id)

      {:ok, content} = ExportView.format_content(challenge, "json")
      {:ok, content} = Jason.decode(content)

      assert content["id"] === challenge.id
    end

    test "failure: invalid format" do
      user = AccountHelpers.create_user()

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id}, user)

      assert ExportView.format_content(challenge, "invalid") === {:error, :invalid_format}
    end
  end
end
