import App  from '../App'
import { DetailsPage } from '../pages/DetailsPage'

export const IndexRoutes = [
  {
    component: App,
    path: "/",
    exact: true
  },
  {
    component: DetailsPage,
    path: "/challenge/:challengeId"
  }
];
