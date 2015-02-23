# Description:
#   Event system related utilities
#
# Commands:
#   hubot whoami - Responds with information about the user

util = require 'util'

module.exports = (robot) ->

  robot.respond /whoami/i, (msg) ->
    msg.send util.inspect(msg.message.user)
