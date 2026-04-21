# Lakeshore

*Broadway provider for mock APIs*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

## Purpose

Lakeshore is a mock provider for Belmont that enables simulated API resources. It allows you to define handlers for URL templates, making it easy to mock complex API behaviors during development or testing.

## Installation

Use your favorite package manager to install `@dashkite/lakeshore`.

## Usage

```coffee
import Providers from "@dashkite/belmont/providers"
import Lakeshore from "@dashkite/lakeshore"
import Resource from "@dashkite/belmont"

# Register Lakeshore for a 'mock' protocol
Providers.add "mock", Lakeshore

# Define a mock resource handler
Lakeshore.register "mock://api/greetings/:name",
  get: ({ url, bindings }) ->
    { description: "ok", content: "Hello, #{bindings.name}!" }

# Use the mock resource
resource = await Resource.resolve
  template: "mock://api/greetings/:name"
  bindings: { name: "World" }

resource.subscribe ({ name, value }) ->
  console.log value # Hello, World!

resource.get()
```

## Other Resources

- [Reference](docs/reference.md)

## Status

Not suitable for production use. Please report bugs and feature requests via the issue tracker.
