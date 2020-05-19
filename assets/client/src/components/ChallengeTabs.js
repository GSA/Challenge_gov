import React, { useState } from 'react';

export const ChallengeTabs = ({children}) => {
  const [activeTab, setActiveTab] = useState("Overview")

  const handleTabClick = (label, disabled) => { 
    if (!disabled) {
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

  return (
    <div className="challenge-tabs">
      <ul className="challenge-tabs__list">
        {React.Children.map(children, (child) => {
          if (child) {
            const { label, disabled } = child.props;
            
            return (
              <div {...tabProps(label, disabled)} 
                  onClick={(e) => handleTabClick(label, disabled)}>
                {label}
              </div>
            )
          }
        })}
      </ul>
      <div className="challenge-tabs__content">
        {
          React.Children.map(children, (child) => {
            if (child) {
              const { label, children } = child.props;

              if (label !== activeTab) return undefined;
              return children;
            }
          })
        }
      </div>
    </div>
  )
}