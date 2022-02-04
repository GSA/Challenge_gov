defmodule Web.SubmissionExportViewTest do
  use Web.ConnCase, async: true
  alias Web.SubmissionExportView

  describe "remove_improperly_encoded_characters/1" do
    test "returns appropriate characters when given improperly encoded characters" do
      improperly_encoded_list = ["&quote; â€œ &#x27; â€™ â€“  â€  &#x2F;  &#x2F;  &amp;  Â  "]

      result =
        SubmissionExportView.remove_improperly_encoded_characters(improperly_encoded_list, [])

      assert result == ["\" \" ' ' -  \"  /  /  &     "]
    end

    test "returns appropriate characters when given improperly encoded characters within other strings" do
      improperly_encoded_list = [
        "Hello&quote; Thereâ€œ I&#x27; think youâ€™re greatâ€“  â€  &#x2F;  &#x2F;  &amp;  Â  "
      ]

      result =
        SubmissionExportView.remove_improperly_encoded_characters(improperly_encoded_list, [])

      assert result == ["Hello\" There\" I' think you're great-  \"  /  /  &     "]
    end
  end
end
