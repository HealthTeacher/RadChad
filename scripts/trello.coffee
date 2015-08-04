# Description:
#   Display card details for a Trello URL
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_TRELLO_KEY - Trello application key
#   HUBOT_TRELLO_TOKEN - Trello API token
#
# Commands:
#   paste a Trello card URL where Hubot can hear you
#
# Author:
#   traviskroberts

module.exports = (robot) ->
  robot.hear /https\:\/\/trello\.com\/c\/(\w+)(?:\/.+)?/i, (msg) ->
    shortLink = msg.match[1]
    key = process.env.HUBOT_TRELLO_KEY
    token = process.env.HUBOT_TRELLO_TOKEN

    msg.http("https://api.trello.com/1/cards/#{shortLink}?fields=id,name,desc&key=#{key}&token=#{token}")
    .get() (err, res, body) ->
      return msg.send "Pivotal says: #{err}" if err
      return msg.send "Card not found!" if res.statusCode == 404

      try
        card = JSON.parse(body)
      catch e
        return msg.send "Error parsing Trello card body: #{e}"

      desc = card.desc.replace /\n/g, "\n> "

      message =  "> *#{card.name}*\n"
      message += "> #{desc}"
      msg.send message
