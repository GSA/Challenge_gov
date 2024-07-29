import React, {useEffect, useState} from 'react'
//import moment from 'moment'

import {phaseInPast, phaseIsCurrent, phaseInFuture} from "../../helpers/phaseHelpers"

export const AccordionSection = ({phase, index, section, children, print}) => {
  const [expanded, setExpanded] = useState();
  const [phaseClass, setPhaseClass] = useState();
  const [phaseText, setPhaseText] = useState();

  let localTimeZone = Intl.DateTimeFormat().resolvedOptions().timeZone; 

  let formatLocalDateTime = (date) => {

    let dateObj = new Date(date);  
    let month = (dateObj.getMonth() + 1).toString().padStart(2, '0'); 
    let day = dateObj.getDate().toString().padStart(2, '0');
    let year = dateObj.getFullYear().toString().slice(-2); 

    return `${month}/${day}/${year}`;
  }   

  useEffect(() => {
    setExpanded(() => {
      return phaseIsCurrent(phase)
    });
    setPhaseText(() => {
      if (phaseInPast(phase)) {
        return 'closed';
      } else if (phaseIsCurrent(phase)) {
        return `open until ${formatLocalDateTime(phase.end_date)}`;
      } else if (phaseInFuture(phase)) {
        return `opens on ${formatLocalDateTime(phase.start_date)}`;
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
        <button
          className="usa-accordion__button"
          aria-expanded={expanded}
          onClick={UpdateExpanded}
          tabIndex="0"
        >
          <span>{`Phase ${index + 1}${
            phase.title ? ': ' + phase.title : ''
          }`}</span>
          <span className={phaseClass}>{phaseText}</span>
        </button>
      </h2>
      <div        
        id={`a-${section}-${phase.id}`} 
        className="usa-accordion__content"
        hidden={!expanded && !print}
      >
        {children}
      </div>
    </div>
  );
}
