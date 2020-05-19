import React from 'react'
import { SectionResources } from "./SectionResources"

export const Judging = ({challenge}) => {
  return (
    <section className="challenge-tab container">
      <div className="challenge-tab__header">Judging</div>
      <hr/>      
      <section className="card challenge-tab__content">
        <div className="card-body">
          <div>{challenge.judging_criteria}</div>
        </div>
      </section>
      <SectionResources challenge={challenge} section="judging" />
    </section>
  )
}
