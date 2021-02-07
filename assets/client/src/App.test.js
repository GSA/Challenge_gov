import React from 'react'
import { render } from '@testing-library/react'
import App from '../src/App'

test('Renders the active challenges page', () => {
  const { getByText } = render(<App />)
  const pageTitle = getByText(/Active Challenges/i)
  expect(pageTitle).toBeInTheDocument()
})
