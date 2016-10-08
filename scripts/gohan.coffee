# coffeelint: disable=max_line_length

moment = require 'moment'
moment.locale 'ja'
cron = require('cron').CronJob
gohan = room: "C2L1Y13R6" # gohan

module.exports = (robot) ->

  getFoods = (daynight, cafeteriaId) ->
     mealTime = {
       'ひる': 1,
       '昼': 1,
       'よる': 2,
       '夜': 2,
       'ばん': 2,
       '晩': 2
     }[daynight]
    cafeteriaApi = 'https://rakuten-towerman.azurewebsites.net/towerman-restapi/rest/cafeteria/menulist'
    robot.http(cafeteriaApi)
      .query(menuDate: toYYYYMMDD(new Date()), mealTime: mealTime, cafeteriaId: cafeteriaId)
      .get() (err, res, body) ->
        foods = JSON.parse(body)['data']
        sender envelope, "本日の#{daynight}ごはん　#{cafeteriaId}は　こちらデス"
        attachments = []
        foods.map (data) ->
          imageURL = data.imageURL.replace(/^https\:\/\//, '')
          price = if data.price > 0 then ", #{data.price}円" else ""
          attachments.push({
            "color": "#36a64f",
            "title": "#{data.menuType} (#{cafeteriaId})",
            "text": "#{data.title}",
            "image_url": "https://images.weserv.nl/?url=#{imageURL}&w=200&h=200",
            "footer": "#{data.calories} kcal #{price}"
          })
          payload = JSON.stringify({attachments: attachments});
          robot.http(process.env.HUBOT_SLACK_INCOMING_WEBHOOK)
            .post("payload={#{payload}}")

  # Direct message
  robot.hear /^(|ひる|昼|よる|夜|ばん|晩)(ごはん|ご飯|めし|飯)( |　)?(9|22)?F?$/i, (msg) ->
     toYYYYMMDD = (date) ->
       return date.getFullYear() + ('0' + (date.getMonth() + 1)).slice(-2) + ('0' + date.getDate()).slice(-2)

     daynight = if msg.match[1] then msg.match[1] else
                if new Date().getHours() < 15 then 'ひる' else 'よる'

     floor = if msg.match[4] then msg.match[4] else '9'
     cafeteriaId = floor.match(/^(\d+)/)[1] + 'F'

     getFoods daynight, cafeteriaId

  new cron '0 0 11 * * *', () ->
    getFoods '昼', '9F'
  , null, true, "Asia/Tokyo"

  new cron '0 0 19 * * *', () ->
    getFoods '夜', '9F'
  , null, true, "Asia/Tokyo"
