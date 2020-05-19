import React from 'react'

export const FAQ = ({challenge}) => {
  return (
    <section className="challenge-tab container">
      <div className="challenge-tab__header">Frequently asked questions</div>
      <hr/>      
      <section className="card challenge-tab__content">
        <div className="card-body">
          {challenge.faq}
        </div>
      </section>
    </section>
  )
}
