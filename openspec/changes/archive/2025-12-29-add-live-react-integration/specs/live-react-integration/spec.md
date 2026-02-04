## ADDED Requirements

### Requirement: React Component Rendering

The system SHALL render React components within LiveView templates using the `<.react>` component helper.

#### Scenario: Basic component rendering
- **WHEN** a LiveView template includes `<.react name="Counter" count={@count} />`
- **THEN** the Counter React component renders with the `count` prop set to the LiveView assign value

#### Scenario: Component hydration on page load
- **WHEN** a page with React components loads
- **THEN** React components hydrate and become interactive without requiring additional server requests

### Requirement: Client-to-Server Events (pushEvent)

The system SHALL allow React components to send events to the LiveView server via the `pushEvent` callback.

#### Scenario: Push event from React component
- **WHEN** a React component calls `pushEvent("action_name", {key: "value"})`
- **THEN** the LiveView receives the event via `handle_event("action_name", %{"key" => "value"}, socket)`

#### Scenario: Event naming convention
- **WHEN** React components push events
- **THEN** event names SHALL use snake_case following the verb_noun pattern (e.g., `create_todo`, `toggle_item`)

### Requirement: Server-to-Client Events (handleEvent)

The system SHALL allow LiveView to push events to React components via the `handleEvent` callback registration.

#### Scenario: Server pushes event to component
- **WHEN** LiveView calls `push_event(socket, "event_name", payload)`
- **THEN** the React component's registered `handleEvent("event_name", callback)` receives the payload

#### Scenario: Event handler cleanup
- **WHEN** a React component unmounts
- **THEN** registered event handlers are automatically cleaned up to prevent memory leaks

### Requirement: TypeScript Support

The system SHALL support TypeScript for React components with strict mode enabled.

#### Scenario: TypeScript compilation
- **WHEN** a `.tsx` file is added to `assets/react-components/`
- **THEN** the build system compiles it with strict type checking

#### Scenario: Props type safety
- **WHEN** a component defines a props interface
- **THEN** TypeScript enforces prop types at compile time

### Requirement: Hot Module Replacement

The system SHALL support Hot Module Replacement (HMR) for React components in development.

#### Scenario: Component update without refresh
- **WHEN** a React component file is saved in development
- **THEN** the component updates in the browser without a full page refresh
- **AND** component state is preserved where possible (React Fast Refresh behavior)

### Requirement: Tailwind CSS Integration

React components SHALL be able to use Tailwind CSS classes for styling.

#### Scenario: Tailwind classes in React
- **WHEN** a React component uses `className="bg-primary text-white p-4"`
- **THEN** the Tailwind CSS styles are applied correctly

#### Scenario: daisyUI components
- **WHEN** a React component uses daisyUI classes like `className="btn btn-primary"`
- **THEN** the daisyUI component styles are applied correctly

### Requirement: Component Registry

React components SHALL be registered in a central index file for LiveView discovery.

#### Scenario: Component registration
- **WHEN** a new React component is created
- **THEN** it must be exported from `assets/react-components/index.tsx` to be available in LiveView

#### Scenario: Component not found
- **WHEN** a LiveView references a component name not in the registry
- **THEN** a clear error message indicates the missing component
