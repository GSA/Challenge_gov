import React, {useState, useEffect} from 'react'
import { documentsForSection } from "../../helpers/documentHelpers"

export const SectionResources = ({label, section, challenge}) => {
  const [documents, setDocuments] = useState(challenge.supporting_documents)

  useEffect(() => {
    if (section) {
      setDocuments(documentsForSection(challenge, section))
    }
  }, [])

  const renderResources = () => {
    return (
      documents.map((document) => {
        return (
          <li>
            <a className="challenge-tab__resource" key={document.id} target="_blank" href={document.url}>{document.display_name}</a>
          </li>
        )
      })
    )
  }

  return (
    <>
      {(documents.length > 0) ? (
        <>
          <div className="challenge-tab__header">{label || "Additional documents"}</div>
          <hr/>
          <section className="card challenge-tab__resources">
            <ul>
              {renderResources()}
            </ul>
          </section>
        </>
      )
      : null}
    </>
  )
}
