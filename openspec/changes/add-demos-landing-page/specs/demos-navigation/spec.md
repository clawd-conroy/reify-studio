## ADDED Requirements

### Requirement: Demos Landing Page

The system SHALL provide a landing page at `/demos` displaying all available demos as navigable cards.

#### Scenario: Landing page displays demo cards
- **WHEN** a user navigates to `/demos`
- **THEN** the page displays cards for each available demo (Counter, Todos)
- **AND** each card shows an icon placeholder, title, and description

#### Scenario: Root route redirects to demos
- **WHEN** a user navigates to `/`
- **THEN** the demos landing page is rendered

#### Scenario: Card links to demo
- **WHEN** a user clicks on a demo card
- **THEN** they are navigated to the demo's route (e.g., `/demos/counter`, `/demos/todos`)

### Requirement: Demo Card Display

Demo cards SHALL provide visual context about each demo's purpose and capabilities.

#### Scenario: Counter demo card content
- **WHEN** the Counter demo card is displayed
- **THEN** it shows a title "Counter Demo"
- **AND** it shows a description highlighting SSR vs LiveReact patterns
- **AND** it shows an icon placeholder in the header area

#### Scenario: Todos demo card content
- **WHEN** the Todos demo card is displayed
- **THEN** it shows a title "Todos Demo"
- **AND** it shows a description highlighting event-based render lifecycle and Ash form validation
- **AND** it shows an icon placeholder in the header area

#### Scenario: Card layout
- **WHEN** the demos landing page is rendered on a desktop viewport
- **THEN** cards display side-by-side in a horizontal layout
- **AND** cards have approximate dimensions of 300x400 pixels

### Requirement: Breadcrumb Navigation

Individual demo pages SHALL include breadcrumb navigation for easy return to the demos landing page.

#### Scenario: Counter demo breadcrumb
- **WHEN** a user is viewing `/demos/counter`
- **THEN** a breadcrumb is visible showing "Demos > Counter"
- **AND** clicking "Demos" navigates back to `/demos`

#### Scenario: Todos demo breadcrumb
- **WHEN** a user is viewing `/demos/todos`
- **THEN** a breadcrumb is visible showing "Demos > Todos"
- **AND** clicking "Demos" navigates back to `/demos`
