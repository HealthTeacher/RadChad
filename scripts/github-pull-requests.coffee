# Description:
#   Handle github webhooks and notify Slack when necessary
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# URLS:
#   /github/webhook

module.exports = (robot) ->
  robot.router.post('/github/webhook', (req, res) ->
    token = process.env.HUBOT_SLACK_BOT_TOKEN
    userMap = {
      dcalhoun: '@david'
      DylanAndrews: '@dylanandrews'
      jchristianhall: '@christianhall'
      jerrysims07: '@jerrysims07'
      lomteslie: '@tom'
      natetallman: '@natetallman'
      stevencwarren: '@stevencwarren'
      traviskroberts: '@travis'
      zenworm: '@zenworm'
    }

    data = if req.body.payload? then JSON.parse(req.body.payload) else req.body

    if data.action == 'review_requested'
      pr = data.pull_request
      pr.requested_reviewers.forEach((reviewer) ->
        username = userMap[reviewer.login]
        messageAttachment = [
          {
            color: '#cccccc',
            fallback: "A pull request from #{pr.user.login} needs your review!"
            pretext: 'The following pull request needs your review!',
            author_name: pr.user.login,
            author_link: pr.user.url,
            title: "[#{pr.head.repo.full_name}] ##{pr.number} - #{pr.title}",
            title_link: pr.html_url,
            text: pr.body
          }
        ]

        robot.http('https://slack.com/api/chat.postMessage')
          .header('Accept', 'application/json')
          .query({
            token: token
            channel: username
            attachments: JSON.stringify(messageAttachment)
            as_user: false
            username: 'github-pr'
            icon_url: 'https://assets-gnp-ssl.gonoodle.com/slack-assets/github-octocat-icon.png'
          })
          .get()((err, resp, body) ->
            res.send('OK')
          )
      )
    else
      res.send('OK')
  )
