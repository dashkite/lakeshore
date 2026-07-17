# Lakeshore

*A Belmont mock provider for simulating API resources.*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

Lakeshore provides a mock resource provider for the Belmont reactive resource manager. It enables creators to define custom request handlers mapped to URL templates, facilitating the simulation of complex API behaviors during development and testing without requiring a live backend.

## Features

- Integrates natively with the Belmont reactive resource model.
- Supports dynamic URL matching using URL templates.
- Persists mock state locally using the Storage module by default.
- Allows fine-grained mock behaviors for GET, PUT, POST, and DELETE methods.

## Installation

Install Lakeshore using pnpm:

```bash
pnpm install @dashkite/lakeshore
```

## Usage

This example demonstrates how to configure Lakeshore to mock an API endpoint and interact with it via Belmont.

```coffeescript
import Providers from "@dashkite/belmont/providers"
import Lakeshore from "@dashkite/lakeshore"
import Resource from "@dashkite/belmont"

# Register the Lakeshore provider for a custom protocol
Providers.add "mock", Lakeshore

# Define mock behavior for a specific route
Lakeshore.register "mock://api/greetings/:name",
  get: ({ bindings }) ->
    description: "ok"
    content: "Hello, #{bindings.name}!"

# Resolve the resource using Belmont
resource = await Resource.resolve
  template: "mock://api/greetings/:name"
  bindings: name: "World"

# Subscribe to resource updates
resource.subscribe ({ name, value }) ->
  console.log value # Hello, World!

# Trigger a fetch
resource.get()
```

## Other Resources

- [Reference](docs/reference.md)
- [Recipes](docs/recipes.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing](docs/testing.md)
