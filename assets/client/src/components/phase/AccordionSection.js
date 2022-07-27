import React, {useEffect, useState} from 'react'
import moment from 'moment'

import {phaseInPast, phaseIsCurrent, phaseInFuture} from "../../helpers/phaseHelpers"

export const AccordionSection = ({phase, index, section, children, print}) => {
  const [expanded, setExpanded] = useState();
  const [phaseClass, setPhaseClass] = useState();
  const [phaseText, setPhaseText] = useState();
  useEffect(() => {
    setExpanded(() => {
      return phaseIsCurrent(phase)
    });
    setPhaseText(() => {
      if (phaseInPast(phase)) {
        return 'closed';
      } else if (phaseIsCurrent(phase)) {
        return `open until ${moment(phase.end_date).local().format("MM/DD/YY")}`;
      } else if (phaseInFuture(phase)) {
        return `opens on ${moment(phase.start_date).local().format("MM/DD/YY")}`;
      }
    });
    setPhaseClass(() => {
      if (phaseInPast(phase)) {
        return 'phase__text phase__text--closed';
      } else if (phaseIsCurrent(phase)) {
        return 'phase__text phase__text--open';
      } else if (phaseInFuture(phase)) {
        return 'phase__text';
      }
    });
  },[]);

  function UpdateExpanded() {
    setExpanded(()=>{
      return !expanded;
    });
  }

  return (
    <div>
      <h2 className="usa-accordion__heading">
        <div className="usa-accordion__button" aria-expanded={expanded}  onClick={UpdateExpanded}>
          <span>{`Phase ${index + 1}${phase.title ? ": " + phase.title : ""}`}</span>
          <span className={phaseClass}>{phaseText}</span>
        </div>
      </h2>
      <div id={`a${index}`} className="usa-accordion__content" hidden={!expanded && !print}>
        {children}
      </div>
    </div>
  )
}
