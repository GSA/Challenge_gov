import React, { useState } from 'react';
import { useHistory, useLocation, useRouteMatch, useParams } from "react-router-dom"

import queryString from 'query-string'

export const ChallengeTabs = (props) => {
  const {children, print, preview, tab} = props
  const [activeTab, setActiveTab] = useState(tab ?? "overview")
  const history = useHistory()
  const currentPath = useRouteMatch()
  const params = useParams()

  let location = useLocation()

  const handleTabClick = (label, disabled) => { 
    if (!disabled) {
      let queryParams = queryString.parse(location.search)
      queryParams.tab = label.toLowerCase()

      let pathRoot = preview ? "/public/previews/challenges?" : `${location.pathname}?`

      const path = pathRoot + queryString.stringify(queryParams)
      history.push(path)
      setActiveTab(label)
    }
  }

  const tabProps = (label, disabled) => {
    let tProps = {
      className: tabClasses(label, disabled),
      disabled: disabled,
      "aria-disabled": disabled,
      tabIndex: 0
    };

    if (disabled) {
      tProps["tabIndex"] = -1;
    }

    return tProps;
  }
  const tabClasses = (label, disabled) => {
    return "challenge-tabs__tab" + activeTabClasses(label) + disabledTabClasses(disabled)
  }
  const activeTabClasses = (label) => {
    return activeTab == label ? " challenge-tabs__tab--active" : ""
  }
  const disabledTabClasses = (disabled) => {
    return disabled ? " challenge-tabs__tab--disabled disabled" : ""
  }

  const renderWinnersIcon = (label, disabled) => {
  if (label === "winners" && !disabled) {
    return (
      <span className="details__btn">
        <svg className="usa-icon" aria-hidden="true" focusable="false" role="img" style={{fill: "#FA9441", height: "21px", width: "21px", position: "relative", top: "5px", right: "5px"}}>
          <title id="challenge-winners">ChallengeGov challenge winners</title>
          <use xlinkHref="/assets/uswds/img/emoji_events.svg#print"></use>
        </svg>Challenge Winners
      </span>
    )
  }
}

  const renderTabLabels = () => {
    return (
      <div className="challenge-tabs__list">
        {React.Children.map(children, (child) => {
          if (child) {
            const { label, disabled } = child.props;
            const titleCasedLabel = label === "faq" ? label.toUpperCase() :
              label[0].toUpperCase() + label.slice(1).toLowerCase();
            return (
              <div
                {...tabProps(label, disabled)}
                onClick={(e) => handleTabClick(label, disabled)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' || e.keyCode === 13) {
                    handleTabClick(label, disabled);
                  }
                }} // Add onKeyDown event listener
              >
                {renderWinnersIcon(label, disabled)}
                {titleCasedLabel}
              </div>
            );
          }
        })}
      </div>
    );
  };

  const renderTabContent = () => {
    return (
      <div className="challenge-tabs__content">
        {
          React.Children.map(children, (child) => {
            if (child) {
              const { label, children } = child.props;

              if (label !== activeTab && (!print || label === "Contact")) {
                return <div className="inactive-tabs">{children}</div>;
              }
              return children;
            }
          })
        }
      </div>
    )
  }

  return (
    <div className="challenge-tabs">
      {renderTabLabels()}
      {renderTabContent()}
    </div>
  )
}