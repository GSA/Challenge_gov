import React, {useContext} from 'react'
import { ChallengeTab } from "../ChallengeTab"
import { ApiUrlContext } from '../../ApiUrlContext'

export const Winners = ({challenge, phaseWinners, print}) => {
  const { imageBase } = useContext(ApiUrlContext)

  const renderOverviewImage = (phaseWinner) => {
    if (phaseWinner.overview_image_path) {
      return (
        <img
          src={imageBase + phaseWinner.overview_image_path}
          alt="Phase Winner image"
          title="Phase Winner image"
          className="mt-3"
        />
      )
    }
  }

  const renderWinners = (winners) => {
    return winners.map(winner => {
      const {id, image_path, name, place_title} = winner
      return (
        <div key={id} className="d-flex flex-row align-items-center my-3">
          {image_path && <img src={imageBase + winner.image_path} alt="winner image" title="winner image" className="winner-image mr-3" />}
          {name && <p>{name}</p>}
          {place_title && <p>{` - ${place_title}`}</p>}
        </div>
      )
    })
  }

  const renderPhaseWinners = () => {
    console.log({phaseWinners})
    return Object.keys(phaseWinners).map(value => {
      const phaseWinner = phaseWinners[value]
      console.log({phaseWinner})
      return (
        <div key={phaseWinner.id} className="card">
          <div className="card-body ql-editor">
            {renderOverviewImage(phaseWinner)}
            <h1 className="my-3">{phaseWinner.phase_title}</h1>
            <div className="my-3" dangerouslySetInnerHTML={{ __html: phaseWinner.overview }}></div>
            {phaseWinner.winners && phaseWinner.winners.length >= 1 &&
              <div className="detail-section winner-grid">{renderWinners(phaseWinner.winners)}</div>
            }
          </div>
        </div>
      )
    })
  }

  return (
    <ChallengeTab label="Winners" downloadsLabel="Additional winner documents" section="winners" challenge={challenge} print={print}>
      {renderPhaseWinners()}
    </ChallengeTab>
  )
}
