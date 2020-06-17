import React from 'react';
import { SectionResources } from "./challenge_tabs/SectionResources"

export const ChallengeTab = ({label, downloadsLabel, section, challenge, wrapContent = true, children}) => {
  return (    
    <section className="challenge-tab container">
      <div className="challenge-tab__header">{label}</div>
      <hr/>
      <section className="card challenge-tab__content">
        {wrapContent ?  
          (
            <div className="card-body">
              {children}
            </div>
          ) : (
            <>
              {children}
            </>
          )
        }
      </section>
      <SectionResources challenge={challenge} section={section} label={downloadsLabel} />
    </section>
  )
}