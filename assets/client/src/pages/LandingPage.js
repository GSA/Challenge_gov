import React, { useState, useEffect } from 'react'
import { ChallengeTiles } from '../components/ChallengeTiles'
import axios from 'axios'

export const LandingPage = () => {
  const [currentChallenges, setCurrentChallenges] = useState([])
  const [loadingState, setLoadingState] = useState(false)

  const base_url = window.location.origin

  useEffect(() => {
    setLoadingState(true)
    axios
      .get(base_url + "/api/challenges")
      .then(res => {
        setCurrentChallenges(res.data)
        setLoadingState(false)
      })
      .catch(e => {
        setLoadingState(false)
        console.log({e})
      })
  }, [])

  return (
    <div>
      <div>
        <ChallengeTiles data={currentChallenges} loading={loadingState}/>
      </div>
    </div>
  )
}
