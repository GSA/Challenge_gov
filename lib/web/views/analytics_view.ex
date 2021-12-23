defmodule Web.AnalyticsView do
  use Web, :view

  alias ChallengeGov.Reports.DapReports
  alias Web.SharedView

  def render_graph(data, opts \\ []) do
    type = Keyword.get(opts, :type, "bar")
    options = Keyword.get(opts, :options, %{})

    {:ok, data} = Jason.encode(data)
    {:ok, options} = Jason.encode(options)

    content_tag(:div, class: "analytics-graph-container") do
      content_tag(:canvas, "",
        class: "js-analytics-graph",
        data: [
          graph_type: type,
          graph_data: data,
          graph_options: options
        ]
      )
    end
  end
end
