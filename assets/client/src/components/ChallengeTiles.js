import React, { useState, useEffect } from 'react';
import moment from "moment";
import { ChallengeTile } from "./ChallengeTile";

const dateAddedOptions = [
  "Past Week",
  "Past Month",
  "Past 90 Days",
  "Past Year"
];

const lastDayOptions = [
  "Next Week",
  "Next Month",
  "Next 90 days",
  "Within Year"
];

const primaryChallengeTypeOptions = [
  "Software and apps",
  "Creative (Multimedia & Design)",
  "Ideas",
  "Technology demonstration and hardware",
  "Nominations",
  "Business plans",
  "Analytics, visualizations, algorithms",
  "Scientific",
];

export const ChallengeTiles = ({ data, loading, isArchived, selectedYear, handleYearChange }) => {
  const [primaryAgencyOptions, setPrimaryAgencyOptions] = useState([]);
  const [primaryAgency, setPrimaryAgency] = useState("");
  const [dateAdded, setDateAdded] = useState("");
  const [lastDay, setLastDay] = useState("");
  const [primaryChallengeType, setPrimaryChallengeType] = useState([]);
  const [keyword, setKeyword] = useState("");
  const [filteredChallenges, setFilteredChallenges] = useState([]);

  const handleFormSubmit = (event) => {
    event.preventDefault();
  };

  useEffect(() => {
    try {
      if (data && data.collection) {
        console.log(data);
        const agencies = Array.from(new Set(data.collection.map(challenge => challenge.agency_name)));
        setPrimaryAgencyOptions(agencies);

        let filtered = data.collection;

        if (primaryAgency) {
            filtered = filtered.filter(challenge => challenge.agency_name === primaryAgency);
        }

        if (dateAdded) {
          // Calculate fromDate based on dateAdded
          const now = moment();
          let fromDate = now.clone().subtract(1, "years"); // Default to "Past Year"

          switch (dateAdded) {
            case "Past Week":
              fromDate = now.clone().subtract(7, "days");
              break;
            case "Past Month":
              fromDate = now.clone().subtract(1, "months");
              break;
            case "Past 90 Days":
              fromDate = now.clone().subtract(90, "days");
              break;
            default:
              break;
          }

          // Filter challenges based on fromDate
          filtered = filtered.filter((challenge) => {
            const challengeDate = moment(challenge.inserted_at);
            return challengeDate.isBetween(fromDate, now, null, "[)");
          });
        }

        // Add filtering by primary challenge type
        if (primaryChallengeType.length > 0) {
          filtered = filtered.filter(challenge => primaryChallengeType.includes(challenge.primary_type));
        }

        if (lastDay) {
          const now = moment();
          let toDate;

          switch (lastDay) {
            case "Next Week":
              toDate = now.clone().add(7, "days");
              break;
            case "Next Month":
              toDate = now.clone().add(1, "months");
              break;
            case "Next 90 days":
              toDate = now.clone().add(90, "days");
              break;
            case "Within Year":
              toDate = now.clone().add(1, "years");
              break;
            default:
              toDate = now.clone().add(1, "years"); // Default to "Within Year"
              break;
          }

        // Filter challenges based on toDate
        filtered = filtered.filter((challenge) => {
            const challengeEnd = moment(challenge.end_date);
            return challengeEnd.isBetween(now, toDate, null, "[)");
          });
        }

        if (keyword) {
          const searchFields = ["title", "tagline", "brief_description"];
          filtered = filtered.filter((challenge) => {            
            for (const field of searchFields) {
              if (challenge[field] && challenge[field].toLowerCase().includes(keyword.toLowerCase())) {
                return true;
              }
            }

            return false;
          });
        }
        // implement other filters here
         setFilteredChallenges(filtered);
        
        console.log(filteredChallenges);  // this is the other modification
      }
    } catch (error) {
      console.error(error);
    }
  }, [primaryAgency, dateAdded, lastDay, primaryChallengeType, keyword, data]);

  const renderFilterDropdown = (

    label,
    options,
    selectedValue,
    handleChange,
    multiple = false,
    className = "",
    placeholder = "Select...",
    id // Add id parameter here
  ) => (
    <div className={`filter-module__item ${className}`}>
      <label className="filter-label" htmlFor={id}>{label}</label>
      <select
        id={id} // Add id attribute here
        className="filter-select"
        value={selectedValue}
        onChange={handleChange}
        multiple={multiple}
        aria-label={label}
      >
        <option value="">{placeholder}</option>
        {options.map((option, index) => (
          <option key={index} value={option}>
            {option}
          </option>
        ))}
      </select>
    </div>
  );

  const handleClearFilters = () => {
    setPrimaryAgency('');
    setDateAdded('');
    setLastDay('');
    setPrimaryChallengeType([]);
    setKeyword('');
  };  

  const renderHeader = () => (
    <h2 className="mb-5">
      {isArchived ? "Archived Challenges" : "Filter by open/active challenges."}
    </h2>
  );

  const renderSubHeader = () => isArchived ? <p>Challenges on this page are completed (closed to submissions) or only open to select winners of a previous competition phase.</p> : null;

  const renderYearFilter = () => {
    const startYear = 2010;
    const currentYear = moment().year();
    const range = (start, stop, step) => Array.from({ length: (stop - start) / step + 1 }, (_, i) => start + (i * step));

    const years = range(currentYear, startYear, -1);

    if (isArchived) {
      return (
        <div className="cards__year-filter">
          <div>Filter by year:</div>
          <select value={selectedYear} onChange={handleYearChange} aria-label="Filter archive by year">
            {
              years.map(year => {
                return <option key={year}>{year}</option>
              })
            }
          </select>
        </div>
      );
    }
  };

    const renderSortText = () => {
      if (isArchived) {
        return (
          <div className="container">
            <p className="card__section--sort">
              <i>Challenges sorted by those most recently closed to open submissions.</i>
            </p>
          </div>
        );
      } else {
        if (data.collection && data.collection.length >= 1) {
          return (
            <div className="container"> 
              <p className="card__section--sort">
                <i>
                  Challenges are sorted by those closing soonest. Results will update automatically as you filter. Press "Clear" to start a new search.
                </i>
              </p>
            </div>
          );
        }
      }
    };

  const renderChallengeTiles = () => {
    if (loading) {
      return (
        <div className="cards__loader-wrapper" aria-label="Loading active challenges">
          {[1, 2, 3, 4, 5, 6].map(numOfPlaceholders => (
            <div key={numOfPlaceholders}>
              <div className="card__loader--image"></div>
              <div className="card__loader--text line-1"></div>
              <div className="card__loader--text line-2"></div>
              <div className="card__loader--text line-3"></div>
            </div>
          ))}
        </div>
      )
    } else {
      if (filteredChallenges) {
        if (filteredChallenges.length > 0) {
          return (
            <div className="cards">
              {filteredChallenges.map(c => (
                <ChallengeTile key={c.id} challenge={c} />
              ))}
            </div>
          )
        }

        if (filteredChallenges.length === 0) {
          return (
            <div className="cards">
              <p className="cards__none">
                Please check back again soon!
              </p>
            </div>
          )
        }
      }
    }
  };

  const renderFilter = () => {
    if (!isArchived) {
      return (
        <form className={`filter-module full-width`} onSubmit={handleFormSubmit}>
          <div className="filter-dropdowns">
            <div className={`filter-module__item`}>
              <label className="filter-label" htmlFor="primaryAgency">Primary agency sponsor</label>
              <select
                id="primaryAgency"
                className="filter-select"
                value={primaryAgency}
                onChange={(event) => setPrimaryAgency(event.target.value)}
                aria-label="Primary agency sponsor"
              >
                <option value="">Select...</option>
                {primaryAgencyOptions.map((option, index) => (
                  <option key={index} value={option}>{option}</option>
                ))}
              </select>
            </div>
            {renderFilterDropdown('Date added', dateAddedOptions, dateAdded, (event) => setDateAdded(event.target.value), false, "", "Select...", "dateAdded")}
            {renderFilterDropdown('Last day to submit', lastDayOptions, lastDay, (event) => setLastDay(event.target.value), false, "", "Select...",
              "lastDay"
            )}
            {renderFilterDropdown(
              "Primary challenge type",
              primaryChallengeTypeOptions,
              primaryChallengeType,
              (event) => {
                const selectedOptions = Array.from(
                  event.target.selectedOptions,
                  (option) => option.value
                );
                setPrimaryChallengeType(selectedOptions);
              },
              true,
              "",
              "Multi select...",
              "primaryChallengeType" // Add id here
            )}
            <div className="filter-module__item keyword-item">
              <label className="filter-label" htmlFor="keyword">Keyword</label>
              <div className="keyword-input-wrapper">
                <input
                  id="keyword"
                  className="filter-input"
                  type="text"
                  placeholder="Keyword"
                  value={keyword}
                  onChange={(event) => setKeyword(event.target.value)}
                  aria-label="Keyword"
                />
                <button className="filter-button" onClick={handleClearFilters}>
                  Clear
                </button>
              </div>
            </div>
          </div>
        </form>
      );
    }
  };

  return (
    <>
      <a href="#main-content" className="sr-only sr-only-focusable">
        Skip to main content
      </a>
      <section
        id="active-challenges"
        className="cards__section"
        tabIndex="-1" // Add tabindex to bring the focus to the section when clicked on the skip link
      >
        <div className="container">
          {renderHeader()}
          {renderSubHeader()}
          {renderYearFilter()}
        </div>
        <div className="full-width-background">
          <div className="container">
            {renderFilter()}
          </div>
        </div>
        <div className="container">
          <div style={{ paddingBottom: "40px" }}>&nbsp;</div>
          {renderSortText()}
          {renderChallengeTiles()}
        </div>
      </section>
    </>
  );
};