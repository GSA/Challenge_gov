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

    test "given brief_description has html, we strip the html" do
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_challenge(
          %{
            user_id: user.id,
            brief_description: "<p>Test <b>brief</b> description from test</p>",
            description: "<h1>Test <i>description</i> for a challenge from test</h1>"
          },
          user
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      {:ok, content} = ExportView.format_content(challenge, "csv")

      flattened_content = List.flatten(content)

      assert Enum.member?(flattened_content, "Test brief description from test")
      refute Enum.member?(flattened_content, "<p>Test <b>brief</b> description from test</p>")
      assert Enum.member?(flattened_content, "Test description for a challenge from test")

      refute Enum.member?(
               flattened_content,
               "<h1>Test <i>description</i> for a challenge from test</h1>"
             )
    end
  end
end
