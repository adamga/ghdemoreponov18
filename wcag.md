# WCAG 2.1 Accessibility Test Plan

## Overview
This document outlines UI accessibility tests based on WCAG 2.1 Level A and AA standards for the applications in this repository.

### Applications Under Test
- **album-viewer**: Node/Express web application (Pug views)
- **adventureview**: Node web application
- **FormsApp**: WinForms desktop application

---

## 🚀 Automated Test Implementation

### Test Suite Location
All automated tests are located in the `accessibility-tests/` directory.

### Implemented Tests (album-viewer)
- [x] **WCAG 1.1.1** - Non-text Content (Image alt text) ✅ [See test](accessibility-tests/tests/album-viewer.test.js)
- [x] **WCAG 1.3.1** - Info and Relationships (Heading hierarchy) ✅ [See test](accessibility-tests/tests/album-viewer.test.js)
- [x] **WCAG 1.3.1** - ARIA Landmarks ✅ [See test](accessibility-tests/tests/album-viewer.test.js)
- [x] **WCAG 2.1.1** - Keyboard Navigation ✅ [See test](accessibility-tests/tests/album-viewer.test.js)
- [x] **WCAG 2.4.2** - Page Titled ✅ [See test](accessibility-tests/tests/album-viewer.test.js)
- [x] **WCAG 3.1.1** - Language of Page ✅ [See test](accessibility-tests/tests/album-viewer.test.js)
- [x] **WCAG 3.3.2** - Form Labels ✅ [See test](accessibility-tests/tests/album-viewer.test.js)
- [x] **Automated axe-core** - Full WCAG 2.1 A/AA scan ✅ [See test](accessibility-tests/tests/album-viewer.test.js)

### How to Run Tests

#### Prerequisites
1. Install dependencies:
   ```bash
   cd accessibility-tests
   npm install
   ```

2. Start the application you want to test:
   ```bash
   # For album-viewer
   cd album-viewer
   npm start
   ```

#### Run Tests
```bash
cd accessibility-tests
npm run test:album-viewer
```

See [accessibility-tests/README.md](accessibility-tests/README.md) for more details.

### Test Implementation Progress
- **album-viewer**: 8 automated tests implemented
- **adventureview**: Not yet implemented
- **FormsApp**: Not yet implemented (requires different tooling)

---

## 1. Perceivable
*Information and UI components must be presentable to users in ways they can perceive.*

### 1.1 Text Alternatives (Level A)

#### Test 1.1.1: Non-text Content ✅ Automated
- [ ] **Images**: All `<img>` tags have meaningful `alt` attributes
- [ ] **Decorative images**: Decorative images use `alt=""` or CSS backgrounds
- [ ] **Icons**: Icon buttons have accessible labels or `aria-label`
- [ ] **Form inputs**: All inputs have associated `<label>` elements or `aria-label`
- [ ] **WinForms**: All images/icons have accessible names and descriptions

**Automated Test**: `tests/album-viewer.test.js::testImageAltText()`

### 1.2 Time-based Media (Level A/AA)

#### Test 1.2.1: Audio-Only and Video-Only
- [ ] **Pre-recorded audio**: Transcripts provided for audio-only content
- [ ] **Pre-recorded video**: Alternative text or audio descriptions provided

#### Test 1.2.2: Captions (Prerecorded)
- [ ] **Video with audio**: Synchronized captions provided

#### Test 1.2.3: Audio Description or Media Alternative
- [ ] **Video content**: Audio descriptions or full text alternatives provided

#### Test 1.2.4: Captions (Live) - Level AA
- [ ] **Live audio**: Captions provided for live audio content

#### Test 1.2.5: Audio Description (Prerecorded) - Level AA
- [ ] **Video content**: Audio descriptions provided for all prerecorded video

### 1.3 Adaptable (Level A/AA)

