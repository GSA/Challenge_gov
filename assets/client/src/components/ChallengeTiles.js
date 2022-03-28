import React from 'react'
import { Link } from "react-router-dom";
import moment from "moment"
import { ChallengeTile } from "./ChallengeTile"

export const ChallengeTiles = ({data, loading, isArchived, selectedYear, handleYearChange}) => {

  const renderChallengeTiles = () => {
    if (loading) {
      return (
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
    } else {
      if (data.collection) {
        if (data.collection.length > 0) {
          return (
            <div className="cards">
              {data.collection.map(c => (
                  <ChallengeTile key={c.id} challenge={c} />
              ))}
            </div>
          )
        }

        if (data.collection.length == 0) {
          return (
            <div className="cards">
              <p className="cards__none">
                Please check back again soon!
              </p>
            </div>
          )
        }
      }
    }
  }

  const renderHeader = () => {
    return (
      <h2 className="mb-5">
        {isArchived ? "Archived Challenges" : "Active Challenges"}
      </h2>
    )
  }
  
  const renderSubHeader = () => {
    return isArchived ?
      (
        <p>
          Challenges on this page are completed (closed to submissions) or only open to select winners of a previous competition phase.
        </p>
      )
      : null
  }

  const renderYearFilter = () => {
    const startYear = 2010
    const currentYear = moment().year()
    const range = (start, stop, step) => Array.from({ length: (stop - start) / step + 1}, (_, i) => start + (i * step));

    const years = range(currentYear, startYear, -1)

    if (isArchived) {
      return (
        <div className="cards__year-filter">
          <div>Filter by year:</div>
          <select value={selectedYear} onChange={handleYearChange}>
            {
              years.map(year => {
                return <option key={year}>{year}</option>
              })
            }
          </select>
        </div>
      )
    } 
  }

  const renderSortText = () => {
    if (isArchived) {
      return <p className="card__section--sort"><i>Challenges sorted by those most recently closed to open submissions.</i></p>
    } else {
      if (data.collection && data.collection.length >= 1) {
        return <p className="card__section--sort"><i>Challenges are sorted by those closing soonest.</i></p>
      }
    }
  }

  return (
    <section id="active-challenges" className="cards__section">
      {renderHeader()}
      {renderSubHeader()}
      {renderYearFilter()}
      {renderSortText()}
      {renderChallengeTiles()}
    </section>
  )
}
  
() => {
  return (
    <>
      <div className="usa-grid usa-grid-full">
        <div className="usa-width-three-fourths">
          <h1>The top</h1>
          {[...Array(10)].map(i => (
            <div
              key={i}
              style={{
                height: '300px',
                background: 'whitesmoke',
                margin: '2em 0',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              Scroll down
            </div>
          ))}
          <va-back-to-top />
        </div>
      </div>
      <footer
        style={{
          height: '500px',
          display: 'flex',
          justifyContent: 'center',
          background: '#112E51',
          color: 'white',
        }}
      >
        The footer
      </footer>
    </>
  );
}
