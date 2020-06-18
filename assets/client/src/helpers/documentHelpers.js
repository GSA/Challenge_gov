export const documentsForSection = (challenge, section) => {
  return challenge.supporting_documents.filter(document => document.section == section)
}

export default {
  documentsForSection
}