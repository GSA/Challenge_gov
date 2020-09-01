import React, { useState, useEffect, useContext } from 'react'
import { ChallengeTiles } from '../components/ChallengeTiles'
import axios from 'axios'
import { ApiUrlContext } from '../ApiUrlContext'

export const LandingPage = () => {
  const [currentChallenges, setCurrentChallenges] = useState([])
  const [loadingState, setLoadingState] = useState(false)

  const { apiUrl } = useContext(ApiUrlContext)

  $(".usa-hero").show()

  useEffect(() => {
    setLoadingState(true)
    axios
      .get(apiUrl + "/api/challenges")
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
