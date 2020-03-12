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

  return (
    <div>
      {currentChallenge &&
        <div>
          <p>id: {currentChallenge.id}</p>
          <p>title: {currentChallenge.title}</p>
        </div>
      }
    </div>
  )
}
