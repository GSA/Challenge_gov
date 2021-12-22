import { Chart, BarController, BarElement, CategoryScale, LinearScale, Title, Tooltip, Legend } from "chart.js"

Chart.register(BarController, BarElement, CategoryScale, LinearScale, Title, Tooltip, Legend)

Chart.defaults.backgroundColor = "#0B4778"
Chart.defaults.maintainAspectRatio = false
Chart.defaults.plugins.legend.display = false
Chart.defaults.scales.category.ticks.autoSkip = false
Chart.defaults.scales.linear.ticks.precision = 0
Chart.defaults.plugins.tooltip.filter = (tooltipItems) => {
  return tooltipItems.parsed.y > 0
}

const analyticsGraphs = document.getElementsByClassName("js-analytics-graph")

Array.from(analyticsGraphs).forEach(el => {
  const graphType = el.dataset.graphType
  const graphData = JSON.parse(el.dataset.graphData)
  const graphOptions = JSON.parse(el.dataset.graphOptions)

  if (graphOptions.format == "currency"){
    graphOptions.scales = {
      y: {
        ticks: {
          callback: (value, index, values) => {
            return '$' + value.toLocaleString()
          }
        }
      }
    }
    graphOptions.plugins.tooltip = {
      callbacks: {
        label: function(context) {
          return '$' + context.parsed.y.toLocaleString()
        }
      }
    }
  }

  const config = {
    type: graphType,
    data: graphData,
    options: graphOptions
  }

  new Chart(el, config)
})