import React, {useState, useEffect} from 'react'
import { useParams } from "react-router-dom";
import axios from 'axios'
import { Button, Modal, ModalBody, ModalFooter } from 'reactstrap';

export const ContactForm = props => {
  const [email, setEmail] = useState("")
  const [body, setBody] = useState("")
  const [recaptchaToken, setRecaptchaToken] = useState("")
  const [errors, setErrors] = useState({})
  const [modalIsOpen, setIsOpen] = useState(false);

  let { challengeId } = useParams();
  const base_url = window.location.origin

  useEffect(() => {
    const recaptcha_key = document.getElementById("recaptcha-key").innerHTML

    if (recaptcha_key) {
      grecaptcha.ready(function() {
        grecaptcha.execute(recaptcha_key, {action: 'register'}).then(function(token) {
          setRecaptchaToken(token)
        });
      });
    }
  }, [])

  const handleSubmit = (e) => {
    e.preventDefault()

    axios
      .post(base_url + `/api/challenges/${challengeId}/contact_form`, { email, body, recaptchaToken })
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
      <section className="challenge-tab container">
        <div className="challenge-tab__header">Contact</div>
        <hr/>    
        <div className="p-5">
          <div className="mb-5">Have a question or comment about this challenge? Reach out by completing the form below.</div>
          <form className="usa-form" onSubmit={handleSubmit}>
            <div className="form-group">
              <input type="hidden" className={`form-control ${errors.recaptcha ? "is-invalid" : ""}`}/>
              {errors.recaptcha && <div className="invalid-feedback">{errors.recaptcha}</div> }
            </div>
            <div className="form-group">
              <label className="usa-label" htmlFor="contactEmail">Email address <span>*</span></label>
              <input id="contactEmail" className="usa-input" type="email" value={email} onChange={e => setEmail(e.target.value)} className={`form-control ${errors.email ? "is-invalid" : ""}`} required/>
              {errors.email && <div className="invalid-feedback">{errors.email}</div> }
            </div>
            <div className="form-group">
              <label className="usa-label" htmlFor="contactBody">Question or comment <span>*</span></label>
              <textarea id="contactBody" className="usa-textarea" value={body} onChange={e => setBody(e.target.value)} className={`form-control ${errors.body ? "is-invalid" : ""}`} required/>
              {errors.body && <div className="invalid-feedback">{errors.body}</div> }
            </div>
            <button className="contact-form__submit usa-button">Submit</button>
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
