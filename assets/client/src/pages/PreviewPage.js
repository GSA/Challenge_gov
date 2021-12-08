import React, { useEffect, useState, useRef } from 'react'
import axios from 'axios'
import queryString from 'query-string'
import { useParams, useLocation } from "react-router-dom";
import { ChallengeTile } from "../components/ChallengeTile"
import { ChallengeDetails } from '../components/ChallengeDetails';
import { PreviewBanner } from '../components/PreviewBanner';

export const PreviewPage = () => {
  const [currentChallenge, setCurrentChallenge] = useState()
  const [loadingState, setLoadingState] = useState(null)
  const [challengePhases, setChallengePhases] = useState([])

  const isMounted = useRef(false)

  let query = useLocation().search

  const { print, challenge, tab } = queryString.parse(query)

  const base_url = window.location.origin

  useEffect(() => {
    let challengeApiPath = base_url + `/api/challenges/preview/${challenge}`

    setLoadingState(true)
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

  const launchPrintDialogue = () => {
    if (loadingState === false) {
      setTimeout(() => {
        window.print()
      }, 1000);
    }
  }

  const renderPreviewItems = () => {
    if (print) {
      return (
        <>
          <div className="floating-tile">
            <ChallengeTile challenge={currentChallenge} preview={true} loading={loadingState}/>
          </div>
          <div className="row">
            <div className="col">
              <ChallengeDetails ref={print && launchPrintDialogue()} challenge={currentChallenge} challengePhases={challengePhases} preview={true} loading={loadingState} print={print} tab={tab} />
            </div>
          </div>
        </>
      )
    }

    if (currentChallenge && currentChallenge.external_url) {
      return (
        <div className="challenge-preview__top row mb-5">
          <div className="col-md-4">
            <ChallengeTile challenge={currentChallenge} preview={true} loading={loadingState}/>
          </div>
          <div className="col-md-8">
            <PreviewBanner challenge={currentChallenge} />
          </div>
        </div>
      )
    }

    return (
      <>
        <div className="challenge-preview__top row mb-5">
          <div className="col-md-4">
            <ChallengeTile challenge={currentChallenge} preview={true} loading={loadingState}/>
          </div>
          <div className="col-md-8">
            <PreviewBanner challenge={currentChallenge} />
          </div>
        </div>
        <div className="row">
          <div className="col">
            <ChallengeDetails ref={print && launchPrintDialogue()} challenge={currentChallenge} challengePhases={challengePhases} preview={true} loading={loadingState} print={print} tab={tab} />
          </div>
        </div>
      </>
    )
  }

  return (
    <div className="challenge-preview py-5">
      {renderPreviewItems()}
    </div>
  )
}
