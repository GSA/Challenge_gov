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
    // TODO: Temporary hiding of layout on chal details until the layout is moved
    $(".top-banner").hide()
    $(".help-section").hide()
    $(".footer").hide()

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
        <div className="item item__standard">
          <p className="info-title">Open until:</p>
          <p>{moment(date).local().format('L LT')}</p>
          { withinFiveDays && <p className="date-qualifier">Closing soon</p> }
        </div>
      )
    } else {
      return (
        <div className="item item__standard">
          <p className="info-title">Closed on:</p>
          <p>{moment(date).local().format('L LT')}</p>
        </div>
      )
    }
  }

  const renderChallengeTypes = (types) => {
    return types.map((t, i) => {
      if (i == types.length - 1) {
        return <p key={i}>{t} </p>
      } else {
        return <p key={i}>{t}, </p>
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
                  { currentChallenge.logo &&
                    <div className="logos">
                      <img
                        className="agency-logo"
                        src={currentChallenge.agency_logo}
                        alt={`${currentChallenge.agency_name} logo`}
                        title={currentChallenge.agency_name} />
                      { (currentChallenge.federal_partners.length > 0 && currentChallenge.federal_partners[0].logo) &&
                        <img
                          className="agency-logo"
                          src={currentChallenge.federal_partners[0].logo}
                          alt={`${currentChallenge.federal_partners[0].name} logo`}
                          title={currentChallenge.federal_partners[0].name} />
                      }
                    </div>
                  }
                  <h1 className="title">{currentChallenge.title}</h1>
                  <h3 className="tagline">{currentChallenge.tagline}</h3>
                  <p className="brief_description">{currentChallenge.brief_description}</p>
                </div>
                <div className="presentational-logo">
                  { currentChallenge.logo
                    ? <img
                        className="challenge-logo"
                        src={currentChallenge.logo} alt="challenge logo"
                        title="challenge logo"/>
                    : <img
                        className="agency-logo"
                        src={currentChallenge.agency_logo}
                        alt={`${currentChallenge.agency_name} logo`}
                        title={currentChallenge.agency_name} />
                  }
                </div>
              </div>
              <div className="hero__info-section">
                <div className="hero__info-section__block">
                    <div className="item item__standard">
                      <p className="info-title">Submission period:</p>
                      { currentChallenge.end_date >  moment().utc().format()
                        ? <p>Open</p>
                        : <p>Closed</p>
                      }
                    </div>
                  {renderDeadline(currentChallenge.end_date)}
                </div>
                <div className="hero__info-section__block">
                  <div className="item item__types">
                    { currentChallenge.types.length > 1
                      ? <p className="info-title">Challenge types:</p>
                      : <p className="info-title">Challenge type:</p>
                    }
                    {renderChallengeTypes(currentChallenge.types)}
                  </div>
                  { !currentChallenge.prize_total || currentChallenge.prize_total != 0 &&
                    <div className="item item__standard">
                      <p className="info-title">Total cash prizes:</p>
                      <p>{`$${currentChallenge.prize_total.toLocaleString()}`}</p>
                    </div>
                  }
                </div>
              </div>
            </section>
          </section>
        </div>
      }
    </div>
  )
}
