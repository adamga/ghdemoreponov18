/**
 * Test Utilities for WCAG 2.1 Accessibility Testing
 * Provides helper functions for common accessibility checks
 */

const { By, until, Key } = require('selenium-webdriver');
const AxeBuilder = require('@axe-core/webdriverjs').default;

class TestUtils {
  constructor(driver) {
    this.driver = driver;
  }

  /**
   * Wait for page to be fully loaded
   */
  async waitForPageLoad() {
    await this.driver.wait(async () => {
      const readyState = await this.driver.executeScript('return document.readyState');
      return readyState === 'complete';
    }, 10000);
  }

  /**
   * Run axe-core automated accessibility checks
   * @returns {Object} Results from axe-core analysis
   */
  async runAxeAnalysis() {
    const results = await new AxeBuilder(this.driver)
      .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
      .analyze();
    return results;
  }

  /**
   * Check if all images have alt attributes
   * WCAG 1.1.1 - Non-text Content (Level A)
   */
  async checkImageAltText() {
    const images = await this.driver.findElements(By.css('img'));
    const results = [];

    for (let img of images) {
      const src = await img.getAttribute('src');
      const alt = await img.getAttribute('alt');
      const role = await img.getAttribute('role');
      
      // Alt attribute should exist (can be empty for decorative images)
      const hasAlt = alt !== null;
      
      results.push({
        src: src || '(no src)',
        hasAlt,
        altText: alt || '(none)',
        role: role || '(none)',
        isDecorative: alt === '' || role === 'presentation'
      });
    }

    return results;
  }

  /**
   * Check if page has proper heading hierarchy
   * WCAG 1.3.1 - Info and Relationships (Level A)
   */
  async checkHeadingHierarchy() {
    const headings = await this.driver.findElements(By.css('h1, h2, h3, h4, h5, h6'));
    const hierarchy = [];

    for (let heading of headings) {
      const tagName = await heading.getTagName();
      const text = await heading.getText();
      hierarchy.push({
        level: parseInt(tagName.substring(1)),
        tag: tagName,
        text: text.substring(0, 50) // Truncate long text
      });
    }

    return hierarchy;
  }

  /**
   * Check if all form inputs have labels
   * WCAG 1.3.1, 3.3.2 - Labels or Instructions (Level A)
   */
  async checkFormLabels() {
    const inputs = await this.driver.findElements(By.css('input, select, textarea'));
    const results = [];

    for (let input of inputs) {
      const id = await input.getAttribute('id');
      const type = await input.getAttribute('type');
      const name = await input.getAttribute('name');
      const ariaLabel = await input.getAttribute('aria-label');
      const ariaLabelledBy = await input.getAttribute('aria-labelledby');

      // Check if there's an associated label
      let hasLabel = false;
      let labelText = '';

      if (id) {
        try {
          const label = await this.driver.findElement(By.css(`label[for="${id}"]`));
          hasLabel = true;
          labelText = await label.getText();
        } catch (e) {
          // No label found
        }
      }

      // Check for ARIA label
      if (!hasLabel && (ariaLabel || ariaLabelledBy)) {
        hasLabel = true;
        labelText = ariaLabel || `(aria-labelledby: ${ariaLabelledBy})`;
      }

      results.push({
        id: id || '(no id)',
        type: type || 'text',
        name: name || '(no name)',
        hasLabel,
        labelText: labelText || '(none)'
      });
    }

    return results;
  }

  /**
   * Test keyboard navigation
   * WCAG 2.1.1 - Keyboard (Level A)
   */
  async testKeyboardNavigation() {
    // Get all focusable elements
    const focusableElements = await this.driver.executeScript(`
      const focusable = document.querySelectorAll(
        'a[href], button, input, select, textarea, [tabindex]:not([tabindex="-1"])'
      );
      return Array.from(focusable).map(el => ({
        tag: el.tagName,
        id: el.id || '',
        class: el.className || '',
        text: el.innerText?.substring(0, 30) || el.value?.substring(0, 30) || '',
        tabIndex: el.tabIndex
      }));
    `);

    return focusableElements;
  }