#### Test 1.3.1: Info and Relationships ✅ Automated
- [ ] **Semantic HTML**: Use proper heading hierarchy (`<h1>` through `<h6>`)
- [ ] **Lists**: Use `<ul>`, `<ol>`, `<li>` for list content
- [ ] **Tables**: Data tables use `<th>`, `scope`, and `<caption>`
- [ ] **Forms**: Related fields grouped with `<fieldset>` and `<legend>`
- [ ] **ARIA landmarks**: Use `role="navigation"`, `role="main"`, `role="banner"`, etc.
- [ ] **WinForms**: Proper control types and grouping (GroupBox, Panel)

**Automated Tests**: `tests/album-viewer.test.js::testHeadingHierarchy()`, `tests/album-viewer.test.js::testLandmarks()`

#### Test 1.3.2: Meaningful Sequence
- [ ] **Reading order**: DOM order matches visual presentation order
- [ ] **Tab order**: Logical keyboard navigation sequence
- [ ] **CSS positioning**: Content order remains meaningful without CSS

#### Test 1.3.3: Sensory Characteristics
- [ ] **Instructions**: Don't rely solely on shape, size, position, or sound
- [ ] **Color-independent**: Instructions don't depend only on color (e.g., "click the green button")

#### Test 1.3.4: Orientation - Level AA
- [ ] **Responsive**: Content not restricted to single orientation (portrait/landscape)
- [ ] **Rotation support**: App functions in both orientations unless essential

#### Test 1.3.5: Identify Input Purpose - Level AA
- [ ] **Autocomplete**: Form fields use appropriate `autocomplete` attributes
- [ ] **Common fields**: Name, email, address fields properly identified

### 1.4 Distinguishable (Level A/AA)

#### Test 1.4.1: Use of Color
- [ ] **Information**: Color not the only visual means of conveying information
- [ ] **Links**: Underlined or other non-color distinction in body text
- [ ] **Form validation**: Errors indicated by text/icons, not just red borders

#### Test 1.4.2: Audio Control
- [ ] **Auto-play**: Mechanism to pause, stop, or control volume for auto-playing audio

#### Test 1.4.3: Contrast (Minimum) - Level AA
- [ ] **Normal text**: 4.5:1 contrast ratio against background
- [ ] **Large text**: 3:1 contrast ratio (18pt+ or 14pt+ bold)
- [ ] **UI components**: 3:1 contrast for interactive elements and boundaries
- [ ] **Test all color schemes**: Background color variations tested

#### Test 1.4.4: Resize Text - Level AA
- [ ] **200% zoom**: Text resizable up to 200% without loss of content/functionality
- [ ] **No horizontal scroll**: Content reflows without requiring horizontal scrolling

#### Test 1.4.5: Images of Text - Level AA
- [ ] **Real text preferred**: Use actual text instead of images of text
- [ ] **Exceptions**: Logos and essential images of text acceptable

#### Test 1.4.10: Reflow - Level AA
- [ ] **Responsive at 320px**: Content reflows at 320 CSS pixels width
- [ ] **No 2D scrolling**: Vertical content doesn't require horizontal scrolling

#### Test 1.4.11: Non-text Contrast - Level AA
- [ ] **UI components**: 3:1 contrast for buttons, form fields, focus indicators
- [ ] **Graphical objects**: 3:1 contrast for meaningful graphics

#### Test 1.4.12: Text Spacing - Level AA
- [ ] **Line height**: 1.5x font size minimum
- [ ] **Paragraph spacing**: 2x font size minimum
- [ ] **Letter spacing**: 0.12x font size minimum
- [ ] **Word spacing**: 0.16x font size minimum
- [ ] **No loss of content**: Content remains readable with adjusted spacing

#### Test 1.4.13: Content on Hover or Focus - Level AA
- [ ] **Dismissable**: Hover/focus content can be dismissed without moving pointer/focus
- [ ] **Hoverable**: Pointer can move to hover content without dismissing it
- [ ] **Persistent**: Content remains visible until dismissed or no longer relevant

---

