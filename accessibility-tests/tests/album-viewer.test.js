/**
 * WCAG 2.1 Accessibility Tests for album-viewer
 * Tests the album viewer web application for accessibility compliance
 */

const { Builder, By } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const TestUtils = require('../utils/test-utils');
const colors = require('colors');

// Configuration
const ALBUM_VIEWER_URL = 'http://localhost:3000';
const TIMEOUT = 10000;

class AlbumViewerTests {
  constructor() {
    this.driver = null;
    this.utils = null;
    this.results = {
      passed: [],
      failed: [],
      warnings: []
    };
  }

  async setup() {
    console.log('Setting up Chrome WebDriver...'.blue);
    
    const options = new chrome.Options();
    // Uncomment the next line to run headless
    // options.addArguments('--headless');
    options.addArguments('--disable-dev-shm-usage');
    options.addArguments('--no-sandbox');

    this.driver = await new Builder()
      .forBrowser('chrome')
      .setChromeOptions(options)
      .build();

    this.utils = new TestUtils(this.driver);
    
    console.log('WebDriver setup complete!'.green);
  }

  async teardown() {
    if (this.driver) {
      await this.driver.quit();
      console.log('\nWebDriver closed.'.blue);
    }
  }

  /**
   * Navigate to the album viewer home page
   */
  async navigateToHome() {
    console.log(`\nNavigating to ${ALBUM_VIEWER_URL}...`.blue);
    await this.driver.get(ALBUM_VIEWER_URL);
    await this.utils.waitForPageLoad();
    console.log('Page loaded successfully!'.green);
  }

  /**
   * Test 1.1.1: Non-text Content (Level A)
   * All images must have alt attributes
   */
  async testImageAltText() {
    const testName = 'WCAG 1.1.1 - Image Alt Text';
    console.log(`\n${'='.repeat(70)}`.cyan);
    console.log(testName.cyan.bold);
    console.log('='.repeat(70).cyan);

    try {
      const imageResults = await this.utils.checkImageAltText();
      
      const missingAlt = imageResults.filter(img => !img.hasAlt);
      const passed = missingAlt.length === 0;

      if (passed) {
        console.log('✓ All images have alt attributes'.green);
        this.results.passed.push(testName);
      } else {
        console.log(`✗ ${missingAlt.length} image(s) missing alt attribute:`.red);
        missingAlt.forEach(img => {
          console.log(`  - ${img.src}`.yellow);
        });
        this.results.failed.push(testName);
      }

      // Show summary
      console.log(`\nTotal images: ${imageResults.length}`);
      console.log(`With alt text: ${imageResults.filter(i => i.hasAlt).length}`);
      console.log(`Decorative (alt=""): ${imageResults.filter(i => i.isDecorative).length}`);

      return { passed, details: imageResults };
    } catch (error) {
      console.log(`✗ Test failed with error: ${error.message}`.red);
      this.results.failed.push(testName);
      return { passed: false, error: error.message };
    }
  }

  /**
   * Test 1.3.1: Heading Hierarchy (Level A)
   * Headings should follow proper hierarchy
   */
  async testHeadingHierarchy() {
    const testName = 'WCAG 1.3.1 - Heading Hierarchy';
    console.log(`\n${'='.repeat(70)}`.cyan);
    console.log(testName.cyan.bold);
    console.log('='.repeat(70).cyan);

    try {
      const hierarchy = await this.utils.checkHeadingHierarchy();
      
      if (hierarchy.length === 0) {
        console.log('⚠ No headings found on page'.yellow);
        this.results.warnings.push(testName);
        return { passed: false, details: [], warning: 'No headings found' };
      }

      // Check for h1
      const hasH1 = hierarchy.some(h => h.level === 1);
      
      // Check for skipped levels
      let skippedLevels = false;
      for (let i = 1; i < hierarchy.length; i++) {
        if (hierarchy[i].level - hierarchy[i-1].level > 1) {
          skippedLevels = true;
          console.log(`⚠ Heading level skipped: ${hierarchy[i-1].tag} -> ${hierarchy[i].tag}`.yellow);
        }
      }

      const passed = hasH1 && !skippedLevels;

      if (hasH1) {
        console.log('✓ Page has an h1 element'.green);
      } else {
        console.log('✗ Page missing h1 element'.red);
      }

      if (!skippedLevels) {
        console.log('✓ No heading levels skipped'.green);
      }

      // Display hierarchy
      console.log('\nHeading structure:');
      hierarchy.forEach(h => {
        const indent = '  '.repeat(h.level - 1);
        console.log(`${indent}${h.tag}: ${h.text}`);
      });

      if (passed) {
        this.results.passed.push(testName);
      } else {
        this.results.failed.push(testName);
      }

      return { passed, details: hierarchy };
    } catch (error) {
      console.log(`✗ Test failed with error: ${error.message}`.red);
      this.results.failed.push(testName);
      return { passed: false, error: error.message };
    }
  }

