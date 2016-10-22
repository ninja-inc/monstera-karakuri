# coffeelint: disable=max_line_length

girl = room: "C2L1Y13R7" # girl

module.exports = (robot) ->

  getGirls = () ->
    girlApi = 'http://bjin.me/api/?type=rand&count=1&format=json'
    robot.http(girlApi)
      .get() (err, res, body) ->
        girls = JSON.parse(body)
        robot.send girl, "今日の美女は　こちらデス"
        attachments = []
        girls.map (data) ->
          imageURL = data.thumb.replace(/^https\:\/\//, '')
          attachments.push({
            "color": "#36a64f",
            "title": "#{data.category}",
            "text": "#{data.category}",
            "image_url": "https://images.weserv.nl/?url=#{imageURL}&w=200&h=200",
            "footer": "#{data.link}"
          })
        json = JSON.stringify({attachments: attachments});
        payload = "payload=" + encodeURIComponent(json)
        robot.http(process.env.HUBOT_SLACK_INCOMING_WEBHOOK_GOHAN)
          .header('content-type', 'application/x-www-form-urlencoded')
          .post(payload) (err, res, body) ->
            console.log err

  # Direct message
  robot.hear /^(美女)$/, () ->
    getGirls null, true, "Asia/Tokyo"