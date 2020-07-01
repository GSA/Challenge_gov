import axios from 'axios'

$("select#challenge_agency_id").on("change", (e) => {
  addSubAgencyOptions(e.target.value)
})

function addSubAgencyOptions(agency_id) {
  axios
    .get(`/api/agencies/${agency_id}/sub_agencies`)
    .then((res) => {
      let sub_agencies = res.data
      let sub_agency_select = $("select#challenge_sub_agency_id")
      let sub_agency_options = sub_agencies.map((sub_agency) => {
        return `<option value=${sub_agency.id}>${sub_agency.name}</option>`
      })

      sub_agency_select.val(null)

      sub_agency_select.html(["<option value=''>Choose a sub-agency</option>"].concat(sub_agency_options))
    })
    .catch(e => {
      console.log("Error fetching sub agencies", e)
    })
}