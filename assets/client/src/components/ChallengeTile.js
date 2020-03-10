import React from 'react'

export const ChallengeTile = (data) => {

  return (
    <div>
      <section className="cards__section">
        <div className="cards">
          {data.data.collection &&
            data.data.collection.map(c => (
                <div key={c.id} className="card">
                  <a href="http://google.com" aria-label="View challenge details">
                    <div class="image_wrapper">
                      <img src={c.logo} alt="Challenge logo" />
                    </div>
                    <div className="card__text-wrapper">
                      <p className="card__title test" aria-label="Challenge title">{c.title}</p>
                      <p className="card__agency-name" aria-label="Agency name">{c.agency_name}</p>
                      <p className="card__tagline" aria-label="Challenge tagline">{c.tagline}</p>
                      <p className="card__date">{c.open_until}</p>
                    </div>
                  </a>
                </div>
              )
            )
          }
        </div>
      </section>
    </div>
  )
}
