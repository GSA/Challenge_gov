import React from 'react'
import { Link } from "react-router-dom";
import moment from "moment"

export const ChallengeTile = ({data, loading}) => {

  const renderChallengeTiles = (challenges) => {
    if (challenges.collection) {

      if (challenges.collection.length > 0) {
        return challenges.collection.map(c => (
            <div key={c.id} className="card">
              <Link to={`/challenge/${c.id}`} aria-label="View challenge details">
                <div className="image_wrapper">
                  <img src={c.logo} alt="Challenge logo" />
                </div>
                <div className="card__text-wrapper">
                  <p className="card__title test" aria-label="Challenge title">{c.title}</p>
                  <p className="card__agency-name" aria-label="Agency name">{c.agency_name}</p>
                  <p className="card__tagline" aria-label="Challenge tagline">{c.tagline}</p>
                  <p className="card__date">{moment(c.open_until).format("llll")}</p>
                </div>
              </Link>
            </div>
          )
        )
      }

      if (challenges.collection.length == 0) {
        return (
          <p>
            There are no current challenges. Please check back again soon!
          </p>
        )
      }
    }
  }

  return (
    <section id="active-challenges" className="cards__section">
      {loading
        ? (
          <div className="cards__loader-wrapper" aria-label="Loading active challenges">
            {[1,2,3,4,5,6].map(numOfPlaceholders => (
              <div key={numOfPlaceholders}>
                <div className="card__loader--image"></div>
                <div className="card__loader--text line-1"></div>
                <div className="card__loader--text line-2"></div>
                <div className="card__loader--text line-3"></div>
              </div>
            ))}
          </div>
        )
        : (
          <section className="cards__section">
            <h2>Active challenges</h2>
            {
              (data.collection && data.collection.length >= 1) &&
              <p className="card__section--sort">Challenges sorted by those closing soonest</p>
            }
            <div className="cards">
              {renderChallengeTiles(data)}
            </div>
          </section>
        )
      }
    </section>
  )
}
