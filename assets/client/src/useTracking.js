import { useEffect } from 'react'
import { useHistory } from 'react-router-dom'

export const useTracking = (GA_MEASUREMENT_ID) => {

  useEffect(() => {
    const script = document.createElement("script");

    script.async = true;
    script.type = "text/javascript"
    script.id = GA_MEASUREMENT_ID
    script.src = "https://dap.digitalgov.gov/Universal-Federated-Analytics-Min.js";

    document.body.appendChild(script)
  },[])
}
