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
    }

    if (disabled) {
      tProps["tab-index"] = -1
    }

    return tProps
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
      return <i className="fas fa-award me-2"></i>
    }
  }

  const renderTabLabels = () => {
    return (
      <ul className="challenge-tabs__list">
        {React.Children.map(children, (child) => {
          if (child) {
            const { label, disabled } = child.props;
            const titleCasedLabel = label === "faq" ? label.toUpperCase() :
              label[0].toUpperCase() + label.slice(1).toLowerCase();
            return (
              <div {...tabProps(label, disabled)}
                  onClick={(e) => handleTabClick(label, disabled)}>
                {renderWinnersIcon(label, disabled)}
                {titleCasedLabel}
              </div>
            )
          }
        })}
      </ul>
    )
  }

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