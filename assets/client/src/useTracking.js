import { useEffect } from 'react'
import { useLocation } from 'react-router-dom'

export const useTracking = () => {

  // send pathname on SPA routed pages
  let location = useLocation()

  useEffect(() => {
      window.gas('send', 'pageview', location.pathname);
    },
    [location]
  )
}
