# Description
#   Find out whether a bigly event has happened yet. You'll need a Google Civic Information API key, and lot's of patience.
#
# Configuration:
#   CIVIC_API_KEY - Your Google Civic Information API key
#   BIGLY_ATTITUDE - 'downbeat' or 'upbeat' you'll work it out
#   BIGLY_GREAT_THINGS - Other great things that you want to make great again, besides America
#
# Notes:
#   Making Hubot Great Again
#
# Author:
#   Sam Bauers <sam@wopr.com.au>

CIVIC_API_KEY = process.env.CIVIC_API_KEY
BIGLY_ATTITUDE = process.env.BIGLY_ATTITUDE || 'downbeat'
BIGLY_GREAT_THINGS = process.env.BIGLY_GREAT_THINGS || ''
BIGLY_START_DATE = Date.UTC(2017, 0, 20, 17)
BIGLY_END_DATE = Date.UTC(2021, 0, 20, 17)

isTrumpPresident = (robot, msg) ->
  affectations = 'normal'
  if msg.match[1] == 'drumpf'
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

formatSuffix = (length, unit) ->
  switch length
    when 0 then return
    when 1 then return "#{length} #{unit}"
    else        return "#{length} #{unit}s"

formatDuration = (seconds) ->
  spm = 60
  sph = spm * 60
  spd = sph * 24
  spw = spd * 7

  w = Math.floor(seconds / spw)
  r = seconds % spw
  d = Math.floor(r / spd)
  r = r % spd
  h = Math.floor(r / sph)
  r = r % sph
  m = Math.floor(r / spm)
  s = r % spm

  units = {
    'week': w,
    'day': d,
    'hour': h,
    'minute': m,
    'second': s
  }
  parts = []
  for unit, length of units
    part = formatSuffix(length, unit)
    console.log(unit, length, part)
    if part
      parts.push(part)

  commas = parts[0...-1].join(', ')
  "#{commas}, and #{parts[-1..]}"

howLongHasTrumpBeenPresident = (msg) ->
  affectations = 'normal'
  if msg.match[1] == 'drumpf'
    affectations = 'trumpy'

  endured = formatDuration(Math.floor((Date.now() - BIGLY_START_DATE)/1000))
  remaining = formatDuration(Math.floor((BIGLY_END_DATE - Date.now())/1000))

  switch "#{BIGLY_ATTITUDE}:#{affectations}"
    when 'downbeat:trumpy'
      msg.send "Trump has been President for a yuge #{endured}. What crazy times we live in. Only #{remaining} to go. Sad. :slightly_frowning_face:"
    when 'upbeat:trumpy'
      msg.send "Trump has been President for the most amazing #{endured} the US has ever seen, ever. And I'm here to tell you folks, the next #{remaining} are going to be even better. :us:"
    when 'downbeat:normal'
      msg.send "Donald Trump has been president for #{endured} and his term ends in #{remaining} :slightly_frowning_face:"
    when 'upbeat:normal'
      msg.send ":us: Donald Trump has been president for #{endured} and his term ends in #{remaining} :us:"

module.exports = (robot) ->
  robot.hear /is(?: donald)? (trump|drumpf)(?: still)? president/i, (msg) ->
    isTrumpPresident(robot, msg)

  robot.hear /long has(?: donald)? (trump|drumpf) been president/i, (msg) ->
    howLongHasTrumpBeenPresident(msg)

  robot.hear /long(?:er)? (?:is|will)(?: donald)? (trump|drumpf)(?: going to| gonna)? be president/i, (msg) ->
    howLongHasTrumpBeenPresident(msg)

  great_things = [
    'america',
    robot.adapterName,
    robot.name
  ].concat(BIGLY_GREAT_THINGS.split(',')).join('|')
  great_things_regex = new RegExp "make (#{great_things}) great again", 'i'

  robot.hear great_things_regex, (msg) ->
    c = '_circle:'
    bc = ":large_blue#{c}"
    rc = ":red#{c}"
    wc = ":white#{c}"
    br = ((bc for [0..7]).concat (rc for [0..9])).join('') + "\n"
    bw = ((bc for [0..7]).concat (wc for [0..9])).join('') + "\n"
    ww = (wc for [0..17]).join('') + "\n"
    rr = (rc for [0..17]).join('') + "\n"
    msg.send br + bw + br + bw + br + bw + br + ww + rr + ww + rr + ww + rr + "There, #{msg.match[1]} is great again. Happy now?"
