import React from 'react';
import { SectionResources } from "./challenge_tabs/SectionResources"

export const ChallengeTab = ({label, downloadsLabel, section, challenge, children}) => {
  return (    
    <section className="challenge-tab container">
      <div className="challenge-tab__header">{label}</div>
      <hr/>
      <section className="card challenge-tab__content">
        <div className="card-body">
          {children}
        </div>
      </section>
      <SectionResources challenge={challenge} section={section} label={downloadsLabel} />
    </section>
  )
}