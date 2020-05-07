import React, {useState, useEffect} from 'react'
import { useParams } from "react-router-dom";
import axios from 'axios'
import { Button, Modal, ModalBody, ModalFooter } from 'reactstrap';

export const ContactForm = props => {
  const [email, setEmail] = useState("")
  const [body, setBody] = useState("")
  const [errors, setErrors] = useState({})
  const [modalIsOpen, setIsOpen] = useState(false);

  let { challengeId } = useParams();
  const base_url = window.location.origin

  const handleSubmit = (e) => {
    e.preventDefault()

    axios
      .post(base_url + `/api/challenges/${challengeId}/contact_form`, { email, body })
      .then(res => {
        setIsOpen(true);
        setEmail("")
        setBody("")
        setErrors({})
      })
      .catch(e => {
        let error = e.response.data.errors
        setErrors(error)
      })
  }

  const closeModal = () => {
    setIsOpen(false);
  }

  return (
    <>
      <section className="contact-form container py-5">
        <h3>Contact</h3>
        <hr/>
        <div className="p-5">
          <div className="mb-5">Have a question or comment about this challenge? Reach out by completing the form below.</div>
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label htmlFor="contactEmail">Email <span>*</span></label>
              <input id="contactEmail" type="email" value={email} onChange={e => setEmail(e.target.value)} className={`form-control ${errors.email ? "is-invalid" : ""}`} required/>
              {errors.email && <div className="invalid-feedback">{errors.email}</div> }
            </div>
            <div className="form-group">
              <label htmlFor="contactBody">Question or comment <span>*</span></label>
              <textarea id="contactBody" value={body} onChange={e => setBody(e.target.value)} className={`form-control ${errors.body ? "is-invalid" : ""}`} required/>
              {errors.body && <div className="invalid-feedback">{errors.body}</div> }
            </div>
            <button className="contact-form__submit">Submit</button>
          </form>
          <div className="contact-form__bottom">
            <div>This site is protected by reCAPTCHA and Google</div>
            <div>Privacy Policy and Terms of Service apply.</div>
          </div>
        </div>
      </section>

      <Modal isOpen={modalIsOpen}>
        <ModalBody>Your message has been received. Check your email for confirmation</ModalBody>
        <ModalFooter>
          <Button color="primary" onClick={closeModal}>Close</Button>
        </ModalFooter>
      </Modal>
    </>
  )
}
