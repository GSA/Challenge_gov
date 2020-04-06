import React, { useEffect, useState } from 'react'
import axios from 'axios'
import { useParams } from "react-router-dom";


export const DetailsPage = () => {

  const [currentChallenge, setCurrentChallenge] = useState()
  const [loadingState, setLoadingState] = useState(false)

  let { challengeId } = useParams();
  const base_url = window.location.origin

  useEffect(() => {
    setLoadingState(true)
    axios
      .get(base_url + `/api/challenges/${challengeId}`)
      .then(res => {
        setCurrentChallenge(res.data)
        setLoadingState(false)
      })
      .catch(e => {
        setLoadingState(false)
        console.log({e})
      })
  }, [])

  console.log({currentChallenge})

  return (
    <div>
      {currentChallenge &&
        <div>
          <section className="hero__wrapper">
            <section className="hero__content">
              <div className="hero__presentational"></div>
              <div className="hero__info-section"></div>
            </section>
          </section>
        </div>
      }
    </div>
  )
}
