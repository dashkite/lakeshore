# Recipes

## Mocking a Basic Read-Only Endpoint

Developers frequently need to simulate an API that returns read-only data before the real backend services are available. Lakeshore solves this by allowing creators to define static or dynamically generated mock responses for specific URL templates using custom handlers.

```coffeescript
import Providers from "@dashkite/belmont/providers"
import Lakeshore from "@dashkite/lakeshore"
import Resource from "@dashkite/belmont"

Providers.add "mock", Lakeshore

Lakeshore.register "mock://api/people/:id",
  get: ({ bindings }) ->
    # mock data retrieval logic goes here
    # data = fetchMockData bindings.id
    description: "ok"
    content: id: bindings.id, name: "Alice"

resource = await Resource.resolve template: "mock://api/people/123"
resource.get()
```

To implement a basic read-only mock:
1. Register Lakeshore as the concrete provider for your chosen URL protocol.
2. Call `Lakeshore.register` with the desired URL template and supply a `get` function.
3. Construct the response object within the `get` function, ensuring it includes a `description` indicating success (like `"ok"`) and the `content` payload.
4. Resolve the resource using Belmont and invoke the `get()` method to trigger the mock handler.

## Simulating a State-Mutating API

Beyond simple reads, developers must often mock endpoints that accept payloads and mutate state, such as creating or updating subordinate resources. Lakeshore enables this by supporting `post` and `put` methods in the registration object, allowing the mock to intercept data payloads and return creation states.

```coffeescript
import Lakeshore from "@dashkite/lakeshore"
import Resource from "@dashkite/belmont"

Lakeshore.register "mock://api/people",
  post: ({ url }, payload ) ->
    # resource creation logic goes here
    # newId = generateId()
    # persistMockData newId, payload
    description: "created"
    content: payload
    locator: name: "person", bindings: id: "456"

resource = await Resource.resolve template: "mock://api/people"
resource.post name: "Bob", email: "bob@example.com"
```

To create a mutating mock endpoint:
1. Provide a `post` or `put` function in the method object passed to `Lakeshore.register`.
2. Extract the `payload` from the second argument of the handler function.
3. Return a response indicating the result, utilizing `description: "created"` for new resources, alongside the updated `content` and an optional `locator`.
4. Invoke the mutating method on the resolved Belmont resource, passing the payload.

## Leveraging the Default Document Store

When prototyping rapidly, writing custom handlers for every single endpoint becomes tedious. Lakeshore provides a fallback mechanism that automatically handles CRUD operations using `@dashkite/storage`. This enables developers to use unregistered URLs as an instant, persistent local document store.

```coffeescript
import Resource from "@dashkite/belmont"

# Do not register a custom handler for this URL
resource = await Resource.resolve template: "mock://api/documents/789"

# The default put handler stores the payload locally
resource.put title: "Draft Proposal", status: "pending"

# The default get handler retrieves the payload from storage
resource.get()

# The default delete handler removes the payload from storage
resource.delete()
```

To utilize the default document store:
1. Ensure no custom handlers are registered for the target URL template.
2. Resolve the resource using the desired URL.
3. Invoke `put` with a payload to store the document in the local storage fallback.
4. Invoke `get` to retrieve the stored document, or `delete` to remove it entirely, without writing any explicit handler logic.

## Inspecting Internal Routing State

In complex simulation scenarios, creators may need to interrogate exactly how a requested URL was parsed and which handlers were bound to it. Lakeshore exposes the internal routing state directly on the instantiated provider object, making it easy to access the URL bindings and matched methods dynamically.

```coffeescript
import Resource from "@dashkite/belmont"

resource = await Resource.resolve template: "mock://api/people/123"

# access the extracted URL parameters directly
extractedId = resource.bindings.id

# inspect the resolved handler methods
hasCustomGet = typeof resource.methods.get == "function"
```

To inspect the routing state:
1. Resolve a specific resource URL using Belmont to obtain the instantiated Lakeshore provider object.
2. Access the `bindings` property to read the variables extracted from the URL template.
3. Access the `methods` property to inspect the specific HTTP handler functions bound to the resource.
4. Utilize this state to branch simulation logic dynamically based on the requested parameters.
