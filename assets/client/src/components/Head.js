import {Helmet, HelmetProvider} from "react-helmet-async";

const HeadTags = (props) => {
  
  const {
    title = "Challenge.Gov --",
    metaDescription = "Main page Challenge.Gov",
    logo = ""
  } = props;
  return (
    <HelmetProvider>
        <Helmet>
        <title>{title}</title>
        <meta name="description" key="description" content={metaDescription} />
        <meta name="title" key="title" content={title} />
        <meta property="og:title" key="og:title" content={title} />
        <meta property="og:locale" key="og:locale" content="en_US" />
        <meta property="og:type" key="og:type" content="website" />
        <meta
            property="og:description"
            key="og:description"
            content={metaDescription}
        />
        <meta
            property="og:image"
            key="og:image"
            content={logo}
        />  
        </Helmet>
    </HelmetProvider>
  );};