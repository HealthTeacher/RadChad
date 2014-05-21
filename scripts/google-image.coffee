# Description:
#   A way to interact with the Google Images API.
#
# Commands:
#   hubot image <query> - The Original. Queries Google Images for <query> and returns a random top result.
#   hubot animate <query> - The same thing as `image`, except adds a few parameters to try to return an animated GIF instead.

module.exports = (robot) ->
  robot.respond /(image|img) (.*)/i, (msg) ->
    imageMe msg, msg.match[2], false, (url) ->
      msg.send url

  robot.respond /(animate) (.*)/i, (msg) ->
    imageMe msg, msg.match[2], true, (url) ->
      msg.send url

imageMe = (msg, query, animated, cb) ->
  q =
    v: '1.0'
    rsz: '8'
    q: query
    safe: 'active'
  q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
    .query(q)
    .get() (err, res, body) ->
      images = JSON.parse(body)
      images = images.responseData?.results
      if images?.length > 0
        image  = msg.random images
        cb "#{image.unescapedUrl}#.png"
      else
        cb "I got nothing."

