import React from 'react'

export const SectionResources = ({challenge, section}) => {
  const renderResources = (documents, section) => {
    if (section) {
      documents = documents.filter(document => document.section == section)
    }

    return (
      documents.map((document) => {
        return (
          <a className="card challenge-tab__resource" key={document.id} href={document.url}>{document.name || document.display_name}</a>
        )
      })
    )
  }

  return (
    <>
      <div className="challenge-tab__header">Additional documents</div>
      <hr/>
      <section className="challenge-tab__resources">
        {renderResources(challenge.supporting_documents, section)}
      </section>
    </>
  )
}
