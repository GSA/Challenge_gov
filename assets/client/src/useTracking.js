import { useEffect, useState } from 'react'
import { useLocation } from 'react-router-dom'

export const useTracking = () => {

  // track if is initial mount
  const [isInitialMount, setIsInitialMount] = useState(true)

  useEffect(() => setIsInitialMount(false),[])


  // send pathname on SPA routed pages
  let location = useLocation()

  useEffect(() => {
      !isInitialMount && window.gas('send', 'pageview', location.pathname);
    },
    [location]
  )
}
