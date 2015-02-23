# Description:
#   Event system related utilities
#
# Commands:
#   hubot fake event <event> - Triggers the <event> event for debugging reasons
#
# Events:
#   debug - {user: <user object to send message to>}

util = require 'util'

module.exports = (robot) ->

  robot.respond /whoami/i, (msg) ->
    message =  "> Name: #{msg.user.name}\n"
    message += "> RealName: #{msg.user.name}\n"
    message += "> Email: #{msg.user.profile.email}"
    msg.send message
