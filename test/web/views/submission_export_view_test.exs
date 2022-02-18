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
        "These are in the database and this test as improperly encoded characters.
         This is a double quote -> &quote;, This is a different double quote in a word -> Heâ€œllo!,
         This is a yet another double quote in a word -> Heâ€llo!,
         This is an apostrophe -> &#x27;, This is a different apostraphe in a word -> Heâ€™llo!,
         This is a hyphen -> â€“, This is a hyphen in a word -> Heâ€“llo!,
         This is a forward slash -> &#x2F;, This is a forward slash in a word -> He&#x2F;llo!,
         This is an ampersand -> &amp;, This is an ampersand in a word -> He&amp;llo!,
         This is a blank space (two technically) -> Â, This is a blank space in a word -> HeÂllo!
         --The End--"
      ]

      result =
        SubmissionExportView.remove_improperly_encoded_characters(improperly_encoded_list, [])

      assert result == [
               "These are in the database and this test as improperly encoded characters.
         This is a double quote -> \", This is a different double quote in a word -> He\"llo!,
         This is a yet another double quote in a word -> He\"llo!,
         This is an apostrophe -> ', This is a different apostraphe in a word -> He'llo!,
         This is a hyphen -> -, This is a hyphen in a word -> He-llo!,
         This is a forward slash -> /, This is a forward slash in a word -> He/llo!,
         This is an ampersand -> &, This is an ampersand in a word -> He&llo!,
         This is a blank space (two technically) ->  , This is a blank space in a word -> He llo!
         --The End--"
             ]
    end
  end

  describe "remove_html_markup/2" do
    test "removes all but the <a> tag" do
      data_to_scrub = [
        "<p>Hello</p>",
        "<a href='#'> My name is Carl</a>",
        "I <div>live</div> 'alone' <h1>with</h1>",
        "<b>27</b> <h6>Cats</h6>"
      ]

      assert SubmissionExportView.remove_html_markup(data_to_scrub, []) == [
               " Hello ",
               "<a href='#'> My name is Carl</a>",
               "I  live  'alone'  with ",
               " 27   Cats "
             ]
    end
  end
end
