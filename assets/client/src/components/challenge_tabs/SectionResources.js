import React from 'react'

export const SectionResources = ({challenge, section}) => {
  const renderResources = (documents, section) => {
    if (section) {
      documents = documents.filter(document => document.section == section)
    }

    return (
      documents.map((document) => {
        return (
          <div key={document.id}>
            <a href={document.url}>{document.name || document.display_name}</a>
          </div>
        )
      })
    )
  }

  return (
    <section className="card challenge-tab__resources">
      <div className="card-header">
        Downloads
      </div>
      <div className="card-body">
        {renderResources(challenge.supporting_documents, section)}
      </div>
    </section>
  )
}
