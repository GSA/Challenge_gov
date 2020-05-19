import React from 'react'
import { SectionResources } from "./SectionResources"

export const Rules = ({challenge}) => {
  return (
    <section className="challenge-tab container">
      <div className="challenge-tab__header">Rules</div>
      <hr/>      
      <section className="card challenge-tab__content">
        <div className="card-body">
          {challenge.rules}
        </div>
      </section>
      <SectionResources challenge={challenge} section="rules" />
    </section>
  )
}
