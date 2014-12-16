# Description:
#   Listen for a specific story from PivotalTracker
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_PIVOTAL_TOKEN
#   HUBOT_PIVOTAL_PROJECT_ID
#
# Commands:
#   paste a pivotal tracker link or type "sid-####" in the presence of hubot
#
# Author:
#   christianchristensen

Util = require "util"

module.exports = (robot) ->
  robot.hear /(sid-|SID-|pivotaltracker.com\/story\/show)/i, (msg) ->
    token = process.env.HUBOT_PIVOTAL_TOKEN
    projectId = process.env.HUBOT_PIVOTAL_PROJECT_ID
    storyId = msg.message.text.match(/\d+$/) # look for some numbers in the string

    message = "> *DEBUG INFORMATION*\n"
    message += "> Token: #{token}\n"
    message += "> Project ID: #{projectId}\n"
    message += "> Story ID: #{storyId}\n"
    message += "Full message received: #{msg.message.text}"
    msg.send message

    # msg.http("https://www.pivotaltracker.com/services/v5/projects/#{projectId}/stories/#{storyId}")
    # .headers("X-TrackerToken": token)
    # .get() (err, res, body) ->
    #   return msg.send "Pivotal says: #{err}" if err
    #   return msg.send "Story not found" if res.statusCode == 404 # No story found in this project

    #   try
    #     story = JSON.parse(body)
    #   catch e
    #     return msg.send "Error parsing pivotal story body: #{e}"

    #   desc = story.description.replace /\n/g, "\n> "

    #   message =  "> *#{story.name}*\n"
    #   message += "> _#{story.estimate} points_ | _#{story.current_state}_\n"
    #   message += "> #{desc}"
    #   msg.send message
