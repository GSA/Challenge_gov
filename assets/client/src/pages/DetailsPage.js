import React, { useEffect, useState } from 'react'
import axios from 'axios'
import { useParams } from "react-router-dom";

import { ChallengeDetails } from '../components/ChallengeDetails';

export const DetailsPage = (props) => {
  const [currentChallenge, setCurrentChallenge] = useState()
  const [loadingState, setLoadingState] = useState(true)

  let { challengeId } = useParams();
  const base_url = window.location.origin

  useEffect(() => {
    // TODO: Temporary hiding of layout on chal details until the layout is moved
    $(".top-banner").hide()
    $(".help-section").hide()
    $(".footer").hide()

    let challengeApiPath = base_url + `/api/challenges/${challengeId}`
    axios
      .get(challengeApiPath)
      .then(res => {
        setCurrentChallenge(res.data)
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
        <ChallengeDetails challenge={currentChallenge} />
      }
    </div>
  )
}
