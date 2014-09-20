# Description:
#   Return a random phrase from SadChad
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot sadchad
#
# Author:
#   travisr

phrases = [
  "Eh, what's the point?"
  "That's what my ex-wife said."
  "How do you _think_ I am?"
  "What's it to you?"
  "Is it you that smells like booze, or me?"
  "Sorry, that's just the booze talkin'."
  "I don't really laugh much anymore..."
  "I guess I'll be working on Saturday...again."
  "20 years and not so much as a 'so long'."
  "My therapist says I have self-destructive tendencies."
  "My Hyundai broke down again."
  "Cheryl says I can't see the kids this weekend."
  "I dunno, maybe the milk went bad."
  "My best friend is the Chinese food delivery guy."
  "These damned divorce attorneys are bleeding me dry."
  "It's not so bad under the bridge."
  "I make an extra $50 a week selling my blood."
  "The only person who calls me more than debt collectors is my mom."
  "The heat went out in my van again."
  "My condo is being sprayed for bed bugs this weekend. Can I crash at your place?"
  "Sorry, gotta get back to my job as the shift manager at Arby's."
]

module.exports = (robot) ->
  robot.respond /sadchad/, (msg) ->
    msg.send msg.random(phrases)