## 2. Operable
*UI components and navigation must be operable.*

### 2.1 Keyboard Accessible (Level A)

#### Test 2.1.1: Keyboard ✅ Automated
- [ ] **Full keyboard access**: All functionality available via keyboard
- [ ] **Tab navigation**: All interactive elements reachable with Tab/Shift+Tab
- [ ] **Enter/Space**: Buttons/links activatable with Enter or Space
- [ ] **Arrow keys**: Dropdowns, radio groups, tabs navigable with arrows
- [ ] **Escape**: Modals/dialogs closable with Escape key
- [ ] **No keyboard trap**: Focus never trapped in any component

**Automated Test**: `tests/album-viewer.test.js::testKeyboardNavigation()`

#### Test 2.1.2: No Keyboard Trap
- [ ] **Modal dialogs**: Can exit modals with keyboard
- [ ] **Custom widgets**: No infinite loops or traps in custom components
- [ ] **Instructions provided**: Non-standard exit methods clearly documented

#### Test 2.1.4: Character Key Shortcuts - Level A
- [ ] **Single-key shortcuts**: Can be turned off, remapped, or only active on focus

### 2.2 Enough Time (Level A/AA)

#### Test 2.2.1: Timing Adjustable
- [ ] **Time limits**: User can turn off, adjust, or extend time limits
- [ ] **Session timeouts**: Warning provided with option to extend

#### Test 2.2.2: Pause, Stop, Hide
- [ ] **Moving content**: Mechanism to pause, stop, or hide auto-updating content
- [ ] **Auto-refresh**: Can be disabled or controlled by user
- [ ] **Carousels**: Pause button provided for auto-rotating content

### 2.3 Seizures and Physical Reactions (Level A/AA)

#### Test 2.3.1: Three Flashes or Below Threshold
- [ ] **Flashing content**: No content flashes more than 3 times per second
- [ ] **Below threshold**: Or flashing is below general flash and red flash thresholds

### 2.4 Navigable (Level A/AA)

#### Test 2.4.1: Bypass Blocks
- [ ] **Skip links**: "Skip to main content" link provided
- [ ] **Landmarks**: ARIA landmarks allow screen readers to skip navigation
- [ ] **Headings**: Heading structure allows navigation through page sections

#### Test 2.4.2: Page Titled ✅ Automated
- [ ] **Title tag**: Every page has unique, descriptive `<title>`
- [ ] **WinForms**: Form titles descriptive and unique

**Automated Test**: `tests/album-viewer.test.js::testPageTitle()`

#### Test 2.4.3: Focus Order
- [ ] **Logical order**: Focus order matches visual and meaningful sequence
- [ ] **Tab order**: No unexpected jumps in focus order

#### Test 2.4.4: Link Purpose (In Context)
- [ ] **Link text**: Link purpose clear from link text alone or with context
- [ ] **Avoid "click here"**: Links use descriptive text
- [ ] **Same destination**: Links with same destination have consistent text

#### Test 2.4.5: Multiple Ways - Level AA
- [ ] **Navigation**: Multiple ways to find pages (menu, search, sitemap)

#### Test 2.4.6: Headings and Labels - Level AA
- [ ] **Descriptive headings**: Headings describe topic or purpose
- [ ] **Descriptive labels**: Form labels describe the input's purpose

#### Test 2.4.7: Focus Visible - Level AA
- [ ] **Keyboard focus indicator**: Visible focus indicator on all focusable elements
- [ ] **Sufficient contrast**: Focus indicator has 3:1 contrast ratio
- [ ] **Not hidden**: Focus never completely obscured by content

### 2.5 Input Modalities (Level A/AA)

#### Test 2.5.1: Pointer Gestures - Level A
- [ ] **Multipoint gestures**: Single-pointer alternatives provided for multipoint gestures
- [ ] **Path-based gestures**: Alternatives for complex path-based gestures

