import { useEffect } from 'react'
import { useLocation } from 'react-router-dom'
import ReactGA from 'react-ga'

export const useTracking = () => {

  // send pathname on SPA routed pages
  let location = useLocation()

  useEffect(() => {
      window.ga('set', 'page', location.pathname);
      window.ga('send', 'pageview');
    },
    [location]
  )
}
