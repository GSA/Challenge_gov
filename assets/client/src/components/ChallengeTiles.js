import React, { useState } from 'react';
import { Link } from "react-router-dom";
import moment from "moment";
import { ChallengeTile } from "./ChallengeTile";

const primaryAgencyOptions = [
  // Populate this array with the options for Primary Agency Sponsor
];

const dateAddedOptions = [
  "Past Week",
  "Past Month",
  "Past 90 Days",
  "Past Year",
  "Custom",
];

const lastDayOptions = [
  "Next Week",
  "Next Month",
  "Next 90 days",
  "Within Year",
  "Custom",
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
  // Add state variables and event handlers for filters
  const [primaryAgency, setPrimaryAgency] = useState("");
  const [dateAdded, setDateAdded] = useState("");
  const [lastDay, setLastDay] = useState("");
  const [primaryChallengeType, setPrimaryChallengeType] = useState("");
  const [keyword, setKeyword] = useState("");

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
      if (data.collection) {
        if (data.collection.length > 0) {
          return (
            <div className="cards">
              {data.collection.map(c => (
                <ChallengeTile key={c.id} challenge={c} />
              ))}
            </div>
          )
        }

        if (data.collection.length == 0) {
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

  // Render filter dropdowns
  const renderFilterDropdown = (options, selectedValue, handleChange) => (
    <select value={selectedValue} onChange={handleChange}>
      <option value="">Select...</option>
      {options.map((option, index) => (
        <option key={index} value={option}>
          {option}
        </option>
      ))}
    </select>
  );

  // Add filter UI elements in the component
  const renderFilter = () => {
    if (!isArchived) {
      return (
        <div className="filter-module">
          <div className="filter-label">Filter by open/active challenges</div>
          <div className="filter-dropdowns">
            {renderFilterDropdown(primaryAgencyOptions, primaryAgency, (event) => setPrimaryAgency(event.target.value))}
            {renderFilterDropdown(dateAddedOptions, dateAdded, (event) => setDateAdded(event.target.value))}
            {renderFilterDropdown(lastDayOptions, lastDay, (event) => setLastDay(event.target.value))}
            {renderFilterDropdown(primaryChallengeTypeOptions, primaryChallengeType, (event) => setPrimaryChallengeType(event.target.value))}
            <input type="text" placeholder="Keyword or phrase" value={keyword} onChange={(event) => setKeyword(event.target.value)} />
          </div>
          <div className="filter-buttons">
            <button onClick={handleSearch}>Search</button>
            <button onClick={handleClearFilters}>Clear</button>
          </div>
        </div>
      );
    }
  };

  // Add clearing functionality for filtering options
  const handleClearFilters = () => {
    setPrimaryAgency('');
    setDateAdded('');
    setLastDay('');
    setPrimaryChallengeType('');
    setKeyword('');

    // Reset the challenges list as needed
  };

  // Fetch and display the challenges based on the selected filter options
  const handleSearch = () => {
    // Construct the query string with the selected filter values
    const queryParams = new URLSearchParams();
    queryParams.append('primaryAgency', primaryAgency);
    queryParams.append('dateAdded', dateAdded);
    queryParams.append('lastDay', lastDay);
    queryParams.append('primaryChallengeType', primaryChallengeType);
    queryParams.append('keyword', keyword);
    
    // Make the API request with the constructed query string
    // to-do: Need to see about using Axios rather than fetch for the API request
    fetch(`/api/challenges?${queryParams.toString()}`)
      .then(response => response.json())
      .then(data => {
        // Handle the API response data
      })
      .catch(error => {
        // Handle any errors
      });
  };

  const renderHeader = () => {
    return (
      <h2 className="mb-5">
        {isArchived ? "Archived Challenges" : "Active Challenges"}
      </h2>
    )
  };

  const renderSubHeader = () => {
    return isArchived ?
      (
        <p>
          Challenges on this page are completed (closed to submissions) or only open to select winners of a previous competition phase.
        </p>
      )
      : null;
  };

  const renderYearFilter = () => {
    const startYear = 2010;
    const currentYear = moment().year();
    const range = (start, stop, step) => Array.from({ length: (stop - start) / step + 1 }, (_, i) => start + (i * step));

    const years = range(currentYear, startYear, -1);

    if (isArchived) {
      return (
        <div className="cards__year-filter">
          <div>Filter by year:</div>
          <select value={selectedYear} onChange={handleYearChange}>
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
      return <p className="card__section--sort"><i>Challenges sorted by those most recently closed to open submissions.</i></p>;
    } else {
      if (data.collection && data.collection.length >= 1) {
        return <p className="card__section--sort"><i>Challenges are sorted by those closing soonest.</i></p>;
      }
    }
  };

  return (
    <>
      <section id="active-challenges" className="cards__section">
        {renderHeader()}
        {renderSubHeader()}
        {renderYearFilter()}
        {renderFilter()}
        {renderSortText()}
        {renderChallengeTiles()}
      </section>
    </>
  );
};