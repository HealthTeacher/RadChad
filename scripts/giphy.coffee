# Description:
#   A way to search images on giphy.com
#
# Configuration:
#   HUBOT_GIPHY_API_KEY
#
# Commands:
#   hubot gif <query> - Returns an animated gif matching the requested search term.

giphy =
  api_key: process.env.HUBOT_GIPHY_API_KEY
  base_url: 'http://api.giphy.com/v1'

module.exports = (robot) ->
  robot.respond /(gif|giphy)( me)? (.*)/i, (msg) ->
    giphyMe msg, msg.match[3], (url) ->
      msg.send url

giphyMe = (msg, query, cb) ->
  msg.http("#{giphy.base_url}/gifs/search")
    .query
      q: query
      api_key: giphy.api_key
    .get() (err, res, body) ->
      response = undefined
      try
        response = JSON.parse(body)
        results = response.data
        if results.length > 0
          resultSubset = results.slice(0, 5)
          item = msg.random resultSubset
          cb item.images.original.url
        else
          cb "Sorry, couldn't find anything..."

      catch e
        response = undefined
        cb 'Error'

      return if response is undefined
