# Quick Start: WCAG Accessibility Testing with Selenium

## What We've Built

You now have a complete automated accessibility testing suite with:

### ✅ Test Infrastructure
- **Location**: `accessibility-tests/` directory
- **Framework**: Selenium WebDriver + axe-core
- **Language**: Node.js
- **Browser**: Chrome (automated)

### ✅ Implemented Tests (8 tests for album-viewer)

1. **WCAG 1.1.1** - Non-text Content
   - Checks all images have `alt` attributes
   - Identifies decorative vs. meaningful images

2. **WCAG 1.3.1** - Heading Hierarchy
   - Validates proper H1-H6 structure
   - Checks for skipped heading levels

3. **WCAG 1.3.1** - ARIA Landmarks
   - Verifies presence of semantic landmarks
   - Checks for `main`, `nav`, `header`, etc.

4. **WCAG 2.1.1** - Keyboard Navigation
   - Lists all keyboard-accessible elements
   - Verifies tab order exists

5. **WCAG 2.4.2** - Page Title
   - Ensures page has descriptive title

6. **WCAG 3.1.1** - Language Attribute
   - Checks `<html lang="">` attribute

7. **WCAG 3.3.2** - Form Labels
   - Validates all inputs have labels

8. **Automated axe-core Scan**
   - Runs 50+ automated WCAG checks
   - Reports violations with severity levels

### 📂 File Structure
```
accessibility-tests/
├── package.json              # Dependencies
├── README.md                 # Documentation
├── .gitignore               # Git ignore rules
├── utils/
│   └── test-utils.js        # Reusable test helpers
└── tests/
    └── album-viewer.test.js # Album viewer tests
```

## How to Use

### Step 1: Start Your Application
```bash
# Terminal 1 - Start album-viewer
cd album-viewer
npm install
npm start
# App runs on http://localhost:3000
```

### Step 2: Run Tests
```bash
# Terminal 2 - Run accessibility tests
cd accessibility-tests
npm run test:album-viewer
```

### Step 3: Review Results

The test will open Chrome browser and:
- Navigate to your app
- Run automated accessibility checks
- Display colored results in terminal:
  - ✓ Green = Passed
  - ✗ Red = Failed (needs fixing)
  - ⚠ Yellow = Warning (manual review)

## Understanding Test Output

### Example Output:
```
══════════════════════════════════════════════════════════════════
WCAG 1.1.1 - Image Alt Text
══════════════════════════════════════════════════════════════════
✓ All images have alt attributes

Total images: 5
With alt text: 5
Decorative (alt=""): 2

══════════════════════════════════════════════════════════════════
TEST SUMMARY
══════════════════════════════════════════════════════════════════
Passed:   7
Failed:   1
Warnings: 0
```

## What to Do When Tests Fail

### Example Failure: Missing Alt Text
```
✗ 2 image(s) missing alt attribute:
  - /images/logo.png
  - /images/icon.svg
```

**Fix**: Add alt attributes to images in your HTML/Pug templates:
```pug
img(src="/images/logo.png" alt="Company Logo")
img(src="/images/icon.svg" alt="")  // decorative
```

### Example Failure: Missing H1
```
✗ Page missing h1 element
```

**Fix**: Add an H1 to your page template:
```pug
h1 Album Viewer
```

## Next Steps

### 1. Fix Current Issues
Run tests, fix failures, repeat until all pass.

### 2. Add More Tests
The test utilities support:
- Color contrast checking (`checkContrast()`)
- Focus visibility (`checkFocusVisible()`)
- Skip links (`checkSkipLinks()`)
- Keyboard trap detection (`testForKeyboardTraps()`)

### 3. Test Other Apps
Create `tests/adventureview.test.js` using album-viewer as template.

### 4. Continuous Integration
Add tests to your CI/CD pipeline to prevent accessibility regressions.

## Available Test Utilities

The `TestUtils` class provides:

```javascript
// From utils/test-utils.js
await utils.checkImageAltText()          // Image alt attributes
await utils.checkHeadingHierarchy()      // H1-H6 structure
await utils.checkFormLabels()            // Form accessibility
await utils.testKeyboardNavigation()     // Keyboard access
await utils.checkLandmarks()             // ARIA landmarks
await utils.checkPageTitle()             // Page title
await utils.checkLanguageAttribute()     // HTML lang attribute
await utils.checkContrast('p')           // Color contrast
await utils.checkSkipLinks()             // Skip navigation
await utils.runAxeAnalysis()             // Full axe-core scan
```

## Troubleshooting

### Chrome Driver Issues
If you get ChromeDriver errors:
```bash
npm install chromedriver@latest
```

### Application Not Running
Ensure your app is running before tests:
```bash
curl http://localhost:3000
```

### Port Conflicts
If port 3000 is in use, update `ALBUM_VIEWER_URL` in the test file.

## Resources

- [Test Implementation](tests/album-viewer.test.js)
- [Test Utilities](utils/test-utils.js)
- [WCAG Guidelines](../wcag.md)
- [Selenium Docs](https://www.selenium.dev/documentation/)
- [axe-core Rules](https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md)

## Pro Tips

1. **Run headless**: Uncomment `options.addArguments('--headless')` for faster tests
2. **Save screenshots**: Use `driver.takeScreenshot()` to capture failures
3. **Manual testing**: Combine with keyboard-only and screen reader testing
4. **Update wcag.md**: Check off tests as you fix issues

Happy testing! 🚀
