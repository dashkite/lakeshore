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
    url = "mock://existing-#{ generateAddress() }"
    Storage.set url, { title: "Existing", body: "I'm a teapot" }
    Lakeshore.register url,
      get: -> { description: "ok", content: { title: "Existing", body: "I'm a teapot" } }
      put: ( { url }, data ) ->
        exists = ( Storage.get url )?
        Storage.set url, data
        { description: "ok", exists, content: data }
      delete: ( { url } ) ->
        Storage.remove url
        { description: "ok" }
    resource = await Resource.resolve template: url
    { resource }

  missing: ->
    url = "mock://missing-#{ generateAddress() }"
    Storage.remove url
    resource = await Resource.resolve template: url
    { resource }

  creatable: ->
    url = "mock://creatable-#{ generateAddress() }"
    Storage.remove url
    Lakeshore.register url,
      post: ( _, data ) -> 
        { 
          description: "created"
          content: data
          locator: { name: "new-resource", bindings: { id: "123" } }
        }
      put: ( { url }, data ) -> 
        exists = ( Storage.get url )?
        Storage.set url, data
        { description: "ok", exists, content: data }
    resource = await Resource.resolve template: url
    { resource, data: { title: "New", body: "I'm a teapot" } }

  unsupported: ->
    url = "mock://readonly-#{ generateAddress() }"
    Lakeshore.register url,
      get: -> { description: "ok", content: { title: "Read-only", body: "I'm a teapot" } }
    resource = await Resource.resolve template: url
    { resource, method: "put" }

do ->

  print await test "Lakeshore", [
    conformance factory
  ]
