import React from 'react'
import { SectionResources } from "./SectionResources"

export const HowToEnter = ({challenge}) => {
  return (
    <section className="challenge-tab container">
      <div className="challenge-tab__header">How to enter</div>
      <hr/>      
      <section className="card challenge-tab__content">
        <div className="card-body">
          {challenge.how_to_enter}
        </div>
      </section>
      <SectionResources challenge={challenge} section="how_to_enter" />
    </section>
  )
}
