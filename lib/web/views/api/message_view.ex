defmodule Web.Api.MessageView do
  use Web, :view

  alias Web.MessageContextView

  def render("create.json", %{user: user, message: message}) do
    %{
      author_id: message.author_id,
      content: message.content,
      class: MessageContextView.message_class(user, message)
    }
  end
end
