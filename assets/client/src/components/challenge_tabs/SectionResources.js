import React, {useState, useEffect} from 'react'

export const SectionResources = ({label, section, challenge}) => {
  const [documents, setDocuments] = useState(challenge.supporting_documents)

  useEffect(() => {
    if (section) {
      setDocuments(documents.filter(document => document.section == section))
    }
  }, [])

  const renderResources = () => {
    return (
      documents.map((document) => {
        return (
          <a className="card challenge-tab__resource" key={document.id} target="_blank" href={document.url}>{document.name || document.display_name}</a>
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
          <section className="challenge-tab__resources">
            {renderResources()}
          </section>
        </>
      )
      : null}
    </>
  )
}
