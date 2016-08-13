module.exports = (robot) ->
  robot.hear /なぶち/i, (res) ->
    res.send "ナブチ様　顔でかいデス"
  robot.hear /こんにちは/i, (res) ->
    res.send "こんにちは　デス"
