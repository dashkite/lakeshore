import Generic from "@dashkite/generic"
import Storage from "@dashkite/storage"
import Provider from "@dashkite/belmont/provider"
import { Router } from "@dashkite/url-router"

Normalize =
  name: ( string ) -> string.toLowerCase().replace /\s+/g, "-"

class Lakeshore extends Provider

  @defaults:

    get: ({ url }) ->
      if ( content = Storage.get url )?
        { description: "ok", content }
      else
        { description: "not found" }

    put: ({ url }, content ) ->
      exists = ( Storage.get url )?
      Storage.set url, content
      { description: "ok", exists }

    delete: ({ url }) ->
      Storage.remove url
      { description: "ok" }

  @register: ( template, methods ) ->
    @_resources ?= Router.make()
    @_resources.add { template, data: { methods }}


  @getters

    match: ->
      @_match ?= do =>
        if ( match = @constructor._resources.match @url )?
          { bindings, data: { methods }} = match
          { bindings, methods }
        else
          methods: @constructor.defaults

    methods: -> @match.methods

    bindings: -> @match.bindings

  get: ->
    if @methods.get?
      response = await @methods.get { @url, @bindings }
      if response.description == "ok"
        @publish name: "value", scope: "resource", value: response.content
      else
        name = Normalize.name response.description
        @publish { name, scope: "response", url: @url }
        @publish name: "failure", scope: "response", response: response
    else
      @publish
        name: "method-not-allowed"
        scope: "request"
        url: @url
        method: "get"
      @publish
        name: "failure"
        scope: "request"
        response: description: "method-not-allowed"

  put: ( value ) ->
    if @methods.put?
      response = await @methods.put { @url, @bindings }, value
      switch response.description
        when "ok"
          if response.exists
            @publish name: "value", scope: "resource", value: ( response.content ? value )
          else
            @publish name: "created", scope: "resource", value: ( response.content ? value )
        when "created"
          @publish name: "created", scope: "resource", value: ( response.content ? value )
        else
          name = Normalize.name response.description
          @publish { name, scope: "response", value: ( response.content ? value ) }
          @publish name: "failure", scope: "response", response: response
    else
      @publish
        name: "method-not-allowed"
        scope: "request"
        url: @url
        method: "put"
      @publish
        name: "failure"
        scope: "request"
        response: description: "method-not-allowed"

  delete: ->
    if @methods.delete?
      response = await @methods.get { @url, @bindings }
      if response.description == "ok"
        @publish name: "delete", scope: "resource"
      else
        name = Normalize.name response.description
        @publish { name, scope: "response", url: @url }
        @publish name: "failure", scope: "response", response: response
    else
      @publish
        name: "method-not-allowed"
        scope: "request"
        url: @url
        method: "delete"
      @publish
        name: "failure"
        scope: "request"
        response: description: "method-not-allowed"


  post: ( value ) ->
    if @methods.post?
      response = await @methods.post { @url, @bindings }, value
      switch response.description
        when "ok", "no content"
          @publish name: "value", scope: "resource", value: ( response.content ? value )
        when "created"
          @publish 
            name: "created"
            scope: "resource"
            value: ( response.content ? value )
            locator: response.locator
        else
          name = Normalize.name response.description
          @publish { name, scope: "response", value: ( response.content ? value ) }
          @publish name: "failure", scope: "response", response: response
    else
      @publish
        name: "method-not-allowed"
        scope: "request"
        url: @url
        method: "post"
      @publish
        name: "failure"
        scope: "request"
        response: description: "method-not-allowed"

export default Lakeshore
