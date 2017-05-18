# Description
#   Find out whether a bigly event has happened yet. You'll need a Google Civic Information API key, and lot's of patience.
#
# Configuration:
#   CIVIC_API_KEY - Your Google Civic Information API key
#   BIGLY_ATTITUDE - 'downbeat' or 'upbeat' you'll work it out
#
# Notes:
#   Making Hubot Great Again
#
# Author:
#   Sam Bauers <sam@wopr.com.au>

CIVIC_API_KEY = process.env.CIVIC_API_KEY
BIGLY_ATTITUDE = process.env.BIGLY_ATTITUDE || 'downbeat'

isTrumpPresident = (robot, msg) ->
  affectations = 'normal'
  if msg.match[2] == 'drumpf'
    affectations = 'trumpy'

  url= "https://content.googleapis.com/civicinfo/v2/representatives/ocd-division%2Fcountry%3Aus?levels=country&recursive=false&roles=headOfState&alt=json&key=#{CIVIC_API_KEY}"
  robot.http(url, {'rejectUnauthorized': false})
    .header('Accept', 'application/json')
    .get() (err, _res, body) ->
      if err
        console.log "Could not GET from #{url}"
        console.log "The error was: #{err}"
        return false

      try
        data = JSON.parse body
      catch paresError
        console.log "Could not parse response body from #{url}"
        console.log "The error was: #{parseError}"
        return false

      unless data
        console.log "No data was retrieved from #{url}"
        return false

      president = data.officials[0].name
      trump_or_other = 'other'
      if president.match /trump/i
        trump_or_other = 'trump'

      switch "#{trump_or_other}:#{BIGLY_ATTITUDE}:#{affectations}"
        when 'trump:downbeat:trumpy' then msg.send 'Bigly... :slightly_frowning_face:'
        when 'trump:upbeat:trumpy'   then msg.send ':us: Bigly! :us:'
        when 'trump:downbeat:normal' then msg.send 'Yes... :slightly_frowning_face:'
        when 'trump:upbeat:normal'   then msg.send ':us: Yes! :us:'
        when 'other:downbeat:trumpy' then msg.send ":us: This is yuge! No! #{president} is now president. :us:"
        when 'other:upbeat:trumpy'   then msg.send "No... #{president} is now president. Sad."
        when 'other:downbeat:normal' then msg.send ":us: OMG! No! #{president} is now president. :us:"
        when 'other:upbeat:normal'   then msg.send "No... #{president} is now president :slightly_frowning_face:"
        else                              msg.send "I can't tell who is president right now. Google says it's #{president} though."

      return true

module.exports = (robot) ->
  robot.hear /is( donald)? (trump|drumpf)( still)? president\??/i, (msg) ->
    isTrumpPresident(robot, msg)

  great_things = [
    'america',
    robot.adapterName,
    robot.name
  ].join('|')
  great_things_regex = new RegExp "make (#{great_things}) great again", 'i'

  robot.hear great_things_regex, (msg) ->
    c = '_circle:'
    bc = ":large_blue#{c}"
    rc = ":red#{c}"
    wc = ":white#{c}"
    br = ((bc for [0..7]).concat (rc for [0..9])).join('') + "\n"
    bw = ((bc for [0..7]).concat (wc for [0..9])).join('') + "\n"
    ww = (wc for [0..16]).join('') + "\n"
    rr = (rc for [0..16]).join('') + "\n"
    msg.send br + bw + br + bw + br + bw + br + ww + rr + ww + rr + ww + rr + "There, #{msg.match[1]} is great again. Happy now?"
