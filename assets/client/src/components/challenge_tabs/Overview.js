import React from 'react'
import { SectionResources } from "./SectionResources"

export const Overview = ({challenge}) => {
  return (
    <section className="challenge-tab container">
      <div className="challenge-tab__header">Overview</div>
      <hr/>
      <section className="card challenge-tab__content">
        <div className="card-body">
          {challenge.description}
        </div>
      </section>
      <SectionResources challenge={challenge} section="general" />
    </section>
  )
}
