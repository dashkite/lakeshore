import assert from "@dashkite/assert"
import {test, success} from "@dashkite/amen"
import print from "@dashkite/amen-console"
import Resource from "@dashkite/belmont"
import Storage from "@dashkite/storage"
import Lakeshore from "../src"
import conformance from "@dashkite/belmont/test/conformance"

# Add Lakeshore as a provider for mock schemes
import Providers from "@dashkite/belmont/providers"
Providers.add "mock", Lakeshore

generateAddress = -> Math.random().toString(36)[ 2.. ]

factory =

  existing: ->
    do ({ url, data } = {}) ->
      url = "mock://existing/#{ generateAddress() }"
      data = title: "Existing", body: "I'm a teapot"
      Storage.set url, data
      resource = await Resource.resolve template: url
      { resource }

  missing: ->
    do ({ url } = {}) ->
      url = "mock://missing/#{ generateAddress() }"
      resource = await Resource.resolve template: url
      { resource }

  creatable: ->
    do ({ url, data } = {}) ->
      url = "mock://creatable/#{ generateAddress() }"
      data = title: "New", body: "I'm a teapot"
      Storage.remove url
      Lakeshore.register url,
        post: ( _, data ) -> 
          description: "created"
          content: data
          locator: name: "new", bindings: foo: "bar"
      resource = await Resource.resolve template: url
      { resource, data }

  unsupported: ->
    do ({ url, data } = {}) ->
      url = "mock://readonly/#{ generateAddress() }"
      data = title: "Read me", body: "I'm a teapot"
      Storage.set url, data
      Lakeshore.register url,
        get: -> data
      resource = await Resource.resolve template: url
      { resource, method: "put" }

do ->

  print await test "Lakeshore", [
    conformance factory
  ]
