# Description:
#   Deploy to EngineYard Cloud
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_ENGINEYARD_TOKEN
#   HUBOT_GITHUB_TOKEN
#
# Commands:
#   hubot deploy <app_name> [migrate OR --migrate]
#
# Author:
#   traviskroberts

moment = require "moment"

config =
  eyToken: process.env.HUBOT_ENGINEYARD_TOKEN
  githubToken: process.env.HUBOT_GITHUB_TOKEN

ghBaseUrl = "https://api.github.com"
slackWebhook = "https://hooks.slack.com/services/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"

appData =
  gn_staging:
    name: "GoNoodle Staging"
    appId: 38264
    envId: 75217
    ref: "staging"
    repoName: "GoNoodle"
  gn_production:
    name: "GoNoodle Production"
    appId: 38264
    envId: 62192
    ref: "master"
    repoName: "GoNoodle"
  accounts_staging:
    name: "Accounts Staging"
    appId: 38263
    envId: 75218
    ref: "staging"
    repoName: "Accounts"
  accounts_production:
    name: "Accounts Production"
    appId: 38263
    envId: 62189
    ref: "master"
    repoName: "Accounts"

module.exports = (robot) ->
  robot.respond /deploy ([\w]+)\s?(.*)?$/i, (msg) ->
    unless config.eyToken
      msg.send "Please set the HUBOT_ENGINEYARD_TOKEN environment variable."
      return
    unless config.githubToken
      msg.send "Please set the HUBOT_GITHUB_TOKEN environment variable."
      return

    appConfig = appData[msg.match[1]]
    appConfig.shouldMigrate = msg.match[2] == "migrate" || msg.match[2] == "--migrate"
    appConfig.user = msg.message.user

    if [
      "david",
      "mwise",
      "natetallman",
      "stevencwarren",
      "travis",
      "zenworm"
    ].indexOf(appConfig.user.id) < 0
      msg.send "https://s3.amazonaws.com/f.cl.ly/items/2f20050g2n450S2J0Z02/orljyyqzdrqkdsl3viz1.gif"
      return

    unless appConfig
      msg.send "Unknown app/environment: #{msg.match[1]}"
      return

    msg.send "Initiating deployment!"

    if appConfig.ref == "master"
      notifySlack(msg, appConfig.name, "Creating tag on Github.")
      getLatestSha(msg, appConfig)
    else
      deployApp(msg, appConfig)

getLatestSha = (msg, appConfig) ->
  msg.http(ghBaseUrl)
  .path("repos/HealthTeacher/#{appConfig.repoName}/git/refs/heads/master?access_token=#{config.githubToken}")
  .header("Accept", "application/vnd.github.v3+json")
  .get() (err, res, body) ->
    data = JSON.parse(body)
    createTag(msg, appConfig, data.object.sha)

createTag = (msg, appConfig, sha) ->
  date = moment()
  formattedTimestamp = date.format("YYYYMMDDHHmmss")
  formattedTime = date.format("dddd, MMM DD YYYY h:mm A")
  isoTime = date.format("YYYY-MM-DDTHH:mm:ssZ")

  params =
    tag: "production-#{formattedTimestamp}"
    message: "Deploy on #{formattedTime}"
    object: sha
    type: "commit"
    tagger:
      name: "HTMachine"
      email: "it@healthteacher.com"
      date: isoTime

  reqBody = JSON.stringify(params)

  msg.http(ghBaseUrl)
  .path("repos/HealthTeacher/#{appConfig.repoName}/git/tags?access_token=#{config.githubToken}")
  .header("Accept", "application/vnd.github.v3+json")
  .post(reqBody) (err, res, body) ->
    data = JSON.parse(body)
    commitTag(msg, appConfig, data.sha, data.tag)

commitTag = (msg, appConfig, sha, tagName) ->
  params =
    ref: "refs/tags/#{tagName}"
    sha: sha

  reqBody = JSON.stringify(params)

  msg.http(ghBaseUrl)
  .path("repos/HealthTeacher/#{appConfig.repoName}/git/refs?access_token=#{config.githubToken}")
  .header("Accept", "application/vnd.github.v3+json")
  .post(reqBody) (err, res, body) ->
    deployApp(msg, appConfig)

deployApp = (msg, appConfig) ->
  msg.http("https://cloud.engineyard.com/api/v2/apps/#{appConfig.appId}/environments/#{appConfig.envId}/deployments/deploy?deployment[ref]=#{appConfig.ref}&deployment[migrate]=#{appConfig.shouldMigrate}")
  .header("X-EY-Cloud-Token", config.eyToken)
  .post() (err, res, body) ->
    return msg.send "EngineYard responded with: #{err}" if err

    message =  "Deployment initiated by #{appConfig.user.id}"
    message += " (with migrations)" if appConfig.shouldMigrate
    notifySlack(msg, appConfig.name, message, "#e3b333")

notifySlack = (msg, title, message, color="#CCC") ->
  payload =
    pretext: "Deployment Notification"
    color: color
    fields: [
      title: title
      value: message
    ]

  reqBody = JSON.stringify(payload)

  msg.http(slackWebhook).header("Content-Type", "application/json").post(reqBody)
