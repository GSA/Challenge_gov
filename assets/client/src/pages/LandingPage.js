import React, { useState, useEffect, useContext } from 'react'
import { ChallengeTiles } from '../components/ChallengeTiles'
import axios from 'axios'
import { ApiUrlContext } from '../ApiUrlContext'

export const LandingPage = () => {
  const [currentChallenges, setCurrentChallenges] = useState([])
  const [loadingState, setLoadingState] = useState(false)

  const { apiUrl } = useContext(ApiUrlContext)
  const challengesPath = window.location.hash === "#/challenges/archived" ? "/api/challenges?archived=true" : "/api/challenges"

  $(".usa-hero").show()

  useEffect(() => {
    setLoadingState(true)
    axios
      .get(apiUrl + challengesPath)
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
