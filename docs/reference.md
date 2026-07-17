# Reference

## Lakeshore

The `Lakeshore` class extends the `@dashkite/belmont/provider` base class to supply mock API capabilities. It allows developers to register custom handlers for URL templates, intercepting resource requests that Belmont delegates to it.

### register

$register: template, methods \to \emptyset$

Registers a set of mock handler methods for a specified URL template. The `template` argument must be a valid URL template string (e.g., `mock://api/resources/:id`) which Belmont and Lakeshore use to match incoming resource requests. The `methods` argument is an object where keys are HTTP method names (such as `get`, `put`, `post`, `delete`) and values are the corresponding handler functions.

```coffeescript
import assert from "@dashkite/assert"
import Lakeshore from "@dashkite/lakeshore"

Lakeshore.register "mock://example/:id",
  get: ({ bindings }) ->
    description: "ok"
    content: id: bindings.id

assert.equal typeof Lakeshore.register, "function"
```

### defaults

$defaults \to handlers$

The default fallback handlers utilized if no specific handler matches the requested URL template. These default handlers (`get`, `put`, `delete`) utilize `@dashkite/storage` to persist state locally across requests, effectively acting as an in-memory document store. This allows developers to read and write mock data without explicitly registering handlers for every single URL.

```coffeescript
import assert from "@dashkite/assert"
import Lakeshore from "@dashkite/lakeshore"

assert.equal typeof Lakeshore.defaults.get, "function"
assert.equal typeof Lakeshore.defaults.put, "function"
```

### match

$match \to routing\_object$

Returns the routing object that corresponds to the currently requested resource URL. This object contains the resolved URL parameters and the associated handler methods. Lakeshore uses this internally to route the incoming request to the correct custom handler or fallback to `defaults`.

```coffeescript
import assert from "@dashkite/assert"

# Assuming `resource` is an instantiated Lakeshore provider
assert.equal typeof resource.match, "object"
```

### methods

$methods \to handlers$

Returns the HTTP handler methods (like `get`, `put`, `post`, `delete`) that are bound to the current resource. If the resource matches a registered template, this returns the custom methods provided during `register`. Otherwise, it returns the `defaults` object.

```coffeescript
import assert from "@dashkite/assert"

# Assuming `resource` is an instantiated Lakeshore provider
assert.equal typeof resource.methods, "object"
```

### bindings

$bindings \to parameters$

Returns the variables extracted from the URL template for the current resource. For example, if the template is `mock://users/:id` and the requested URL is `mock://users/123`, the bindings object will be `{ id: "123" }`.

```coffeescript
import assert from "@dashkite/assert"

# Assuming `resource` was resolved with `mock://users/123`
assert.deepEqual resource.bindings, { id: "123" }
```

### get

$get: \dashrightarrow \emptyset$

Executes the registered or default `get` handler for the resource. It evaluates the response and publishes the resulting value to the Belmont resource stream. If the response description is `"ok"`, it publishes the `content`. Otherwise, it publishes a failure or specific error state.

```coffeescript
import assert from "@dashkite/assert"

# Assuming `resource` is an instantiated Lakeshore provider
assert.ok resource.get
```

### put

$put: payload \dashrightarrow \emptyset$

Executes the registered or default `put` handler with the provided `payload`. It updates or creates the resource state. Depending on whether the resource previously existed, the handler should return a description of `"ok"` or `"created"`. The provider then publishes the updated value to the resource stream.

```coffeescript
import assert from "@dashkite/assert"

# Assuming `resource` is an instantiated Lakeshore provider
assert.ok resource.put
```

### post

$post: payload \dashrightarrow \emptyset$

Executes the registered or default `post` handler with the provided `payload`. This is typically used to create new subordinate resources. If the creation is successful, it publishes a `"created"` event along with the new content and an optional `locator` identifying the new resource.

```coffeescript
import assert from "@dashkite/assert"

# Assuming `resource` is an instantiated Lakeshore provider
assert.ok resource.post
```

### delete

$delete: \dashrightarrow \emptyset$

Executes the registered or default `delete` handler. It removes the resource from the underlying storage or mock state. Upon success, it publishes a `"deleted"` event to the resource stream, signaling subscribers that the resource is no longer available.

```coffeescript
import assert from "@dashkite/assert"

# Assuming `resource` is an instantiated Lakeshore provider
assert.ok resource.delete
```
