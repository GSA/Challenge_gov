import React from 'react'

export const Winners = ({challenge}) => {
  return (
    <section className="challenge-tab container">
      <div className="challenge-tab__header">Timeline</div>
      <hr/>      
      <section className="card challenge-tab__content">
        <div className="card-body">
          <div>{challenge.winner_image}</div>
          <div>{challenge.winner_information}</div>
        </div>
      </section>
    </section>
  )
}
