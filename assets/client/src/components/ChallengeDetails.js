import React, { useContext, useEffect, useState } from 'react'
import moment from "moment"
import { stripHtml } from "string-strip-html";
import { Tooltip } from 'reactstrap'
import NumberFormat from 'react-number-format';

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
import { SocialSharingTooltip } from "../components/SocialSharingTooltip"
import { documentsForSection } from "../helpers/documentHelpers"
import { getPreviousPhase, getCurrentPhase, getNextPhase, phaseInPast, phaseIsCurrent, phaseInFuture, phaseNumber, isSinglePhase, formatDateTime, formatDate } from '../helpers/phaseHelpers'
import { ChallengeAnnouncement } from './ChallengeAnnouncement'
import { ApiUrlContext } from '../ApiUrlContext'

export const ChallengeDetails = ({challenge, challengePhases, preview, print, tab}) => {
  const { apiUrl, imageBase, bridgeApplyBlocked } = useContext(ApiUrlContext)
  const [followTooltipOpen, setFollowTooltipOpen] = useState(false)
  const [shareTooltipOpen, setShareTooltipOpen] = useState(false)

  const toggleFollowTooltip = () => setFollowTooltipOpen(!followTooltipOpen)
  const toggleShareTooltip = () => setShareTooltipOpen(!shareTooltipOpen)

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
      return <span className="details__btn"><i className="far fa-bookmark me-2"></i>Follow challenge ({ challenge.subscriber_count })</span>
    } else {
      return <span className="details__btn"><i className="far fa-bookmark me-2"></i>Follow challenge</span>
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
    } else if (challenge.how_to_enter_link) {
      applyButtonUrl = challenge.how_to_enter_link
    } else if (!preview) {
      applyButtonUrl = apiUrl + `/challenges/${challenge.id}/submissions/new`
    }

    let applyButtonText = []
    let applyButtonAttr = {href: applyButtonUrl}
    let applyButtonShow = "show"

    if (challenge.external_url) {
      applyButtonText = ["View on external website", <i key={1} className="fa fa-external-link-alt ms-3"></i>]
      applyButtonAttr.target = "_blank"
    } else if (challenge.how_to_enter_link) {
      applyButtonText = ["Apply on external website", <i key={1} className="fa fa-external-link-alt ms-3"></i>]
      applyButtonAttr.target = "_blank"
    } else {
      if (bridgeApplyBlocked && challenge.id <= 1288 && challenge.id != 1287) {
        // Hide apply button for challenges from the old platform
        applyButtonShow = "hide"
      } else if (!currentPhase && nextPhase) {
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
        submissionPeriodText += `Open until ${formatDateTime(phase.end_date)}`
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

  const renderInteractiveItems = () => {
    if (print != "true") {
      return (
        <>
          {renderApplyButton(challenge)}
          <div className="detail-section__split-btns">
            {!challenge.is_archived &&
              <div className="follow-btn" id="followChallengeButton">
                {renderFollowButton(challenge)}
                {renderFollowTooltip()}
              </div>
            }
            <div className="social-share-btn" id="shareChallengeButton">
              <span className="details__btn">
                <i className="fas fa-share-alt me-2"></i>
                Share
              </span>
              <SocialSharingTooltip shareTooltipOpen={shareTooltipOpen} toggleShareTooltip={toggleShareTooltip} challenge={challenge}/>
            </div>
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

  const renderChallengeLogo = () => {
    if (challenge.imported && challenge.sub_status === "archived" && challenge.logo.includes("challenge-logo-2_1")) {
      return (
        <img
          className="agency-logo"
          src={challenge.agency_logo}
          alt={`${challenge.agency_name} logo`}
          title="Challenge agency logo" />
      )
    }

    if (challenge.logo) {
      return (
        <img
        className={challenge.upload_logo ? "custom-logo" : "challenge-logo-details-page"}
        src={challenge.logo} alt={challenge.logo_alt_text}
        title="challenge logo"/>
      )
    }

    return (
      <img
        className="agency-logo"
        src={challenge.agency_logo}
        alt={`${challenge.agency_name} logo`}
        title="Challenge agency logo" />
    )
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
                {renderChallengeLogo()}
              </div>
            </div>
            <div className="detail-section">
              {renderInteractiveItems()}
              <div className="item">
                <p className="info-title">Submission period:</p>
                {submissionPeriod(challenge.phases)}
              </div>
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
                  <NumberFormat value={challenge.prize_total/100} displayType={'text'} thousandSeparator={true} prefix={'$'} />
                </div>
              }
              {!print &&
                <a className="follow__btn" href={apiUrl + `/public/previews/challenges?challenge=${challenge.uuid}&print=true`} target="_blank">
                  <span className="details__btn"><i className="fas fa-print me-2"></i>Print challenge</span>
                </a>
              }
            </div>
          </section>
        </section>
        <ChallengeTabs print={print} preview={preview} tab={tab}>
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
          { documentsForSection(challenge, "resources").length > 0 &&
            <div label="resources">
              <Resources challenge={challenge} />
            </div>
          }
          { (challenge.faq || documentsForSection(challenge, "faq").length > 0) &&
            <div label="faq">
              <FAQ challenge={challenge} print={print} />
            </div>
          }
          <div label="contact">
            <ContactForm challenge={challenge} preview={preview} />
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