#### Test 2.5.2: Pointer Cancellation - Level A
- [ ] **Down-event**: No actions execute on down-event unless essential
- [ ] **Up-event reversal**: Actions on up-event can be aborted or undone

#### Test 2.5.3: Label in Name - Level A
- [ ] **Visible label match**: Accessible name contains visible label text
- [ ] **Order matches**: Visible label appears at start of accessible name

#### Test 2.5.4: Motion Actuation - Level A
- [ ] **Device motion**: Functions triggered by motion have UI alternative
- [ ] **Can disable**: Motion actuation can be disabled

---

## 3. Understandable
*Information and UI operation must be understandable.*

### 3.1 Readable (Level A/AA)

#### Test 3.1.1: Language of Page ✅ Automated
- [ ] **Lang attribute**: `<html lang="en">` or appropriate language set
- [ ] **WinForms**: Culture/language settings properly configured

**Automated Test**: `tests/album-viewer.test.js::testLanguageAttribute()`

#### Test 3.1.2: Language of Parts
- [ ] **Lang changes**: `lang` attribute used for content in different language

### 3.2 Predictable (Level A/AA)

#### Test 3.2.1: On Focus
- [ ] **No context change**: Receiving focus doesn't automatically trigger change of context
- [ ] **Dropdowns**: Dropdowns don't auto-submit on selection

#### Test 3.2.2: On Input
- [ ] **No auto-submit**: Changing input doesn't automatically submit forms
- [ ] **Predictable**: Input changes don't cause unexpected context changes

#### Test 3.2.3: Consistent Navigation - Level AA
- [ ] **Navigation order**: Navigation menus appear in same order across pages
- [ ] **Consistent placement**: Navigation components consistently positioned

#### Test 3.2.4: Consistent Identification - Level AA
- [ ] **Same function**: Components with same functionality labeled consistently
- [ ] **Icons consistent**: Same icons used for same functions

### 3.3 Input Assistance (Level A/AA)

#### Test 3.3.1: Error Identification
- [ ] **Error detection**: Input errors automatically detected
- [ ] **Text description**: Errors described in text
- [ ] **Error location**: Error associated with specific field

#### Test 3.3.2: Labels or Instructions ✅ Automated
- [ ] **Labels provided**: All inputs have labels
- [ ] **Required fields**: Required fields clearly indicated
- [ ] **Format instructions**: Expected format provided (e.g., date format)

**Automated Test**: `tests/album-viewer.test.js::testFormLabels()`

#### Test 3.3.3: Error Suggestion - Level AA
- [ ] **Correction suggestions**: Suggestions provided when input errors detected
- [ ] **Security exception**: Unless suggestion compromises security

#### Test 3.3.4: Error Prevention (Legal, Financial, Data) - Level AA
- [ ] **Reversible**: Submissions can be reversed
- [ ] **Checked**: Data entered is validated for errors
- [ ] **Confirmed**: Confirmation page provided before final submission

---

## 4. Robust
*Content must be robust enough for interpretation by assistive technologies.*

### 4.1 Compatible (Level A/AA)

#### Test 4.1.1: Parsing
- [ ] **Valid HTML**: No duplicate IDs
- [ ] **Proper nesting**: Elements properly nested
- [ ] **Complete tags**: Start and end tags properly formed

#### Test 4.1.2: Name, Role, Value
- [ ] **Accessible names**: All UI components have accessible names
- [ ] **Correct roles**: ARIA roles accurately describe components
- [ ] **State/property**: States (checked, expanded, etc.) programmatically determinable
- [ ] **Updates notified**: Changes to states communicated to assistive technologies

#### Test 4.1.3: Status Messages - Level AA
- [ ] **Live regions**: Status messages use ARIA live regions
- [ ] **Success messages**: Success confirmations announced to screen readers
- [ ] **Progress updates**: Progress/busy states announced appropriately
- [ ] **Error announcements**: Errors announced without stealing focus

---

## Testing Tools & Methods

