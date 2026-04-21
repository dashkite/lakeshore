# Reference

## Lakeshore

The Lakeshore provider enables mock API resources with custom handlers. It extends `@dashkite/belmont/provider`.

### register
$register: template, handlers \to \emptyset$

Registers a set of mock handlers for a URL template.

```coffee
Lakeshore.register "mock://example/:id",
  get: ({ url, bindings }) ->
    { description: "ok", content: { id: bindings.id } }
```

### defaults

The default handlers used if no specific handler is registered for a URL. These use `LocalStorage` for persistence.

- `get`: Returns `{ description: "ok", content }` if the key exists, otherwise `{ description: "not found" }`.
- `put`: Stores the content and returns `{ description: "ok", content }`.
- `delete`: Removes the key and returns `{ description: "ok" }`.

### Methods

- `get`, `put`, `post`, `delete`: Execute the corresponding registered or default handler and publish the result as a topic event.
