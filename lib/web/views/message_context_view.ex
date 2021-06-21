defmodule Web.MessageContextView do
  use Web, :view

  alias Web.FormView
  alias Web.SharedView

  def message_class(user, message) do
    if message.author_id == user.id do
      "message_center__message message_center__message--self"
    else
      "message_center__message"
    end
  end

  def display_audience(message_context) do
    message_context.audience
    |> Enum.map(&String.capitalize(&1))
    |> Enum.join(", ")
  end
end
