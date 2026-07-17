# Technical Notes

### RMVC+R Architecture and Reactive Resources

Lakeshore operates as a core component within the RMVC+R (Reactive Model-View-Controller + Resources) architecture. This paradigm treats an entire application as a set of interacting event streams and logical resources. By abstracting data access into reactive event streams, developers decouple application logic from transport protocols. Components subscribe to data changes rather than fetching data imperatively, establishing a clean separation of concerns.

### Belmont Integration

Lakeshore functions as a specialized provider for Belmont, the reactive resource manager in the DashKite ecosystem. Belmont handles the wiring for the Reactive Resource Model by mapping abstract resource locators to concrete providers. Creators register Lakeshore with Belmont to manage specific URL protocols (like `mock://`). Belmont then delegates all resource operations (GET, PUT, POST, DELETE) for that protocol to Lakeshore. This integration enables developers to replace a live HTTP provider with a Lakeshore mock provider while keeping the application's core resource logic completely intact.

### LocalStorage Persistence

By default, Lakeshore uses `@dashkite/storage` to wrap the browser's native [LocalStorage API](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage) as the underlying mechanism for its fallback handlers. This supplies a persistent state store without a database backend. Simulated API resources maintain their state across page reloads and requests during development. This approach closely mimics real backend data persistence, making it highly effective for simulating state-mutating requests entirely within the browser.

### Utility of a Mock Interface for Testing

Developing against a mock interface offers significant utility for front-end testing and rapid prototyping. Lakeshore enables developers to define dynamic URL templates and supply custom request handlers. This capability facilitates the simulation of edge cases, error states, and complex API behaviors long before the actual backend services are available. When used during automated testing, Lakeshore isolates the client application from network latency and unreliability, yielding fast and deterministic test suites.
