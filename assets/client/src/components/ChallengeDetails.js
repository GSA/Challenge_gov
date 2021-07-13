import React, { useContext, useEffect, useState } from 'react'
import { Tooltip } from 'reactstrap'
import moment from "moment"
import { stripHtml } from "string-strip-html";
import {FacebookShareButton, LinkedinShareButton, TwitterShareButton, EmailShareButton} from "react-share";

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
import { ApiUrlContext } from '../ApiUrlContext'

export const ChallengeDetails = ({challenge, challengePhases, preview, print, tab}) => {
  const { apiUrl, imageBase } = useContext(ApiUrlContext)
  const [followTooltipOpen, setFollowTooltipOpen] = useState(false)
  const [shareTooltipOpen, setShareTooltipOpen] = useState(false)

  const toggleFollowTooltip = () => setFollowTooltipOpen(!followTooltipOpen)
  const toggleShareTooltip = () => setShareTooltipOpen(!shareTooltipOpen)

  const challengeURL = window.location.href

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

  const renderChallengeTypes = (types, other_type) => {
    if (types.every(v => v === "")) return

    return types.map((t, i) => {
      if (i == types.length - 1 && !challenge.other_type) {
        return <span key={i}>{`${t} `} </span>
      } else {
        return <span key={i}>{`${t}; `} </span>
      }
    })
  }

  const renderFollowButton = (challenge) => {
    if (challenge.subscriber_count > 0) {
      return <span className="details__btn"><i className="far fa-bookmark mr-3"></i>Follow challenge ({ challenge.subscriber_count })</span>
    } else {
      return <span className="details__btn"><i className="far fa-bookmark mr-3"></i>Follow challenge</span>
    }
  }

  const renderSubscribeButton = () => {
    if (challenge.gov_delivery_topic_subscribe_link) {
      return (
        <>
          <div className="follow-tooltip__section">
            <h4>Follow challenge as guest</h4>
            <p>Receive challenge updates to your email. No sign-in required</p>
            <a href={preview ? null : challenge.gov_delivery_topic_subscribe_link}>
              <button className="follow-tooltip__button">Follow challenge</button>
            </a>
          </div>
          <div className="follow-tooltip__divider">Or</div>
        </>
      )
    }
  }

  const renderSaveButton = () => {
    return (
      <div className="follow-tooltip__section">
        <h4>Save challenges to your account</h4>
        <p>Sign in to save a challenge and receive updates. Free login.gov account required.</p>
        <a href={preview ? null : apiUrl + `/challenges/${challenge.id}/save_challenge/new`}>
          <button className="follow-tooltip__button">Save challenge</button>
        </a>
      </div>
    )
  }

  const renderFollowTooltip = () => {
    return (
      <Tooltip placement="bottom" trigger="click" isOpen={followTooltipOpen} target="followChallengeButton" toggle={toggleFollowTooltip} autohide={false} className="follow-tooltip" innerClassName="follow-tooltip__inner" arrowClassName="follow-tooltip__arrow">
        {renderSubscribeButton()}
        {renderSaveButton()}
      </Tooltip>
    )
  }

  const renderShareTooltip = () => {
    return (
      <Tooltip placement="bottom" trigger="click" isOpen={shareTooltipOpen} target="shareChallengeButton" toggle={toggleShareTooltip} autohide={false} className="share-tooltip" innerClassName="share-tooltip__inner" arrowClassName="share-tooltip__arrow">
        <FacebookShareButton url={challengeURL} quote="Check out this awesome challenge" hashtag="#prizechallenge">
          <svg viewBox="0 0 64 64" width="32" height="32">
            <circle cx="32" cy="32" r="31" fill="#3b5998"></circle>
            <path d="M34.1,47V33.3h4.6l0.7-5.3h-5.3v-3.4c0-1.5,0.4-2.6,2.6-2.6l2.8,0v-4.8c-0.5-0.1-2.2-0.2-4.1-0.2 c-4.1,0-6.9,2.5-6.9,7V28H24v5.3h4.6V47H34.1z" fill="white"></path>
          </svg>
        </FacebookShareButton>
        <LinkedinShareButton url={challengeURL} title="Title of the shared page" summary="Description of the shared page" source="Source of the content (e.g. your website or application name)">
          <svg viewBox="0 0 64 64" width="32" height="32">
            <circle cx="32" cy="32" r="31" fill="#007fb1"></circle>
            <path d="M20.4,44h5.4V26.6h-5.4V44z M23.1,18c-1.7,0-3.1,1.4-3.1,3.1c0,1.7,1.4,3.1,3.1,3.1 c1.7,0,3.1-1.4,3.1-3.1C26.2,19.4,24.8,18,23.1,18z M39.5,26.2c-2.6,0-4.4,1.4-5.1,2.8h-0.1v-2.4h-5.2V44h5.4v-8.6 c0-2.3,0.4-4.5,3.2-4.5c2.8,0,2.8,2.6,2.8,4.6V44H46v-9.5C46,29.8,45,26.2,39.5,26.2z" fill="white"></path>
          </svg>
        </LinkedinShareButton>
        <TwitterShareButton url={challengeURL} title="Title of the shared page" via="ChallengeGov" hashtags={["prizechallenge", "innovation"]} related={["Accounts to recommend following", "?"]}>
          <svg viewBox="0 0 64 64" width="32" height="32">
            <circle cx="32" cy="32" r="31" fill="#00aced"></circle>
            <path d="M48,22.1c-1.2,0.5-2.4,0.9-3.8,1c1.4-0.8,2.4-2.1,2.9-3.6c-1.3,0.8-2.7,1.3-4.2,1.6 C41.7,19.8,40,19,38.2,19c-3.6,0-6.6,2.9-6.6,6.6c0,0.5,0.1,1,0.2,1.5c-5.5-0.3-10.3-2.9-13.5-6.9c-0.6,1-0.9,2.1-0.9,3.3 c0,2.3,1.2,4.3,2.9,5.5c-1.1,0-2.1-0.3-3-0.8c0,0,0,0.1,0,0.1c0,3.2,2.3,5.8,5.3,6.4c-0.6,0.1-1.1,0.2-1.7,0.2c-0.4,0-0.8,0-1.2-0.1 c0.8,2.6,3.3,4.5,6.1,4.6c-2.2,1.8-5.1,2.8-8.2,2.8c-0.5,0-1.1,0-1.6-0.1c2.9,1.9,6.4,2.9,10.1,2.9c12.1,0,18.7-10,18.7-18.7 c0-0.3,0-0.6,0-0.8C46,24.5,47.1,23.4,48,22.1z" fill="white"></path>
          </svg>
        </TwitterShareButton>
        <EmailShareButton url={challengeURL} subject="Subject of this email?" body="Can put a body message here" separator=" ">
          <svg viewBox="0 0 64 64" width="32" height="32">
            <circle cx="32" cy="32" r="31" fill="#7f7f7f"></circle>
            <path d="M17,22v20h30V22H17z M41.1,25L32,32.1L22.9,25H41.1z M20,39V26.6l12,9.3l12-9.3V39H20z" fill="white"></path>
          </svg>
        </EmailShareButton>
      </Tooltip>
    )
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
      applyButtonUrl = apiUrl + `/challenges/${challenge.id}/submissions/new`
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

  const renderInteractiveItems = () => {
    if (print != "true") {
      return (
        <>
          {renderApplyButton(challenge)}
          <div className="detail-section__follow" id="followChallengeButton">
            {renderFollowButton(challenge)}
            {renderFollowTooltip()}
          </div>
        </>
      )
    }
  }

  const disableWinners = () => {
    return challengePhases.every(phase => {
      const phaseWinner = phase.phase_winner
      if (!phaseWinner) {
        return true
      } else {
        return (
          (!phaseWinner.overview || phaseWinner.overview === "") &&
          !phaseWinner.overview_image_path &&
          (!!phaseWinner.winners && phaseWinner.winners.length === 0)
        )
      }
    })
  }

  return (
    (challenge && !!challengePhases) ? (
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
                      src={imageBase + challenge.agency_logo}
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
                <div dangerouslySetInnerHTML={{ __html: stripHtml(challenge.brief_description).result }}></div>
              </div>
              <div className="logo-container">
                { challenge.logo
                  ? <img
                      className={challenge.upload_logo ? "custom-logo" : "challenge-logo"}
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
              {renderInteractiveItems()}
              <div className="item">
                <p className="info-title">Submission period:</p>
                {submissionPeriod(challenge.phases)}
              </div>
              {renderWhoCanApply(challenge)}
              <div className="item">
                { (challenge.types.length > 1 && challenge.types.every(v => v != "")) || challenge.other_type
                  ? <><span className="info-title">Challenge types:</span><span>{`${challenge.primary_type}; `}</span></>
                  : <><span className="info-title">Challenge type:</span><span>{`${challenge.primary_type}`}</span></>
                }
                {renderChallengeTypes(challenge.types, challenge.other_type)}
                {challenge.other_type}
              </div>
              { !challenge.prize_total || challenge.prize_total != 0 &&
                <div className="item">
                  <p className="info-title">Total cash prizes:</p>
                  <p>{`$${challenge.prize_total.toLocaleString()}`}</p>
                </div>
              }
              {!print &&
                <>
                  <a className="follow__btn" href={apiUrl + `/public/previews/challenges/${challenge.uuid}?print=true`} target="_blank">
                    <span className="details__btn"><i className="fas fa-print mr-2"></i>Print challenge</span>
                  </a>
                  <div className="social-share details__btn">
                    <span className="social-share__btn" id="shareChallengeButton">
                      <i className="fas fa-share-alt"></i>
                      share
                    </span>
                    {renderShareTooltip()}
                  </div>
                </>
              }
            </div>
          </section>
        </section>
        <ChallengeTabs print={print} tab={tab}>
          <div label="overview">
            <Overview challenge={challenge} print={print} />
          </div>
          { challenge.events.length > 0 &&
            <div label="timeline">
              <Timeline challenge={challenge} print={print} />
            </div> 
          }
          <div label="prizes">
            <Prizes challenge={challenge} print={print} />
          </div>
          <div label="rules">
            <Rules challenge={challenge} print={print} />
          </div>
          <div label="judging">
            <Judging challenge={challenge} print={print} />
          </div>
          <div label="how to enter">
            <HowToEnter challenge={challenge} print={print} />
          </div>
          { challenge.supporting_documents.length > 0 &&
            <div label="resources">
              <Resources challenge={challenge} />
            </div>
          }
          { (challenge.faq || documentsForSection(challenge, "faq") > 0) &&
            <div label="faq">
              <FAQ challenge={challenge} print={print} />
            </div>
          }
          <div label="contact">
            <ContactForm preview={preview} />
          </div>
          <div label="winners" disabled={disableWinners()}>
            <Winners challenge={challenge} challengePhases={challengePhases} print={print} />
          </div>
        </ChallengeTabs>
      </div>
    ) : (
      <div className="card__loader--image"></div>
    )
  )
}
