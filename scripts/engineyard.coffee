# Description:
#   Deploy to EngineYard Cloud
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_ENGINEYARD_TOKEN
#
# Commands:
#   hubot deploy <app_name> [migrate OR --migrate]
#
# Author:
#   traviskroberts

config =
  token: process.env.HUBOT_ENGINEYARD_TOKEN

appData =
  gn_staging:
    name: "GoNoodle Staging"
    app_id: 38264
    env_id: 75217
    ref: "staging"
  gn_production:
    name: "GoNoodle Producton"
    app_id: 38264
    env_id: 62192
    ref: "master"
  accounts_staging:
    name: "Accounts Staging"
    app_id: 38263
    env_id: 75218
    ref: "staging"
  accounts_production:
    name: "Accounts Producton"
    app_id: 38263
    env_id: 62189
    ref: "master"

module.exports = (robot) ->
  robot.hear /deploy ([\w]+)\s?(.*)?$/i, (msg) ->
    unless config.token
      msg.send "Please set the HUBOT_ENGINEYARD_TOKEN environment variable."
      return

    appConfig = appData[msg.match[1]]
    shouldMigrate = msg.match[2] == "migrate" || msg.match[2] == "--migrate"

    unless appConfig
      msg.send "Unknown app/environment: #{msg.match[1]}"
      return

    msg.http("https://cloud.engineyard.com/api/v2/apps/#{appConfig.app_id}/environments/#{appConfig.env_id}/deployments/deploy?deployment[ref]=#{appConfig.ref}&deployment[migrate]=#{shouldMigrate}")
    .header("X-EY-Cloud-Token", config.token)
    .post() (err, res, body) ->
      return msg.send "EngineYard responded with: #{err}" if err

      message = "Initiated deployment of *#{appConfig.name}*"
      message += " (with migrations)" if shouldMigrate
      msg.send message
