import React, { useState, useEffect } from 'react'
import { ChallengeTile } from '../components/ChallengeTile'
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
        <ChallengeTile data={currentChallenges} loading={loadingState}/>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 214">
            <defs>
              <filter x="-3.3%" y="-35.8%" width="106.5%" height="178.3%" filterUnits="objectBoundingBox" id="a">
                <feOffset dy="4" in="SourceAlpha" result="shadowOffsetOuter1"/>
                <feGaussianBlur stdDeviation="15" in="shadowOffsetOuter1" result="shadowBlurOuter1"/>
                <feColorMatrix values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.2 0" in="shadowBlurOuter1"/>
              </filter>
              <filter x="-2.1%" y="-12.5%" width="104.2%" height="150%" filterUnits="objectBoundingBox" id="d">
                <feOffset dy="15" in="SourceAlpha" result="shadowOffsetOuter1"/>
                <feGaussianBlur stdDeviation="7.5" in="shadowOffsetOuter1" result="shadowBlurOuter1"/>
                <feColorMatrix values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.2 0" in="shadowBlurOuter1"/>
              </filter>
              <path d="M0 3701h1440v86.862C1204.664 3809.954 966.664 3821 726 3821s-482.664-11.046-726-33.138V3701z" id="b"/>
              <path d="M0 3641h1440v86.862C1204.664 3749.954 966.664 3761 726 3761s-482.664-11.046-726-33.138V3641z" id="e"/>
              <linearGradient x1="0%" y1="50%" x2="154.83%" y2="50%" id="c">
                <stop stopColor="#0B4778" offset="0%"/>
                <stop stopColor="#009BC2" offset="100%"/>
              </linearGradient>
            </defs>
            <g fill="none" fillRule="evenodd">
              <path fill="#EFF6FB" d="M2-2412h1440V83H2z"/>
              <g transform="translate(0 -3641)">
                <use fill="#000" filter="url(#a)" xlinkHref="#b"/>
                <use fill="url(#c)" xlinkHref="#b"/>
              </g>
              <g transform="translate(0 -3641)">
                <use fill="#000" filter="url(#d)" xlinkHref="#e"/>
                <use fill="#EFF6FB" xlinkHref="#e"/>
              </g>
            </g>
          </svg>
      </div>
    </div>
  )
}
