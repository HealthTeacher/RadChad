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
  robot.router.post '/github/webhook', (req, res) ->
    data   = if req.body.payload? then JSON.parse(req.body.payload) else req.body
    action = data.action
    label  = data.label

    if action == 'labeled' && label.name == 'needs-review'
      pr      = data.pull_request
      payload = {
        attachments: [
          {
            color: label.color,
            title: "##{pr.number} #{pr.title}",
            title_link: pr.html_url
            pretext: "*[#{data.repository.full_name}]* Pull request by *#{pr.user.login}* is ready for review!",
            text: pr.body,
            mrkdwn_in: ['pretext', 'text']
          }
        ]
      }

      robot.http('https://hooks.slack.com/services/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')
        .header('Content-Type', 'application/json')
        .post(JSON.stringify(payload))

    res.send 'OK'
