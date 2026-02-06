# Accessibility Test Suite

This directory contains automated accessibility tests based on WCAG 2.1 Level A and AA standards using Selenium WebDriver and axe-core.

## Prerequisites

- Node.js (v14 or higher)
- Google Chrome browser
- The application under test running locally

## Installation

```bash
cd accessibility-tests
npm install
```

## Running Tests

### Run all tests for album-viewer
```bash
npm run test:album-viewer
```

### Run all tests for adventureview
```bash
npm run test:adventureview
```

## Test Structure

- `tests/` - Test files for each application
- `utils/` - Shared test utilities and helper functions
- `package.json` - Dependencies and test scripts

## What Gets Tested

### WCAG 2.1 Level A
- **1.1.1 Non-text Content**: Images have alt text
- **1.3.1 Info and Relationships**: Semantic HTML, headings, landmarks
- **2.1.1 Keyboard**: Full keyboard accessibility
- **2.1.2 No Keyboard Trap**: Users can navigate away
- **2.4.2 Page Titled**: Pages have descriptive titles
- **3.1.1 Language of Page**: HTML lang attribute set
- **3.3.2 Labels or Instructions**: Form inputs have labels

### WCAG 2.1 Level AA
- **1.4.3 Contrast (Minimum)**: Color contrast ratios
- **2.4.7 Focus Visible**: Focus indicators are visible
- And more...

## Test Tools

- **Selenium WebDriver**: Browser automation
- **axe-core**: Automated accessibility testing engine
- **ChromeDriver**: Chrome browser driver

## Before Running Tests

Make sure your application is running:

### For album-viewer:
```bash
cd album-viewer
npm start
# Should be running on http://localhost:3000
```

### For adventureview:
```bash
cd adventureforms/adventureview
npm start
# Should be running on http://localhost:3000
```

## Understanding Test Results

- ✓ **PASS** (green): Test passed successfully
- ✗ **FAIL** (red): Test failed - accessibility issue found
- ⚠ **WARNING** (yellow): Potential issue requiring manual review
- ℹ **INFO** (blue): Informational message

## Next Steps

1. Run the tests
2. Review failures and warnings
3. Fix accessibility issues in the application
4. Re-run tests to verify fixes
5. Update wcag.md with test results

## Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [axe-core Documentation](https://github.com/dequelabs/axe-core)
- [Selenium WebDriver Docs](https://www.selenium.dev/documentation/webdriver/)
