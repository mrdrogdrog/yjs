
text_types_uninitialized = require "../Types/TextTypes"
HistoryBuffer = require "../HistoryBuffer"
Engine = require "../Engine"
adaptConnector = require "../ConnectorAdapter"

#
# Framework for Text Datastructures.
#
class TextFramework

  #
  # @param {String} user_id Uniqe user id that defines this peer.
  # @param {Connector} Connector The connector defines how you connect to the other peers.
  #
  constructor: (user_id, @connector)->
    @HB = new HistoryBuffer user_id
    text_types = text_types_uninitialized @HB
    @types = text_types.types
    @engine = new Engine @HB, text_types.parser
    adaptConnector @connector, @engine, @HB, text_types.execution_listener

    beginning = @HB.addOperation new @types.Delimiter {creator: '_', op_number: '_beginning'} , undefined, undefined
    end =       @HB.addOperation new @types.Delimiter {creator: '_', op_number: '_end'}       , beginning, undefined
    beginning.next_cl = end
    beginning.execute()
    end.execute()
    first_word = new @types.WordType {creator: '_', op_number: '_'}, beginning, end
    @HB.addOperation(first_word).execute()

    uid_r = { creator: '_', op_number: "RM" }
    uid_beg = { creator: '_', op_number: "_RM_beginning" }
    uid_end = { creator: '_', op_number: "_RM_end" }
    beg = @HB.addOperation(new @types.Delimiter uid_beg, undefined, uid_end).execute()
    end = @HB.addOperation(new @types.Delimiter uid_end, beg, undefined).execute()
    @root_element = @HB.addOperation(new @types.ReplaceManager undefined, uid_r, beg, end).execute()
    @root_element.replace first_word, { creator: '_', op_number: 'Replaceable'}


  #
  # @return WordType
  #
  getSharedObject: ()->
    @root_element.val()

  #
  # Get the initialized connector.
  #
  getConnector: ()->
    @connector

  #
  # @see HistoryBuffer
  #
  getHistoryBuffer: ()->
    @HB

  #
  # Get the UserId from the HistoryBuffer object.
  # In most cases this will be the same as the user_id value with which
  # JsonFramework was initialized (Depending on the HistoryBuffer implementation).
  #
  getUserId: ()->
    @HB.getUserId()

  #
  # @see JsonType.val
  #
  val: ()->
    @getSharedObject().val()

  #
  # @see WordType.insertText
  #
  insertText: (pos, content)->
    @getSharedObject().insertText pos, content

  #
  # @see WordType.deleteText
  #
  deleteText: (pos, length)->
    @getSharedObject().deleteText pos, length

  #
  # @see WordType.bind
  #
  bind: (textarea)->
    @getSharedObject().bind textarea

  #
  # @see WordType.replaceText
  #
  replaceText: (text)->
    @getSharedObject().replaceText text

  #
  # @see Operation.on
  #
  on: ()->
    @root_element.on arguments...


module.exports = TextFramework
if window?
  if not window.Y?
    window.Y = {}
  window.Y.TextFramework = TextFramework
