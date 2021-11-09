import React from 'react'

const NotFound = () => {
  return (
    <div className="container p-5">
      <h1>404 / Page not found</h1>
      <span>Please review the URL above and try again, or return to the homepage to search for <a href={location.pathname}>challenges</a>.</span>
    </div>
  )
}

export default NotFound