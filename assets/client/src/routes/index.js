import App  from '../App'
import { DetailsPage } from '../pages/DetailsPage'

export const IndexRoutes = [
  {
    component: App,
    path: "/",
    exact: true
  },
  {
    component: App,
    path: "/challenges/archived",
    exact: true
  },
  {
    component: DetailsPage,
    path: "/challenge/:challengeId/:tab"
  },
  {
    component: DetailsPage,
    path: "/challenge/:challengeId"
  }
];