### Automated Testing Tools
- [ ] **axe DevTools**: Browser extension for automated WCAG checks
- [ ] **WAVE**: Web accessibility evaluation tool
- [ ] **Lighthouse**: Chrome DevTools accessibility audit
- [ ] **Pa11y**: Command-line accessibility testing
- [ ] **Color contrast analyzers**: WebAIM, Stark, Colour Contrast Analyser

### Manual Testing
- [ ] **Keyboard only**: Navigate entire app using only keyboard
- [ ] **Screen reader**: Test with NVDA (Windows), JAWS (Windows), or VoiceOver (Mac)
- [ ] **200% zoom**: Test at 200% browser zoom level
- [ ] **Mobile devices**: Test responsive layouts on actual devices
- [ ] **High contrast mode**: Test with Windows High Contrast mode
- [ ] **Text spacing**: Test with browser extension adjusting text spacing

### Screen Readers to Test
- [ ] **NVDA** (free, Windows) - latest version
- [ ] **JAWS** (Windows) - latest version
- [ ] **VoiceOver** (macOS/iOS) - built-in
- [ ] **TalkBack** (Android) - built-in
- [ ] **Narrator** (Windows) - built-in

### Browser/Platform Coverage
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)
- [ ] Mobile Safari (iOS)
- [ ] Chrome Mobile (Android)

---

## Test Execution Checklist

### Per Page/View Test
1. [ ] Run automated tools (axe, WAVE, Lighthouse)
2. [ ] Review and fix automated issues
3. [ ] Keyboard navigation test (no mouse)
4. [ ] Screen reader test (NVDA/JAWS)
5. [ ] Zoom to 200% test
6. [ ] Contrast verification
7. [ ] Focus indicator check
8. [ ] Mobile responsive test

### Application-Specific Tests

#### album-viewer (Web)
- [ ] Album list view accessibility
- [ ] Album detail views (if any)
- [ ] Navigation menu keyboard access
- [ ] Album images have alt text
- [ ] Background color setting doesn't affect contrast

#### adventureview (Web)
- [ ] Database query results table accessibility
- [ ] Form inputs labeled
- [ ] Error messages accessible
- [ ] Data table headers properly marked

#### FormsApp (WinForms)
- [ ] All controls have accessible names
- [ ] Tab order logical
- [ ] High contrast mode support
- [ ] Keyboard shortcuts documented
- [ ] Screen reader compatibility (Narrator)

---

## Issue Tracking Template

When logging accessibility issues:

```markdown
### Issue Title
**WCAG Criterion**: [e.g., 1.4.3 Contrast (Minimum)]
**Level**: [A / AA / AAA]
**Severity**: [Critical / High / Medium / Low]

**Location**: [Page/component/file]

**Description**: 
[Describe the issue]

**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]

**Expected Behavior**:
[What should happen]

**Actual Behavior**:
[What currently happens]

**Recommendation**:
[How to fix]

**Testing Method**: [Automated tool / Manual / Screen reader]
```

---

## Success Criteria

- [ ] All Level A criteria pass
- [ ] All Level AA criteria pass
- [ ] Zero critical/high severity issues
- [ ] Automated tool scores 95%+ on axe/Lighthouse
- [ ] Full keyboard navigation confirmed
- [ ] Screen reader testing completed with zero critical issues

---

## References
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [WebAIM Checklist](https://webaim.org/standards/wcag/checklist)
- [ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [Microsoft Accessibility Guidelines](https://docs.microsoft.com/en-us/windows/apps/design/accessibility/accessibility)

---

## 📚 Additional Documentation

- **[Quick Start Guide](accessibility-tests/QUICKSTART.md)** - Get started with automated testing
- **[Test Suite README](accessibility-tests/README.md)** - Detailed documentation on the test framework
- **[Test Implementation](accessibility-tests/tests/album-viewer.test.js)** - View the actual test code
- **[Test Utilities](accessibility-tests/utils/test-utils.js)** - Reusable helper functions