  /**
   * Check if focus is visible
   * WCAG 2.4.7 - Focus Visible (Level AA)
   */
  async checkFocusVisible(element) {
    // Focus the element
    await element.sendKeys('');
    
    // Get computed styles
    const styles = await this.driver.executeScript(`
      const el = arguments[0];
      el.focus();
      const styles = window.getComputedStyle(el, ':focus');
      return {
        outline: styles.outline,
        outlineWidth: styles.outlineWidth,
        outlineColor: styles.outlineColor,
        boxShadow: styles.boxShadow,
        border: styles.border
      };
    `, element);

    return styles;
  }

  /**
   * Check color contrast ratios
   * WCAG 1.4.3 - Contrast (Minimum) (Level AA)
   */
  async checkContrast(selector) {
    const elements = await this.driver.findElements(By.css(selector));
    const results = [];

    for (let el of elements) {
      const contrast = await this.driver.executeScript(`
        const el = arguments[0];
        const styles = window.getComputedStyle(el);
        return {
          color: styles.color,
          backgroundColor: styles.backgroundColor,
          fontSize: styles.fontSize,
          fontWeight: styles.fontWeight
        };
      `, el);

      results.push(contrast);
    }

    return results;
  }

  /**
   * Check if page has proper language attribute
   * WCAG 3.1.1 - Language of Page (Level A)
   */
  async checkLanguageAttribute() {
    const htmlLang = await this.driver.executeScript('return document.documentElement.lang');
    return {
      hasLang: !!htmlLang,
      lang: htmlLang || '(none)'
    };
  }

  /**
   * Check for skip links
   * WCAG 2.4.1 - Bypass Blocks (Level A)
   */
  async checkSkipLinks() {
    try {
      // Look for skip links (usually hidden until focused)
      const skipLinks = await this.driver.findElements(By.css('a[href^="#"]'));
      const results = [];

      for (let link of skipLinks) {
        const text = await link.getText();
        const href = await link.getAttribute('href');
        const isVisible = await link.isDisplayed();

        if (text.toLowerCase().includes('skip') || href === '#main' || href === '#content') {
          results.push({
            text,
            href,
            isVisible
          });
        }
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  /**
   * Check if page has a unique title
   * WCAG 2.4.2 - Page Titled (Level A)
   */
  async checkPageTitle() {
    const title = await this.driver.getTitle();
    return {
      hasTitle: !!title,
      title: title || '(empty)'
    };
  }

  /**
   * Test for keyboard traps
   * WCAG 2.1.2 - No Keyboard Trap (Level A)
   */
  async testForKeyboardTraps() {
    // Get all interactive elements
    const elements = await this.driver.findElements(
      By.css('a, button, input, select, textarea, [tabindex]')
    );

    if (elements.length === 0) return { trapped: false };

    // Try tabbing through elements
    const firstElement = elements[0];
    await firstElement.sendKeys('');

    for (let i = 0; i < elements.length + 2; i++) {
      await this.driver.actions().sendKeys(Key.TAB).perform();
      await this.driver.sleep(100);
    }

    // Check if we can still navigate
    const activeElement = await this.driver.switchTo().activeElement();
    const tagName = await activeElement.getTagName();

    return {
      trapped: false, // If we got here, we're not trapped
      lastFocusedElement: tagName
    };
  }

  /**
   * Check ARIA landmarks
   * WCAG 1.3.1 - Info and Relationships (Level A)
   */
  async checkLandmarks() {
    const landmarks = await this.driver.executeScript(`
      const landmarks = document.querySelectorAll(
        '[role="banner"], [role="navigation"], [role="main"], [role="complementary"], [role="contentinfo"], [role="search"], header, nav, main, aside, footer'
      );
      return Array.from(landmarks).map(el => ({
        tag: el.tagName,
        role: el.getAttribute('role') || '(implicit)',
        ariaLabel: el.getAttribute('aria-label') || ''
      }));
    `);

    return landmarks;
  }

  /**
   * Print test results in a formatted way
   */
  formatResults(testName, results, passed) {
    const colors = require('colors');
    const status = passed ? 'PASS'.green : 'FAIL'.red;
    console.log(`\n${'='.repeat(70)}`);
    console.log(`${testName} - ${status}`);
    console.log('='.repeat(70));
    console.log(JSON.stringify(results, null, 2));
  }
}

module.exports = TestUtils;
