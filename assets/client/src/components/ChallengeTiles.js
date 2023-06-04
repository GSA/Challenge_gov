import React, { useState, useEffect } from 'react';
import { Link } from "react-router-dom";
import moment from "moment";
import { ChallengeTile } from "./ChallengeTile";

const dateAddedOptions = [
  "Past Week",
  "Past Month",
  "Past 90 Days",
  "Past Year",
  //"Custom",   #todo
];

const lastDayOptions = [
  "Next Week",
  "Next Month",
  "Next 90 days",
  "Within Year",
  //"Custom",   #todo
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
  const [primaryChallengeType, setPrimaryChallengeType] = useState("");
  const [keyword, setKeyword] = useState("");
  const [filteredChallenges, setFilteredChallenges] = useState([]);

  useEffect(() => {
    if (data && data.collection) {
        const agencies = Array.from(new Set(data.collection.map(challenge => challenge.agency_name)));
        setPrimaryAgencyOptions(agencies);

        let filtered = data.collection;

        if (primaryAgency) {
            filtered = filtered.filter(challenge => challenge.agency_name === primaryAgency);
        }

        if (dateAdded) {
            const now = moment();
            let fromDate;
            switch(dateAdded) {
                case 'Past Week':
                    fromDate = now.clone().subtract(7, 'days');
                    break;
                case 'Past Month':
                    fromDate = now.clone().subtract(1, 'months');
                    break;
                case 'Past 90 Days':
                    fromDate = now.clone().subtract(90, 'days');
                    break;
                case 'Past Year':
                    fromDate = now.clone().subtract(1, 'years');
                    break;
                default:
                    fromDate = now;
            }

            filtered = filtered.filter(challenge => {
                const challengeDate = moment(challenge.start_date);
                return challengeDate.isBetween(fromDate, now, null, '[)');
            });
        }

        if (lastDay) {
            const now = moment();
            let toDate;
            switch(lastDay) {
                case 'Next Week':
                    toDate = now.clone().add(7, 'days');
                    break;
                case 'Next Month':
                    toDate = now.clone().add(1, 'months');
                    break;
                case 'Next 90 days':
                    toDate = now.clone().add(90, 'days');
                    break;
                case 'Within Year':
                    toDate = now.clone().add(1, 'years');
                    break;
                default:
                    toDate = now;
            }

            filtered = filtered.filter(challenge => {
                const challengeEndDate = moment(challenge.end_date);
                return challengeEndDate.isBetween(now, toDate, null, '[)');
            });
        }

        // Implement other filters here

        setFilteredChallenges(filtered);
      }
  }, [primaryAgency, dateAdded, lastDay, primaryChallengeType, keyword, data]);

  const renderFilterDropdown = (label, options, selectedValue, handleChange) => (
    <div>
      <label>{label}</label>
      <select value={selectedValue} onChange={handleChange}>
        <option value="">Select...</option>
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
    setPrimaryChallengeType('');
    setKeyword('');
  };

  const handleSearch = () => {
    const queryParams = new URLSearchParams();
    queryParams.append('primaryAgency', primaryAgency);
    queryParams.append('dateAdded', dateAdded);
    queryParams.append('lastDay', lastDay);
    queryParams.append('primaryChallengeType', primaryChallengeType);
    queryParams.append('keyword', keyword);

    fetch(`/api/challenges?${queryParams.toString()}`)
      .then(response => response.json())
      .then(data => {
        // Handle the API response data
      })
      .catch(error => {
        // Handle any errors
      });
  };

  const renderHeader = () => (
    <h2 className="mb-5">
      {isArchived ? "Archived Challenges" : "Active Challenges"}
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
        <div className="filter-module">
          <div className="filter-label">Filter by open/active challenges</div>
          <div className="filter-dropdowns">
            {renderFilterDropdown('Primary agency sponsor', primaryAgencyOptions, primaryAgency, (event) => setPrimaryAgency(event.target.value))}
            {renderFilterDropdown('Date added', dateAddedOptions, dateAdded, (event) => setDateAdded(event.target.value))}
            {renderFilterDropdown('Last day to submit', lastDayOptions, lastDay, (event) => setLastDay(event.target.value))}
            {renderFilterDropdown('Primary challenge type', primaryChallengeTypeOptions, primaryChallengeType, (event) => setPrimaryChallengeType(event.target.value))}
            <div>
              <label className="filter-label">Keyword or phrase</label>
              <input type="text" placeholder="Keyword or phrase" value={keyword} onChange={(event) => setKeyword(event.target.value)} />
            </div>
          </div>
          <div className="filter-buttons">
            <button onClick={handleSearch}>Search</button>
            <button onClick={handleClearFilters}>Clear</button>
          </div>
        </div>
      );
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

export default ChallengeTiles;
