create = require 'lodash/create'
isObject = require 'lodash/isObject'
isFunction = require 'lodash/isFunction'
every = require 'lodash/every'

XMLNode = require './XMLNode'
XMLAttribute = require './XMLAttribute'
XMLProcessingInstruction = require './XMLProcessingInstruction'

# Represents an element of the XML document
module.exports = class XMLElement extends XMLNode


  # Initializes a new instance of `XMLElement`
  #
  # `parent` the parent node
  # `name` element name
  # `attributes` an object containing name/value pairs of attributes
  constructor: (parent, name, attributes) ->
    super parent

    if not name?
      throw new Error "Missing element name"

    @name = @stringify.eleName name
    @children = []
    @instructions = []
    @attributes = {}

    @attribute attributes if attributes?


  # Creates and returns a deep clone of `this`
  #
  clone: () ->
    clonedSelf = create XMLElement.prototype, @

    # remove document element
    if clonedSelf.isRoot
      clonedSelf.documentObject = null

    # clone attributes
    clonedSelf.attributes = {}
    for own attName, att of @attributes
      clonedSelf.attributes[attName] = att.clone()

    # clone processing instructions
    clonedSelf.instructions = []
    for pi in @instructions
      clonedSelf.instructions.push pi.clone()

    # clone child nodes
    clonedSelf.children = []
    @children.forEach (child) ->
      clonedChild = child.clone()
      clonedChild.parent = clonedSelf
      clonedSelf.children.push clonedChild

    return clonedSelf


  # Adds or modifies an attribute
  #
  # `name` attribute name
  # `value` attribute value
  attribute: (name, value) ->
    name = name.valueOf() if name?

    if isObject name # expand if object
      for own attName, attValue of name
        @attribute attName, attValue
    else
      value = value.apply() if isFunction value
      if not @options.skipNullAttributes or value?
        @attributes[name] = new XMLAttribute @, name, value

    return @


  # Removes an attribute
  #
  # `name` attribute name
  removeAttribute: (name) ->
    if not name?
      throw new Error "Missing attribute name"
    name = name.valueOf()

    if Array.isArray name # expand if array
      for attName in name
        delete @attributes[attName]
    else
      delete @attributes[name]

    return @


  # Adds a processing instruction
  #
  # `target` instruction target
  # `value` instruction value
  instruction: (target, value) ->
    target = target.valueOf() if target?
    value = value.valueOf() if value?

    if Array.isArray target # expand if array
      for insTarget in target
        @instruction insTarget
    else if isObject target # expand if object
      for own insTarget, insValue of target
        @instruction insTarget, insValue
    else
      value = value.apply() if isFunction value
      instruction = new XMLProcessingInstruction @, target, value
      @instructions.push instruction
    return @


  # Converts the XML fragment to string
  #
  # `options.pretty` pretty prints the result
  # `options.indent` indentation for pretty print
  # `options.offset` how many indentations to add to every line for pretty print
  # `options.newline` newline sequence for pretty print
  # `options.allowEmpty` do not self close empty element tags
  toString: (options) ->
    @options.writer.set(options).element @


  # Aliases
  att: (name, value) -> @attribute name, value
  ins: (target, value) -> @instruction target, value
  a: (name, value) -> @attribute name, value
  i: (target, value) -> @instruction target, value
