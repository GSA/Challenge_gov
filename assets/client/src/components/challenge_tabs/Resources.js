import React from 'react'
import { SectionResources } from "./SectionResources"

export const Resources = ({challenge}) => {
  return (
    <section className="challenge-tab container">
      <SectionResources label="Additional resources" challenge={challenge} section="resources" />
    </section>
  )
}
