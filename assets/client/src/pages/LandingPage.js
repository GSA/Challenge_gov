import React, { useState, useEffect } from 'react'
import { ChallengeTile } from '../components/ChallengeTile'
import axios from 'axios'

export const LandingPage = () => {
  const [currentChallenges, setCurrentChallenges] = useState([])
  useEffect(() => {
    axios
      .get("http://localhost:4000/api/challenges")
      .then(res => {
        setCurrentChallenges(res.data)
      })
      .catch(e => {
        console.log({e})
      })
  }, [])

  return (
    <div>
      <ChallengeTile data={currentChallenges}/>
    </div>
  )
}
