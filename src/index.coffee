import Generic from "@dashkite/generic"
import Storage from "@dashkite/storage"
import Provider from "@dashkite/belmont/provider"
import { Router } from "@dashkite/url-router"
import { metaclass } from "@dashkite/joy/metaclass"

# TODO probably move metaclass to Provider
class Lakeshore extends metaclass Provider

  @defaults:

    get: ({ url }) ->
      if ( content = Storage.get url )?
        { description: "ok", content }
      else
        description: "not found"

    put: ({ url }, content ) ->
      Storage.set url, content
      { description: "ok", content }

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
      response = @methods.get { @url, @bindings }
      if response.description == "ok"
        @publish { name: "value", value: response.content }
      else
        @publish 
          name: response.description
          url: @url
    else
      @publish 
        name: "unsupported method"
        url: @url
        method: "get"

  put: ( value ) ->
    if @methods.put?
      response = @methods.put { @url, @bindings }, value
      if response.description == "ok"
        @publish { name: "value", value }
    else
      @publish 
        name: "unsupported method"
        url: @url
        method: "put"

  delete: ->
    if @methods.delete?
      response = @methods.delete { @url, @bindings }
      if response.description == "ok"
          @publish { name: "delete" }
    else
      @publish 
        name: "unsupported method"
        url: @url
        method: "delete"


  post: ( value ) ->
    if @methods.post?
      response = @methods.post { @url, @bindings }, value
      switch response.description
        # how do we map this to an event?
        # when "ok"
        # how do we map this to an event?
        # when "no content"
        when "created"
          @publish name: "create", value: response.content
          @get() if @methods.get?
    else
      @publish 
        name: "unsupported method"
        url: @url
        method: "post"

export default Lakeshore