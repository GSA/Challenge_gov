import App  from '../App'
import { DetailsPage } from '../pages/DetailsPage'

export const IndexRoutes = [
  {
    component: App,
    path: "/challenges"
  },
  {
    component: DetailsPage,
    path: "/challenge/:challengeId"
  }
];
