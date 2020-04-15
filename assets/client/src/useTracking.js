import { useEffect } from 'react'
import { useLocation } from 'react-router-dom'
import ReactGA from 'react-ga'

export const useTracking = (GA_MEASUREMENT_ID) => {

// send pathname on SPA routed pages
  let location = useLocation()

  useEffect(
    () => {
      ReactGA.ga('send', 'pageview', location.pathname);
    },
    [location]
  )

// inject script tag into all other pages
  useEffect(() => {
    const script = document.createElement("script");

    script.async = true;
    script.type = "text/javascript"
    script.id = GA_MEASUREMENT_ID
    script.src = "https://dap.digitalgov.gov/Universal-Federated-Analytics-Min.js?agency=GSA";

    document.body.appendChild(script)
  },[])
}