  /**
   * Test 3.3.2: Form Labels (Level A)
   * All form inputs should have labels
   */
  async testFormLabels() {
    const testName = 'WCAG 3.3.2 - Form Labels';
    console.log(`\n${'='.repeat(70)}`.cyan);
    console.log(testName.cyan.bold);
    console.log('='.repeat(70).cyan);

    try {
      const formResults = await this.utils.checkFormLabels();
      
      if (formResults.length === 0) {
        console.log('ℹ No form inputs found on page'.blue);
        this.results.passed.push(testName);
        return { passed: true, details: [], note: 'No forms on page' };
      }

      const missingLabels = formResults.filter(input => !input.hasLabel);
      const passed = missingLabels.length === 0;

      if (passed) {
        console.log(`✓ All ${formResults.length} form input(s) have labels`.green);
        this.results.passed.push(testName);
      } else {
        console.log(`✗ ${missingLabels.length} input(s) missing labels:`.red);
        missingLabels.forEach(input => {
          console.log(`  - ${input.type} (id: ${input.id}, name: ${input.name})`.yellow);
        });
        this.results.failed.push(testName);
      }

      return { passed, details: formResults };
    } catch (error) {
      console.log(`✗ Test failed with error: ${error.message}`.red);
      this.results.failed.push(testName);
      return { passed: false, error: error.message };
    }
  }

  /**
   * Test 2.1.1: Keyboard Navigation (Level A)
   * All functionality must be keyboard accessible
   */
  async testKeyboardNavigation() {
    const testName = 'WCAG 2.1.1 - Keyboard Navigation';
    console.log(`\n${'='.repeat(70)}`.cyan);
    console.log(testName.cyan.bold);
    console.log('='.repeat(70).cyan);

    try {
      const focusableElements = await this.utils.testKeyboardNavigation();
      
      const passed = focusableElements.length > 0;

      if (passed) {
        console.log(`✓ Found ${focusableElements.length} keyboard-accessible elements`.green);
        
        console.log('\nFocusable elements:');
        focusableElements.slice(0, 10).forEach((el, idx) => {
          console.log(`  ${idx + 1}. ${el.tag}${el.id ? '#' + el.id : ''} - "${el.text || '(no text)'}"`);
        });
        
        if (focusableElements.length > 10) {
          console.log(`  ... and ${focusableElements.length - 10} more`);
        }

        this.results.passed.push(testName);
      } else {
        console.log('✗ No keyboard-accessible elements found'.red);
        this.results.failed.push(testName);
      }

      return { passed, details: focusableElements };
    } catch (error) {
      console.log(`✗ Test failed with error: ${error.message}`.red);
      this.results.failed.push(testName);
      return { passed: false, error: error.message };
    }
  }

  /**
   * Test 2.4.2: Page Title (Level A)
   * Page must have a descriptive title
   */
  async testPageTitle() {
    const testName = 'WCAG 2.4.2 - Page Title';
    console.log(`\n${'='.repeat(70)}`.cyan);
    console.log(testName.cyan.bold);
    console.log('='.repeat(70).cyan);

    try {
      const titleResult = await this.utils.checkPageTitle();
      
      const passed = titleResult.hasTitle && titleResult.title.length > 0;

      if (passed) {
        console.log(`✓ Page has title: "${titleResult.title}"`.green);
        this.results.passed.push(testName);
      } else {
        console.log('✗ Page missing title or title is empty'.red);
        this.results.failed.push(testName);
      }

      return { passed, details: titleResult };
    } catch (error) {
      console.log(`✗ Test failed with error: ${error.message}`.red);
      this.results.failed.push(testName);
      return { passed: false, error: error.message };
    }
  }

  /**
   * Test 3.1.1: Language Attribute (Level A)
   * HTML element must have lang attribute
   */
  async testLanguageAttribute() {
    const testName = 'WCAG 3.1.1 - Language of Page';
    console.log(`\n${'='.repeat(70)}`.cyan);
    console.log(testName.cyan.bold);
    console.log('='.repeat(70).cyan);

    try {
      const langResult = await this.utils.checkLanguageAttribute();
      
      const passed = langResult.hasLang;

      if (passed) {
        console.log(`✓ Page has lang attribute: "${langResult.lang}"`.green);
        this.results.passed.push(testName);
      } else {
        console.log('✗ Page missing lang attribute on <html> element'.red);
        this.results.failed.push(testName);
      }

      return { passed, details: langResult };
    } catch (error) {
      console.log(`✗ Test failed with error: ${error.message}`.red);
      this.results.failed.push(testName);
      return { passed: false, error: error.message };
    }
  }

