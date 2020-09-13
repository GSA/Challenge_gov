import React from 'react'
import moment from "moment"

import { ChallengeTabs } from "../components/ChallengeTabs"
import { Overview } from "../components/challenge_tabs/Overview"
import { Timeline } from "../components/challenge_tabs/Timeline"
import { Prizes } from "../components/challenge_tabs/Prizes"
import { Rules } from "../components/challenge_tabs/Rules"
import { Judging } from "../components/challenge_tabs/Judging"
import { HowToEnter } from "../components/challenge_tabs/HowToEnter"
import { Resources } from "../components/challenge_tabs/Resources"
import { FAQ } from "../components/challenge_tabs/FAQ"
import { ContactForm } from "../components/challenge_tabs/ContactForm"
import { Winners } from "../components/challenge_tabs/Winners"
import { documentsForSection } from "../helpers/documentHelpers"
import { getPreviousPhase, getCurrentPhase, getNextPhase, phaseInPast, phaseIsCurrent, phaseInFuture, phaseNumber, isSinglePhase, formatDateTime, formatDate } from '../helpers/phaseHelpers'
import { ChallengeAnnouncement } from './ChallengeAnnouncement'

export const ChallengeDetails = ({challenge, preview}) => {
  const renderEndDate = (date) => {
    const fiveDaysFromNow = moment().add(5,'d').utc().format()
    const withinFiveDays = moment(date).diff(fiveDaysFromNow) <= 0

    if (date >  moment().utc().format()) {
      return (
        <div className="item">
          <p className="info-title">Open until:</p>
          <p>{moment(date).local().format('L LT')}</p>
          { withinFiveDays && <p className="date-qualifier">Closing soon</p> }
        </div>
      )
    } else {
      return (
        <div className="item">
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

  const renderFollowButton = (challenge) => {
    if (challenge.gov_delivery_topic_subscribe_link) {
      return (
        <a href={preview ? null : challenge.gov_delivery_topic_subscribe_link}>
          <button className="follow-btn"><i className="far fa-bookmark mr-3"></i>Follow challenge</button>
            </a>
      )
    } else {
      return null
    }
  }

  const renderApplyButton = (challenge) => {
    // Button states
    // Disabled
    // - Before challenge is open
    // Enabled
    // - Challenge has started and is external
    // - Challenge has a current open to submission phase
    // Enabled to some (login button)
    // - Challenge not external
    // - Challenge is not in a current open phase
    // - Challenge is not in a current phase and next phase isn't open
    // Hidden
    // - Phase is not external and is closed
    let phases = challenge.phases
    let currentPhase = getCurrentPhase(phases)
    let nextPhase = getNextPhase(phases)

    let applyButtonUrl = null
    if (challenge.external_url) {
      applyButtonUrl = challenge.external_url
    } else if (!preview) {
      applyButtonUrl = `/challenges/${challenge.id}/solutions/new`
    }

    let applyButtonText = []
    let applyButtonAttr = {href: applyButtonUrl}
    let applyButtonShow = "show"

    if (challenge.external_url) {
      applyButtonText = ["View on external website", <i key={1} className="fa fa-external-link-alt ml-3"></i>]
      applyButtonAttr.target = "_blank"
    } else {
      if (!currentPhase && nextPhase) {
        applyButtonText = `Apply starting ${formatDate(nextPhase.start_date)}`
        applyButtonAttr.href = null
        applyButtonAttr.disabled = true
      } else if (!currentPhase && !nextPhase) {
        applyButtonShow = "hide"
      } else if (currentPhase) {
        if (currentPhase.open_to_submissions) {
          applyButtonText = "Apply for this challenge"
        } else {
          applyButtonShow = "login"
        }
      }
    }

    switch (applyButtonShow) {
      case "show": 
        return (
          <div className="detail-section__apply">
            <a {...applyButtonAttr}>
              <button className="apply-btn">{applyButtonText}</button>
            </a>
          </div>
        )
      case "login":
        return (
          <div className="detail-section__apply">
            <p><span>Winners of a previous phase <a {...applyButtonAttr}>login</a> to continue.</span></p>
          </div>
        )
      case "hide":
        return null
    }
  }

  const submissionPeriod = (phases) => {
    let previousPhase = getPreviousPhase(phases)
    let previousPhaseNumber = phaseNumber(phases, previousPhase)
    let currentPhase = getCurrentPhase(phases)
    let currentPhaseNumber = phaseNumber(phases, currentPhase)
    let nextPhase = getNextPhase(phases)
    let nextPhaseNumber = phaseNumber(phases, nextPhase)

    let submissionPeriodText = ""

    if (isSinglePhase(challenge)) {
      let phase = phases[0]
      if (phaseInFuture(phases[0])) {
        submissionPeriodText += `Coming soon / Open on ${formatDateTime(phase.start_date)}`
      } else if (phaseIsCurrent(phase)) {
        submissionPeriodText += `Opens until ${formatDateTime(phase.end_date)}`
      } else if (phaseInPast(phase)) {
        submissionPeriodText += `Closed on ${formatDateTime(phase.end_date)}`
      }
    } else {
      if (currentPhase) {
        submissionPeriodText += `Phase ${currentPhaseNumber} open until ${formatDateTime(currentPhase.end_date)}`
      } else {
        if (!previousPhase && nextPhase) {
          submissionPeriodText += `Phase ${nextPhaseNumber} opens on ${formatDateTime(nextPhase.start_date)}`
        }
        if (previousPhase && nextPhase) {
          submissionPeriodText += `Phase ${previousPhaseNumber} closed / Phase ${nextPhaseNumber} opens on ${formatDateTime(nextPhase.start_date)}`
        }
        if (previousPhase && !nextPhase) {
          submissionPeriodText += "Closed to submissions"
        }
      }
    }

    return submissionPeriodText
  }

  const renderWhoCanApply = (challenge) => {
    let phases = challenge.phases
    let previousPhase = getPreviousPhase(phases)
    let previousPhaseNumber = phaseNumber(phases, previousPhase)
    let currentPhase = getCurrentPhase(phases)
    let nextPhase = getNextPhase(phases)

    if (!currentPhase && !nextPhase) {
      return null
    } else if (currentPhase) {
      if (currentPhase.open_to_submissions) {
        return (
          <div className="item">
            <p className="info-title">Who can apply: </p>
            <span>Open to all eligible</span>
          </div>
        )
      } else {
        return (
          <div className="item">
            <p className="info-title">Who can apply: </p>
            <span>Phase {previousPhaseNumber} winners</span>
          </div>
        )
      }
    }
  }

  return (
    challenge ? (
      <div className="w-100">
        <section className="hero__wrapper" aria-label="Challenge overview details">
          <section className="hero__content">
            <ChallengeAnnouncement challenge={challenge} />
            <div className="main-section">
              <div className="main-section__text">
                { challenge.logo &&
                  <div className="logos">
                    <img
                      className="agency-logo"
                      src={challenge.agency_logo}
                      alt={`${challenge.agency_name} logo`}
                      title="Challenge agency logo" />
                    { (challenge.federal_partners.length > 0 && challenge.federal_partners[0].logo) &&
                      <img
                        className="agency-logo"
                        src={challenge.federal_partners[0].logo}
                        alt={`${challenge.federal_partners[0].name} logo`}
                        title="Federal partner agency logo"/>
                    }
                  </div>
                }
                <h4 className="title">{challenge.title}</h4>
                <h5 className="tagline">{challenge.tagline}</h5>
                <p className="brief_description">{challenge.brief_description}</p>
              </div>
              <div className="logo-container">
                { challenge.logo
                  ? <img
                      className="challenge-logo"
                      src={challenge.logo} alt="challenge logo"
                      title="challenge logo"/>
                  : <img
                      className="agency-logo"
                      src={challenge.agency_logo}
                      alt={`${challenge.agency_name} logo`}
                      title="Challenge agency logo" />
                }
              </div>
            </div>
            <div className="detail-section">
              {renderApplyButton(challenge)}
              <div className="detail-section__follow">
                <a href={preview ? null : `/challenges/${challenge.id}/save_challenge/new`}>
                  <button className="follow-btn"><i className="far fa-bookmark mr-3"></i>Save challenge</button>
                </a>
                {renderFollowButton(challenge)}
              </div>
              <div className="item">
                <p className="info-title">Submission period:</p>
                {submissionPeriod(challenge.phases)}
              </div>
              {renderWhoCanApply(challenge)}
              <div className="item">
                { challenge.types.length > 1
                  ? <p className="info-title">Challenge types:</p>
                  : <p className="info-title">Challenge type:</p>
                }
                {renderChallengeTypes(challenge.types)}
              </div>
              { !challenge.prize_total || challenge.prize_total != 0 &&
                <div className="item">
                  <p className="info-title">Total cash prizes:</p>
                  <p>{`$${challenge.prize_total.toLocaleString()}`}</p>
                </div>
              }
            </div>
          </section>
        </section>
        <ChallengeTabs>
          <div label="Overview">
            <Overview challenge={challenge} />
          </div>
          { challenge.events.length > 0 &&
            <div label="Timeline">
              <Timeline challenge={challenge} />
            </div> 
          }
          <div label="Prizes">
            <Prizes challenge={challenge} />
          </div>
          <div label="Rules">
            <Rules challenge={challenge} />
          </div>
          <div label="Judging">
            <Judging challenge={challenge} />
          </div>
          <div label="How to enter">
            <HowToEnter challenge={challenge} />
          </div>
          { challenge.supporting_documents.length > 0 &&
            <div label="Resources">
              <Resources challenge={challenge} />
            </div>
          }
          { (challenge.faq || documentsForSection(challenge, "faq") > 0) &&
            <div label="FAQ">
              <FAQ challenge={challenge} />
            </div>
          }
          <div label="Contact">
            <ContactForm preview={preview} />
          </div>
          <div label="Winners" disabled={!challenge.winner_information} >
            <Winners challenge={challenge} />
          </div>
        </ChallengeTabs>
      </div>
    ) : (
      <div className="card__loader--image"></div>
    )
  )
}
