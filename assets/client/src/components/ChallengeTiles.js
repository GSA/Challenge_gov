import React from 'react'
import { Link } from "react-router-dom";
import moment from "moment"
import { ChallengeTile } from "./ChallengeTile"

export const ChallengeTiles = ({data, loading}) => {

  const renderChallengeTiles = (challenges) => {
    // TODO: Temporary showing of layout on chal details until the layout is moved
    $(".top-banner").show()
    $(".help-section").show()
    $(".section-divider").show()
    $(".footer").show()

    if (challenges.collection) {

      if (challenges.collection.length > 0) {
        return challenges.collection.map(c => (
          <ChallengeTile key={c.id} challenge={c} />
        ))
      }

      if (challenges.collection.length == 0) {
        return (
          <p className="cards__none">
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
