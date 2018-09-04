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
  "How do you _think_ I am?"
  "What's it to you?"
  "Is it you that smells like booze, or me?"
  "Sorry, that's just the booze talkin'."
  "I don't really laugh much anymore..."
  "I guess I'll be working on Saturday...again."
  "My therapist says I have self-destructive tendencies."
  "My Hyundai broke down again."
  "I dunno, maybe the milk went bad."
  "My best friend is the Chinese food delivery guy."
  "It's not so bad under the bridge."
  "I make an extra $50 a week selling my blood."
  "The only person who calls me more than debt collectors is my mom."
  "The heat went out in my van again."
  "My condo is being sprayed for bed bugs this weekend. Can I crash at your place?"
  "Sorry, gotta get back to my job as the shift manager at Arby's."
  "I gave a hobo some change today. He gave it back and said I looked like I needed it more."
  "I think happiness is about as real as The Little Mermaid"
  "Spoiled milk is only bad if you let yourself give in to standards."
  "Sorry I missed your call. My phone was disconnected...again"
  "My favorite mixed drink is rum, sour milk, and regret."
  "I fell asleep in the alley behind O'Charley's...again"
  "I got banned from Dave & Buster's this weekend."
]

module.exports = (robot) ->
  robot.respond /sadchad/, (msg) ->
    msg.send msg.random(phrases)
