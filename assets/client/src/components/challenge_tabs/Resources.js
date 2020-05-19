import React from 'react'
import { SectionResources } from "./SectionResources"

export const Resources = ({challenge}) => {
  return (
    <section className="challenge-tab container">
      <div className="challenge-tab__header">Resources</div>
      <hr/>     
      <SectionResources challenge={challenge} />
    </section>
  )
}
