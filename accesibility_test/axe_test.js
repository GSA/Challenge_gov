const puppeteer = require('puppeteer');
const AxeBuilder = require('axe-core').AxeBuilder;
const fs = require('fs');
const path = require('path');

// Load the URLs to test from a file
function loadUrlsFromFile(filePath) {
  return fs.readFileSync(filePath, 'utf-8')
    .split('\n')
    .filter(Boolean)
    .map(url => url.trim());
}

// Create or ensure the logs directory exists
const logDir = path.join(__dirname, 'logs');
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir);
}

// Generate a date and time format
const getFormattedDate = () => {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');  // Months are 0-based
  const day = String(now.getDate()).padStart(2, '0');
  const hours = String(now.getHours()).padStart(2, '0');
  const minutes = String(now.getMinutes()).padStart(2, '0');
  const seconds = String(now.getSeconds()).padStart(2, '0');
  return `${year}-${month}-${day}_${hours}-${minutes}-${seconds}`;
};

// Create a unique log file name with the current date and time
const logFile = path.join(logDir, `accessibility_report_${getFormattedDate()}.log`);
const logFileCSV = path.join(logDir, `accessibility_report_${getFormattedDate()}.csv`);
const logStream = fs.createWriteStream(logFile, { flags: 'a' });  // Append mode
const logStreamCSV = fs.createWriteStream(logFileCSV, { flags: 'a' });  // Append mode

// Function to log messages to the log file
function logMessage(message) {
  logStream.write(`${new Date().toISOString()} - ${message}\n`);
}

// Function to log messages to the CSV file
function logMessageCSV(fullUrl, description, impact, helpUrl, target) {
  const csvRow = `${fullUrl},"${description}","${impact}","${helpUrl}","${target}"`;
  logStreamCSV.write(`${csvRow}\n`);
}

// Capture the selector from command line arguments
const selector = process.argv[2];  // This will capture the selector passed as an argument

if (selector != "super_admin_active" && selector != "solver_active") {
  console.error("Error: You must provide a CSS selector as a command-line argument. super_admin_active or solver_active");
  process.exit(1);  // Exit with failure if no selector is provided
}

const baseUrlToTest = 'http://localhost:4000';

// Define a list of URLs to test
const urlsToTest = loadUrlsFromFile(`./accesibility_test/urls_to_test_${selector}.txt`);


(async () => {

  const logMsg = `Testing accessibility on: ${baseUrlToTest} as ${selector}\n\n`;
  console.log(logMsg);
  logMessage(logMsg);  // Log the URL being tested
  logMessageCSV("URL", "Description", "Impact", "Help URL", "Target"); // Log the CSV header
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  await page.goto(baseUrlToTest + '/dev_accounts?_csrf_token=&_method=get');  // Access the admin page

  let hasViolations = false;

  await page.waitForSelector(`#${selector}`);  // Use the selector for the admin page
  await Promise.all([
    page.waitForNavigation(),
    await page.click(`#${selector}`)]);

  for (const url of urlsToTest) {

    if (!url.startsWith('#')) {
      const fullUrl = `${baseUrlToTest}${url}`;
      const logMsg = `Testing accessibility on: ${fullUrl}`;
      console.log(logMsg);
      logMessage(logMsg);  // Log the URL being tested

      // Navigate to the page
      await page.goto(`${baseUrlToTest}${url}`);

      // Inject axe-core into the page
      await page.addScriptTag({ path: require.resolve('axe-core') });

      // Run the accessibility tests
      const results = await page.evaluate(() => {
        return axe.run({
          runOnly: {
            type: 'tag',
            values: ['section508', 'wcag2aa']  // Specify Section 508 and wcag2aa as the compliance standard
          }
        });
      });

      // Log accessibility violations, if any
      if (results.violations.length > 0) {
        hasViolations = true;  // Set flag to true if any violations are found
        const violationMsg = `\n❌ Accessibility violations found on ${fullUrl}:`;
        console.log(violationMsg);
        logMessage(violationMsg);

        results.violations.forEach(violation => {
          const violationDetail = `\n🚩 Violation: ${violation.description}\nImpact: ${violation.impact}\nHelp: ${violation.help}\nHelp URL: ${violation.helpUrl}\nID: ${violation.id}\n`;
          console.log(violationDetail);
          logMessage(violationDetail);

          violation.nodes.forEach(node => {
            const nodeDetail = `\n🔸 Affected element: ${node.target}\n\nFailure summary: ${node.failureSummary}`;
            console.log(nodeDetail);
            logMessage(nodeDetail);
            logMessageCSV(fullUrl, violation.description, violation.impact, violation.helpUrl, node.target);
          });
        });
      } else {
        const noViolationMsg = `\n✅ No accessibility violations found on ${fullUrl}.`;
        console.log(noViolationMsg);
        logMessage(noViolationMsg);
      }
    }
  }

  await browser.close();
  logStream.end();
  logStreamCSV.end();
  if (hasViolations) {
    console.error("Accessibility violations found! Exiting with failure...");
    process.exit(1);  // Non-zero exit code indicates a failure
  } else {
    process.exit(0);  // Zero exit code indicates success
  }
})();
