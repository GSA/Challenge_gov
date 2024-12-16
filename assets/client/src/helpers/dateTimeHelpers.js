// TODO: Move date and timezone related functions to this file
// export const localDate = (datetime) => {

export const localDate = (datetime) => {

  let dateObj = new Date(datetime);
  let month = (dateObj.getMonth() + 1).toString().padStart(2, '0'); 
  let day = dateObj.getDate().toString().padStart(2, '0');
  let year = dateObj.getFullYear(); 

  return `${month}/${day}/${year}`;
}


export default {
  localDate
}