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

function formatPrizeAmount(num) {
  const formatNum = num / 100;
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(formatNum);
}

function escapeFieldForCsv(field) {
  // if the field includes commas, newline characters or double-quotes, then
  // - wrap them in quotes
  // - replace inner double quotes with a pair of double quotes
  // - replace newline characters with '\n'
  if (typeof field === 'string' && /[,\"\n]/.test(field)) {
    field = `"${field.replace(/"/g, '""').replace(/\n/g, '\\n')}"`;
  }
  return field;
}

// this function will replace each occurrence of these error characters with the correct one 
// we can add more such cases as we find them; this fix will handle most such issues
function cleanUpString(str) {
  if (!str || typeof str !== 'string') {
    return '';
  }

const replacements = [
    { from: /â€“/g, to: "-" },
    { from: /â€œ/g, to: "'" },
    { from: /â€˜/g, to: "'" },
    { from: /â€\u009D/g, to: "'" },
    { from: /â€\u0080/g, to: "'" },
    { from: /â€\u009C/g, to: "'" },
    { from: /â€\u008B/g, to: "'" },
    { from: /Ã©/g, to: "é" }
  ];
  replacements.forEach(({ from, to }) => {
      str = str.replace(from, to);
    });
    return str;
  }

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
      width: '100%'
    },
    largeWidth: {
      width: '100%'
    },
    exportContainer: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      maxWidth: '1200px',
      margin: '0 auto',
      padding: '5px 0 5px 0', // reduce the bottom padding here
    },
    exportTextContainer: {
      width: '50%',
      textAlign: 'left',
      /*marginLeft: '410px',*/
    },
    exportButtonContainer: {
      width: '50%',
      textAlign: 'right',
      marginRight: '10px',
    },
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

  const handleExportButtonClick = (event) => {
  event.preventDefault();

  if (filteredChallenges.length === 0) return;

  const csvData = filteredChallenges.map(challenge => {

    let formattedUrl = '';
    if (challenge.external_url) {
      formattedUrl = challenge.external_url;
    } else if (challenge.custom_url) {
      formattedUrl = `https://www.challenge.gov/?challenge=${challenge.custom_url}`;
    }

    return [
      `"${challenge.id}"`,
      `"${challenge.title}"`,
      `"${challenge.agency_name}"`,      
      `"${challenge.prize_total}"`,
      `"${challenge.start_date}"`,
      `"${challenge.end_date}"`,
      `"${challenge.primary_type}"`,
      `"${challenge.tagline}"`,
      `"${challenge.brief_description}"`,
      `${formattedUrl}` 
    ].join(',');
  }); 
    
   csvData.unshift([
      "Challenge ID",
      "Challenge Name",
      "Primary Agency Name",
      /*"Primary Sub-agency Name",*/
      "Prize Amount",
      "Challenge Start Date",
      "Challenge End Date",
      "Primary Challenge Type",
      "Tagline",
      "Short Description",
      "URL of Challenge Landing Page"
    ].join(','));

    const blob = new Blob([csvData.join('\n')], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');

    link.href = url;
    link.download = 'Challenges.csv';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    // Track this event
    window.gtag('event', 'challenge_filter_export', {
    'event_category': 'button_click',
    'event_label': 'Export',
    'value': 1 //  Google Analytics will increment the total value for the 'export_click' event by 1 each time the event is triggered
    });
  }  

  const renderHeader = () => (
    <h2 className="usa-margin-bottom-5">  
      {isArchived ? "Archived Challenges" : "Filter by open/active challenges"}
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
        <form className="usa-form" style={{display: 'flex', flexDirection: 'column', alignItems: 'center'}}>
          {renderSubHeader()}
          <label className="usa-label" htmlFor="options">Filter by year:</label>
          <select 
            className="usa-select"
            name="options" 
            id="options"
            value={selectedYear} 
            onChange={handleYearChange} 
            aria-label="Filter archive by year"
            style={{width: '80px'}} // Inline style for select
          >
            <option value>- Select -</option>
            {
              years.map(year => {
                return <option key={year} value={year}>{year}</option>
              })
            }
          </select>
        </form>
      </div>
    );
  }
};
  
  const renderSortText = () => {
  const sortTextStyle = { textAlign: 'center', marginBottom: '20px' };
  
  const sortedTextComponent = 
    <div style={sortTextStyle}>
      <p className="card__section--sort">
        <i>Results will update automatically as you filter. Press "Clear Search" to start a new search. Press "Export" to download a CSV file of your results.</i>
      </p>
    </div>;


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
                Challenges are sorted by those closing soonest. Results will update automatically as you filter. Press "Clear Filter" to start a new search.
              </i>
            </p>
          </div>
        );
      }
    } else {
      return (<>
        <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
          {renderSubHeader()}
        </div>
        <div style={{
          display: 'flex', 
          flexDirection: 'column',
          justifyContent: 'center', 
          alignItems: 'center',
          maxWidth: '1200px', 
          margin: '0 auto'
        }}>
          {sortedTextComponent}
        </div>
      </>);
    }
  };

  const renderExportButton = () => {
    return (
      <div className="exportContainer" style={styles.exportContainer}>
        <div className="exportTextContainer" style={styles.exportTextContainer}>
          <p>Challenges are sorted by those closing soonest.</p>
        </div>

        <div className="exportButtonContainer" style={styles.exportButtonContainer}>
          <button 
            className="usa-button usa-button--accent-warm" 
            onClick={handleExportButtonClick} 
            disabled={filteredChallenges.length === 0} 
            type="button"
          >
              Export
          </button>
        </div>
      </div>
    );
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
            <div className="cards" style={{ marginTop: 0 }}>
              {filteredChallenges.map(c => (
                <ChallengeTile key={c.id} challenge={c} />
              ))}
            </div>
          )
        }

        if (filteredChallenges && filteredChallenges.length === 0) {
          return (
            <div className="cards cardsOverride" style={{ marginTop: 0 }}>
              <p className="cards__none" style={{ textAlign: 'left', fontWeight: 'bold', color: 'green', margin: '0' }}>
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
          
          {renderYearFilter()}
        </div>

        <div className="full-width-background">
          <div className="container">
            {renderSortText()}
            <form className="filter-module full-width">
              <div className="filter-dropdowns" style={{ display: 'flex' }}>
                <div style={{ flex: 2, minWidth: '160px', marginRight: '10px'}}>
                  <div className="filter-module__item">
                    <label className="filter-label" htmlFor="primaryAgency">Primary agency sponsor</label>
                    <select
                      id="primaryAgency"
                      className="usa-select"
                      value={primaryAgency}
                      style={{ marginBottom: '10px' }} 
                      onChange={(event) => setPrimaryAgency(event.target.value)}
                    >
                      <option value="">Select...</option>
                      {primaryAgencyOptions.map((option, index) => (
                        <option key={index} value={option}>{option}</option>
                      ))}
                    </select>
                  </div>

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
                  
                  <div className="keyword-input-wrapper" 
                     style={{ 
                        display: 'flex', 
                        flexDirection: 'column', 
                        alignItems: 'flex-start', 
                        marginTop: '0', 
                        flexWrap: 'wrap', 
                        width: '100%', 
                     }}
                    >
                    <input
                      id="keyword"
                      className="usa-input"
                      type="text"
                      placeholder="Keyword"
                      value={keyword}
                      onChange={(event) => setKeyword(event.target.value)}
                      style={{ 
                          marginTop: '1px', 
                          width: '100%', 
                          marginBottom: '10px' 
                      }}
                    />
                    <button className="usa-button" 
                            onClick={handleClearFilters} 
                            style={{ 
                              marginTop: '1.5px', 
                              marginBottom: '10px', 
                              width: '100%' 
                            }}
                    >                    
                      Clear Filter
                    </button>

                    <button className="usa-button usa-button--accent-warm" 
                      onClick={handleExportButtonClick} 
                      style={{ 
                        marginTop: '1.5px', 
                        width: '100%' 
                      }}
                      disabled={filteredChallenges.length === 0}  // Make disabled when there's no output
                      type="button"
                    >
                      Export
                    </button>
                  </div>

                </div>
              </div>
            </form>
          </div>
        </div>

        <div className="container">
          {renderExportButton()}
          {renderChallengeTiles()}
        </div>

      </section>
    </>
  );
};