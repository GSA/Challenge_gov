import { Chart, BarController, BarElement, CategoryScale, LinearScale, Title, Tooltip, Legend } from "chart.js"

Chart.register(BarController, BarElement, CategoryScale, LinearScale, Title, Tooltip, Legend)

Chart.defaults.plugins.legend.display = false
Chart.defaults.scales.category.ticks.autoSkip = false
Chart.defaults.scales.linear.ticks.precision = 0

const analyticsGraphs = document.getElementsByClassName("js-analytics-graph")

Array.from(analyticsGraphs).forEach(el => {
  const graphType = el.dataset.graphType
  const graphData = JSON.parse(el.dataset.graphData)
  const graphOptions = JSON.parse(el.dataset.graphOptions)

  const config = {
    type: graphType,
    data: graphData,
    options: graphOptions
  }

  new Chart(el, config)
})