  /**
   * Test 1.3.1: ARIA Landmarks (Level A)
   * Check for proper landmarks
   */
  async testLandmarks() {
    const testName = 'WCAG 1.3.1 - ARIA Landmarks';
    console.log(`\n${'='.repeat(70)}`.cyan);
    console.log(testName.cyan.bold);
    console.log('='.repeat(70).cyan);

    try {
      const landmarks = await this.utils.checkLandmarks();
      
      const hasMain = landmarks.some(l => 
        l.role === 'main' || l.tag === 'MAIN'
      );

      const passed = landmarks.length > 0 && hasMain;

      if (hasMain) {
        console.log('✓ Page has main landmark'.green);
      } else {
        console.log('⚠ Page missing main landmark'.yellow);
      }

      console.log(`\nFound ${landmarks.length} landmark(s):`);
      landmarks.forEach(l => {
        console.log(`  - <${l.tag.toLowerCase()}> ${l.role !== '(implicit)' ? `role="${l.role}"` : ''} ${l.ariaLabel ? `aria-label="${l.ariaLabel}"` : ''}`);
      });

      if (passed) {
        this.results.passed.push(testName);
      } else {
        this.results.warnings.push(testName);
      }

      return { passed, details: landmarks };
    } catch (error) {
      console.log(`✗ Test failed with error: ${error.message}`.red);
      this.results.failed.push(testName);
      return { passed: false, error: error.message };
    }
  }

  /**
   * Run automated axe-core tests
   */
  async runAxeTests() {
    const testName = 'Automated axe-core Analysis';
    console.log(`\n${'='.repeat(70)}`.cyan);
    console.log(testName.cyan.bold);
    console.log('='.repeat(70).cyan);

    try {
      const results = await this.utils.runAxeAnalysis();
      
      const violations = results.violations || [];
      const passes = results.passes || [];
      const incomplete = results.incomplete || [];

      console.log(`✓ Passed: ${passes.length} rule(s)`.green);
      
      if (violations.length > 0) {
        console.log(`✗ Violations: ${violations.length}`.red);
        violations.forEach(v => {
          console.log(`\n  ${v.id} (${v.impact})`.red.bold);
          console.log(`  ${v.description}`);
          console.log(`  Help: ${v.helpUrl}`);
          console.log(`  Affected nodes: ${v.nodes.length}`);
        });
      } else {
        console.log('✓ No violations found!'.green);
      }

      if (incomplete.length > 0) {
        console.log(`\n⚠ Incomplete: ${incomplete.length} (requires manual review)`.yellow);
      }

      const passed = violations.length === 0;
      
      if (passed) {
        this.results.passed.push(testName);
      } else {
        this.results.failed.push(testName);
      }

      return { passed, violations, passes, incomplete };
    } catch (error) {
      console.log(`✗ Test failed with error: ${error.message}`.red);
      this.results.failed.push(testName);
      return { passed: false, error: error.message };
    }
  }

  /**
   * Print final summary
   */
  printSummary() {
    console.log('\n\n');
    console.log('╔' + '═'.repeat(68) + '╗');
    console.log('║' + ' '.repeat(20) + 'TEST SUMMARY'.bold + ' '.repeat(36) + '║');
    console.log('╠' + '═'.repeat(68) + '╣');
    console.log(`║ ${'Passed:'.green.bold}  ${this.results.passed.length.toString().padEnd(58)} ║`);
    console.log(`║ ${'Failed:'.red.bold}  ${this.results.failed.length.toString().padEnd(58)} ║`);
    console.log(`║ ${'Warnings:'.yellow.bold} ${this.results.warnings.length.toString().padEnd(56)} ║`);
    console.log('╚' + '═'.repeat(68) + '╝');

    if (this.results.failed.length > 0) {
      console.log('\nFailed Tests:'.red.bold);
      this.results.failed.forEach(test => console.log(`  ✗ ${test}`.red));
    }

    if (this.results.warnings.length > 0) {
      console.log('\nWarnings:'.yellow.bold);
      this.results.warnings.forEach(test => console.log(`  ⚠ ${test}`.yellow));
    }
  }

  /**
   * Run all tests
   */
  async runAll() {
    try {
      await this.setup();
      await this.navigateToHome();

      // Run all tests
      await this.testPageTitle();
      await this.testLanguageAttribute();
      await this.testImageAltText();
      await this.testHeadingHierarchy();
      await this.testFormLabels();
      await this.testKeyboardNavigation();
      await this.testLandmarks();
      await this.runAxeTests();

      this.printSummary();

    } catch (error) {
      console.error('Test execution failed:'.red, error);
    } finally {
      await this.teardown();
    }
  }
}

// Run tests if this file is executed directly
if (require.main === module) {
  console.log('╔' + '═'.repeat(68) + '╗');
  console.log('║' + ' WCAG 2.1 Accessibility Tests - Album Viewer '.bold.cyan + ' '.repeat(22) + '║');
  console.log('╚' + '═'.repeat(68) + '╝\n');

  const tests = new AlbumViewerTests();
  tests.runAll().then(() => {
    const exitCode = tests.results.failed.length > 0 ? 1 : 0;
    process.exit(exitCode);
  });
}

module.exports = AlbumViewerTests;
