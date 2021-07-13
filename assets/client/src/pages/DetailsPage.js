import React, { useEffect, useState, useContext } from 'react'
import axios from 'axios'
import { useParams } from "react-router-dom";

import { ChallengeDetails } from '../components/ChallengeDetails';
import { ApiUrlContext } from '../ApiUrlContext'

export const DetailsPage = (props) => {
  const [currentChallenge, setCurrentChallenge] = useState()
  const [challengePhases, setChallengePhases] = useState([])
  const [loadingState, setLoadingState] = useState(true)

  let { challengeId, tab } = useParams();
  const { apiUrl } = useContext(ApiUrlContext)

  useEffect(() => {
    setLoadingState(true)
    // TODO: Temporary hiding of layout on chal details until the layout is moved
    $(".top-banner").hide()
    $(".help-section").hide()
    $(".section-divider").hide()
    $(".footer").hide()
    $(".usa-hero").hide()

    let challengeApiPath = apiUrl + `/api/challenges/${challengeId}`
    axios
      .get(challengeApiPath)
      .then(res => {
        setCurrentChallenge(res.data)
        setChallengePhases(res.data.phases)
        setLoadingState(false)
      })
      .catch(e => {
        setLoadingState(false)
        console.log({e})
      })
  }, [])

  return (
    <div>
      {currentChallenge &&
        <ChallengeDetails challenge={currentChallenge} challengePhases={challengePhases} tab={tab}/>
      }
    </div>
  )
}
