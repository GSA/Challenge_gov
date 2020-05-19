import React from 'react'
import { SectionResources } from "./SectionResources"

export const Prizes = ({challenge}) => {
  return (
    <section className="challenge-tab container">
      <div className="challenge-tab__header">Prizes</div>
      <hr/>      
      <section className="card challenge-tab__content">
        <div className="card-body">
          <div>{challenge.prize_total}</div>
          <div>{challenge.prize_descriptions}</div>
          <div>{challenge.non_monetary_prizes}</div>
        </div>
      </section>
      <SectionResources challenge={challenge} section="prizes" />
    </section>
  )
}
