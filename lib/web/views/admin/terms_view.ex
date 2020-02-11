defmodule Web.Admin.TermsView do
  use Web, :view

  alias Web.Admin.FormView

  def challenge_owner_fields(f, user) do
    if user.data.role == "challenge_owner" do
      [
        content_tag(:div, class: "input") do
          [
            label(f, :first_name, "First Name*", class: "label-text"),
            text_input(f, :first_name, required: true, placeholder: "First Name", class: "form-control fc-input")
          ]
        end,
        content_tag(:div, class: "input") do
          [
            label(f, :last_name, "Last Name*", class: "label-text"),
            text_input(f, :last_name, required: true, placeholder: "Last Name", class: "form-control fc-input")
          ]
        end,
        content_tag(:div, class: "input") do
          [
            label(f, :email, "Email Address*", class: "label-text"),
            text_input(f, :email, required: true, placeholder: "Email Address", class: "form-control fc-input")
          ]
        end,
        content_tag(:div, class: "input") do
          [
            label(f, :agency_id, "Agency Name*", class: "label-text"),
            text_input(f, :agency_id, required: true, placeholder: "Agency Name", class: "form-control fc-input")
          ]
        end,
      ]
    end
  end

end
