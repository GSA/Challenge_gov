import React, { useState, useEffect } from 'react';
import moment from 'moment';
import { ChallengeTile } from './ChallengeTile';

const dateAddedOptions = [
  'Past Week',
  'Past Month',
  'Past 90 Days',
  'Past Year',
];

const lastDayOptions = [
  'Next Week',
  'Next Month',
  'Next 90 days',
  'Within Year',
];

/*const primaryChallengeTypeOptions = [
  { display: 'Software and apps', value: 'Software and apps' },
  { display: 'Creative (Multimedia & Design)', value: 'Creative (Multimedia & Design)' },
  { display: 'Ideas', value: 'Ideas' },
  { display: 'Technology demonstration and hardware', value: 'Technology demonstration and hardware' },
  { display: 'Nominations', value: 'Nominations' },
  { display: 'Business Plans', value: 'Business plans' },
  { display: 'Analytics, visualizations, algorithms', value: 'Analytics, visualizations, algorithms' },
  { display: 'Scientific', value: 'Scientific' },
];*/

const primaryChallengeTypeOptions = [
  { display: 'Software & Apps', value: 'Software and apps' },
  { display: 'Creative', value: 'Creative (Multimedia & Design)' },
  { display: 'Ideas', value: 'Ideas' },
  { display: 'Technology & Hardware', value: 'Technology demonstration and hardware' },
  { display: 'Nominations', value: 'Nominations' },
  { display: 'Business Plans', value: 'Business plans' },
  { display: 'Analytics & Algorithms', value: 'Analytics, visualizations, algorithms' },
  { display: 'Scientific', value: 'Scientific' },
];

export const ChallengeTiles = ({ data, loading, isArchived, selectedYear, handleYearChange }) => {
  const [primaryAgencyOptions, setPrimaryAgencyOptions] = useState([]);
  const [primaryAgency, setPrimaryAgency] = useState('');
  const [dateAdded, setDateAdded] = useState('');
  const [lastDay, setLastDay] = useState('');
  const [primaryChallengeType, setPrimaryChallengeType] = useState([]);
  const [keyword, setKeyword] = useState('');
  const [filteredChallenges, setFilteredChallenges] = useState([]);

 useEffect(() => {
  try {
    if (data && data.collection) {
      const agencies = Array.from(new Set(data.collection.map(challenge => challenge.agency_name)));
      setPrimaryAgencyOptions(agencies);

      let filtered = data.collection;

      if (primaryAgency) {
        filtered = filtered.filter(challenge => challenge.agency_name === primaryAgency);
      }

      if (dateAdded) {
        const now = moment();
        let fromDate = now.clone().subtract(1, "years"); 

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

        filtered = filtered.filter((challenge) => {
          const challengeDate = moment(challenge.inserted_at);
          return challengeDate.isBetween(fromDate, now, null, "[)");
        });
      }

      /*if (primaryChallengeType.length > 0) {
        filtered = filtered.filter(challenge => {
          const displayType = primaryChallengeTypeOptions.find(option => option.value === challenge.primary_type)?.display;
          return primaryChallengeType.includes(displayType);
        });
      }*/

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
            toDate = now.clone().add(1, "years");
            break;
        }

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

      setFilteredChallenges(filtered);
      console.log(filteredChallenges); 
    }
  } catch (error) {
    console.error(error);
  }
}, [primaryAgency, dateAdded, lastDay, primaryChallengeType, keyword, data]);

  const styles ={
    smallWidth: {
      width: '100%' // or any desired width
    },
    largeWidth: {
      width: '100%' // or any desired width
    }
  };

  const handleClearFilters = (event) => {
    event.preventDefault();
    setPrimaryAgency('');
    setDateAdded('');
    setLastDay('');
    setPrimaryChallengeType([]);
    setKeyword('');
    setFilteredChallenges(data.collection);
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
          <select 
            className=""
            value={selectedYear} 
            onChange={handleYearChange} 
            aria-label="Filter archive by year"
          >
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
    const sortTextStyle = { textAlign: 'center', marginBottom: '20px' };

    if (isArchived) {
      return (
        <div style={sortTextStyle}>
          <p className="card__section--sort">
            <i>Challenges sorted by those most recently closed to open submissions.</i>
          </p>
        </div>
      );
    } else {
      if (data.collection && data.collection.length >= 1) {
        return (
          <div style={sortTextStyle}>
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
  
  return (
    <>
      <section id="active-challenges" className="cards__section" tabIndex="-1">
        <div className="container">
          {renderHeader()}
          {renderSubHeader()}
          {renderYearFilter()}
        </div>

        <div className="full-width-background">
          <div className="container">
            {renderSortText()}
            <form className="filter-module full-width">

              <div className="filter-dropdowns">

                <div className="filter-module__item">
                  <label className="filter-label" htmlFor="primaryAgency">Primary agency sponsor</label>
                  <select
                    id="primaryAgency"
                    className="usa-select"
                    value={primaryAgency}
                    onChange={(event) => setPrimaryAgency(event.target.value)}
                  >
                    <option value="">Select...</option>
                    {primaryAgencyOptions.map((option, index) => (
                      <option key={index} value={option}>{option}</option>
                    ))}
                  </select>
                </div>

                <div className="filter-module__item" style={styles.smallWidth}>
                  <label className="filter-label" htmlFor="dateAdded">Date added</label>
                  <select
                    id="dateAdded"
                    className="usa-select"
                    value={dateAdded}
                    onChange={(event) => setDateAdded(event.target.value)}
                  >
                    <option value="">Select...</option>
                    {dateAddedOptions.map((option, index) => (
                      <option key={index} value={option}>{option}</option>
                    ))}
                  </select>
                </div>

                <div className="filter-module__item">
                  <label className="filter-label" htmlFor="lastDay">Last day to submit</label>
                  <select
                    id="lastDay"
                    className="usa-select"
                    value={lastDay}
                    onChange={(event) => setLastDay(event.target.value)}
                  >
                    <option value="">Select...</option>
                    {lastDayOptions.map((option, index) => (
                      <option key={index} value={option}>{option}</option>
                    ))}
                  </select>
                </div>

                <div className="filter-module__item" style={styles.largeWidth}>
                  <label className="filter-label" htmlFor="primaryChallengeType">Primary challenge type</label>
                  <select
                    id="primaryChallengeType"
                    className="usa-select"
                    style={{ height: '150px'}} // or desired height
                    value={primaryChallengeType}
                    onChange={(event) => {
                      const selectedOptions = Array.from(
                        event.target.selectedOptions,
                        (option) => option.value
                      );
                      setPrimaryChallengeType(selectedOptions);
                    }}
                    multiple
                  >
                    <option value="">Select one or more...</option>
                    {primaryChallengeTypeOptions.map((option, index) => (
                      <option key={index} value={option.value}>{option.display}</option>
                    ))}
                  </select>
                </div>

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
                    />
                    <button className="usa-button" onClick={handleClearFilters} style={{ marginTop: '5px' }}>
                      Clear
                    </button>
                  </div>
                </div>

              </div>

            </form>
          </div>
        </div>

        <div className="container">
          {renderChallengeTiles()}
        </div>
      </section>
    </>
  );
}