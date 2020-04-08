import React, { useEffect, useState } from 'react'
import axios from 'axios'
import { useParams } from "react-router-dom";
import moment from 'moment'


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

  const renderDeadline = (date) => {
    const fiveDaysFromNow = moment().add(5,'d').utc().format()
    const withinFiveDays = moment(date).diff(fiveDaysFromNow) <= 0

    if (date >  moment().utc().format()) {
      return (
        <span>
          <p>{moment(date).local().format('L LT')}</p>
          { withinFiveDays && <p className="date-qualifier">Closing soon</p> }
        </span>
      )
    } else {
      return <p className="date-qualifier">Closed</p>
    }
  }

  const renderChallengeTypes = (types) => {
    return types.map((t, i) => {
      if (i == types.length - 1) {
        return <span key={i}>{t} </span>
      } else {
        return <span key={i}>{t}, </span>
      }
    })
  }

  return (
    <div>
      {currentChallenge &&
        <div>
          <section className="hero__wrapper">
            <section className="hero__content">
              <div className="hero__presentational">
                <div className="presentational-info">
                  <div className="logos">
                    <img
                      className="agency-logo"
                      src={currentChallenge.agency_logo}
                      alt={`${currentChallenge.agency_name} logo`} />
                    { currentChallenge.federal_partners[0].logo &&
                      <img
                        className="agency-logo"
                        src={currentChallenge.federal_partners[0].logo}
                        alt={`${currentChallenge.federal_partners[0].name} logo`} />
                    }
                  </div>
                  <h1 className="title">{currentChallenge.title}</h1>
                  <h3 className="tagline">{currentChallenge.tagline}</h3>
                  <p className="brief_description">{currentChallenge.brief_description}</p>
                </div>
                <div className="presentational-logo">
                  <img className="challenge-logo" src={currentChallenge.logo} alt={"challenge logo"}/>
                </div>
              </div>
              <div className="hero__info-section">
                <div className="hero__info-section__block">
                  { currentChallenge.end_date >  moment().utc().format() &&
                    <div className="item item__standard">
                      <p className="info-title">Submission Period:</p>
                      <p>open</p>
                    </div>
                  }
                  <div className="item item__standard">
                    <p className="info-title">Open Until:</p>
                    {renderDeadline(currentChallenge.end_date)}
                  </div>
                </div>
                <div className="hero__info-section__block">
                  <div className="item item__types">
                    <p className="info-title">Challenge Type(s):</p>
                    {renderChallengeTypes(currentChallenge.types)}
                  </div>
                  <div className="item item__standard">
                    <p className="info-title">Total Cash Prizes:</p>
                    <p>{`$${currentChallenge.prize_total}`}</p>
                  </div>
                </div>
              </div>
            </section>
          </section>
        </div>
      }
    </div>
  )
}
