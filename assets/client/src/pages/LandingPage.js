import React, { useState, useEffect, useContext } from 'react'
import { ChallengeTiles } from '../components/ChallengeTiles'
import axios from 'axios'
import { ApiUrlContext } from '../ApiUrlContext'
import moment from "moment"

export const LandingPage = () => {
  const [currentChallenges, setCurrentChallenges] = useState([])
  const [loadingState, setLoadingState] = useState(false)
  const [isArchived] = useState(window.location.hash === "#/challenges/archived")
  const [selectedYear, setSelectedYear] = useState(moment().year())

  const { apiUrl } = useContext(ApiUrlContext)
  const challengesPath = isArchived ? "/api/challenges?archived=true" : "/api/challenges"

  $(".usa-hero").show()

  useEffect(() => {
    let yearFilter = isArchived ? `&filter[year]=${selectedYear}` : ""
    
    setLoadingState(true)
    axios
      .get(apiUrl + challengesPath + yearFilter)
      .then(res => {
        setCurrentChallenges(res.data)
        setLoadingState(false)
      })
      .catch(e => {
        setLoadingState(false)
        console.log({e})
      })
  }, [selectedYear])

  const handleYearChange = (e) => {
    setSelectedYear(e.target.value)
  }

  return (
    <div>
      <div>
        <ChallengeTiles data={currentChallenges} loading={loadingState} isArchived={isArchived} selectedYear={selectedYear} handleYearChange={handleYearChange} />
      </div>
    </div>
  )
}
