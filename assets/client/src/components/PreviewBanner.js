import React from 'react'
import moment from 'moment'

export const PreviewBanner = ({challenge}) => {
  const location = window.location.href.split('?')[0]

  return (
    challenge ? (
      <div className="challenge-preview__banner card p-5">
        <div className="card-body">
          <h1 className="card-title">Preview of challenge #{challenge.id}: {challenge.title}</h1>
          <br/>
          <div className="card-text">
            <div>
              You are viewing a preview of this challenge. 
              Any changes are not live and are not available to the public 
              until submitted on the "Review and submit" page by the Challenge Manager
            </div>
            <br/>
            <div>
              <span className="mr-3">Preview generated on {moment().format("llll")}</span>
              <a className="mr-3" href={window.location.href}>Refresh page</a>
              <a href={location + "?print=true"}>Print</a>
            </div> 
            <br/>
            <div>Link to share for internal agency review:</div>
            <a href={window.location.href}>{window.location.href}</a>
          </div>
        </div>
      </div>
    ) : (
      <div className="card__loader--image"></div>
    )
  )
}
