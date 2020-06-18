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

  return (
    challenge ? (
      <div className="w-100">
        <section className="hero__wrapper" aria-label="Challenge overview details">
          <section className="hero__content">
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
              { challenge.end_date >  moment().utc().format() &&
                <>
                  <div className="detail-section__apply">
                    { challenge.external_url ? 
                    <a href={`${challenge.external_url}`} target="_blank">
                      <button className="apply-btn">Apply on external website <i className="fa fa-external-link-alt ml-3"></i></button>
                    </a>
                    :
                    <a href={`/challenges/${challenge.id}/solutions/new`}>
                      <button className="apply-btn">Apply for this challenge</button>
                    </a>
                    }
                  </div>
                  <div className="detail-section__follow">
                    <a href={`/challenges/${challenge.id}/save_challenge/new`}>
                      <button className="follow-btn"><i className="far fa-bookmark mr-3"></i>Follow challenge</button>
                    </a>
                  </div>
                </>
              }
              <div className="item">
                <p className="info-title">Submission period:</p>
                { challenge.end_date >  moment().utc().format()
                  ? <p>Open</p>
                  : <p>Closed</p>
                }
              </div>
              {renderEndDate(challenge.end_date)}
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
            <ContactForm />
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
