defmodule Web.AccessView do
  use Web, :view

  def recertification_heading_by_status(user) do
    case user.status == "decertified" do
      true ->
        [
          content_tag(:h4, "Your account must be recertified.", class: "mt-5"),
          content_tag(:p, "Request recertification by submitting the following:", class: "mt-5")
        ]

      false ->
        [
          content_tag(:p, "Request recertification by submitting the following:", class: "mt-5")
        ]
    end
  end

  def request_type_by_status(user) do
    case user.status do
      "decertified" ->
        "recertification"

      "deactivated" ->
        "reactivation"
    end
  end
end
