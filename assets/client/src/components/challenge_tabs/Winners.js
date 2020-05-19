import React from 'react'

export const Winners = ({challenge}) => {
  return (
    <section className="container py-5">
      <div>{challenge.winner_image}</div>
      <div>{challenge.winner_information}</div>
    </section>
  )
}
