import React, { useEffect, useState } from 'react'
import axios from 'axios'
import { useParams } from "react-router-dom";
import { ChallengeTile } from "../components/ChallengeTile"
import { ChallengeDetails } from '../components/ChallengeDetails';
import { PreviewBanner } from '../components/PreviewBanner';

export const PreviewPage = () => {
  const [currentChallenge, setCurrentChallenge] = useState()
  const [loadingState, setLoadingState] = useState(false)

  let { challengeId } = useParams();
  const base_url = window.location.origin

  useEffect(() => {
    let challengeApiPath = base_url + `/api/challenges/preview/${challengeId}`

    setLoadingState(true)
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
    <div className="py-5">
      <div className="row mb-5">
        <div className="col-md-4">
          <ChallengeTile challenge={currentChallenge} preview={true} loading={loadingState}/>
        </div>
        <div className="col-md-8">
          <PreviewBanner challenge={currentChallenge} />
        </div>
      </div>
      <div className="row">
        <div className="col">
          <ChallengeDetails challenge={currentChallenge} preview={true} loading={loadingState} />
        </div>
      </div>
    </div>
  )
}