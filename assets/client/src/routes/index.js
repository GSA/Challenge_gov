import App  from '../App'
import { DetailsPage } from '../pages/DetailsPage'

export const IndexRoutes = [
  {
    component: App,
    path: "/public/challenges"
  },
  {
    component: DetailsPage,
    path: "/public/challenge/:challengeId"
  }
];
