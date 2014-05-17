# Description:
#   gets Mitchell Deli's daily special tweet if it exists
#
# Dependencies:
#   "twit": "1.1.6"
#
# Configuration:
#   HUBOT_TWITTER_CONSUMER_KEY
#   HUBOT_TWITTER_CONSUMER_SECRET
#   HUBOT_TWITTER_ACCESS_TOKEN
#   HUBOT_TWITTER_ACCESS_TOKEN_SECRET
#
# Commands:
#   hubot special|sandwich|mitchell|sammich me - gets the latest tweet containing the word "special" from @MitchellDeli
#
# Author:
#   maxbeizer, very closely based off of the good work of KevinTraver
#

Twit = require "twit"
config =
  consumer_key:         process.env.HUBOT_TWITTER_CONSUMER_KEY
  consumer_secret:      process.env.HUBOT_TWITTER_CONSUMER_SECRET
  access_token:         process.env.HUBOT_TWITTER_ACCESS_TOKEN
  access_token_secret:  process.env.HUBOT_TWITTER_ACCESS_TOKEN_SECRET

module.exports = (robot) ->
  twit = undefined

  robot.respond /special|sandwich|mitchell me/i, (msg) ->
    unless config.consumer_key
      msg.send "Please set the HUBOT_TWITTER_CONSUMER_KEY environment variable."
      return
    unless config.consumer_secret
      msg.send "Please set the HUBOT_TWITTER_CONSUMER_SECRET environment variable."
      return
    unless config.access_token
      msg.send "Please set the HUBOT_TWITTER_ACCESS_TOKEN environment variable."
      return
    unless config.access_token_secret
      msg.send "Please set the HUBOT_TWITTER_ACCESS_TOKEN_SECRET environment variable."
      return

    unless twit
      twit = new Twit(config)

    twit.get "statuses/user_timeline",
      screen_name: 'mitchelldeli'
      count: 20
      include_rts: false
      exclude_replies: true
    , (err, reply) ->
      return msg.send "Error getting the tweets." if err
      hasSpecial = false
      date = new Date() # RadChad is in Central time and twitter is in GMT, but if Mitchell hasn't posted the special before midnight GMT, they've missed the lunch rush anyway.
      date = String(date).substr(0, 10)
      for tweet of reply
        if (/special/i.test(reply[tweet]['text'])) and (reply[tweet]['created_at'].substr(0, 10) == date)
          hasSpecial = true
          return msg.send "https://twitter.com/mitchelldeli/status/#{reply[tweet]['id_str']}"

      msg.send "Sorry, Mitchell Deli haven't posted the special today." if hasSpecial == false
