# coffeelint: disable=max_line_length

moment = require 'moment'
moment.locale 'ja'
cron = require('cron').CronJob

module.exports = (robot) ->

  # Nabuchi
  robot.receive = (msg)->
    user = msg.user?.name?.trim().toLowerCase()

    if user == 'nabnab'
      msg.send "ナブチ様　顔でかいデス"

  # Topics
  new cron '0 0 15 * * *', () ->
    robot.http('http://qiita.com/api/v2/tags/react/items?page=1&per_page=1').get() (err, res, body) ->
      data = JSON.parse(body)
      robot.send('３時のオヤツ　デス')
      robot.send(data[0].title)
      robot.send(data[0].url)
  , null, true, "Asia/Tokyo"

  # Greeting
  robot.hear /こんばんわ/i, (msg) ->
    msg.send "こんばん　デス"
  robot.hear /おはよう/i, (msg) ->
    msg.send "おはようござい　デス"
  robot.hear /こんにちは/i, (msg) ->
    msg.send "こんにちは　デス"

  new cron '* * * * * *', () ->
    robot.send robot.random [
      '茶運び人形　からくり　と申します　デス',
      'カタカタカタカタ・・・',
      'お茶をお持ちいたしました　デス',
      'ルンバは　からくり業界では　中の上くらい　デス'
    ]
  , null, true, "Asia/Tokyo"

  # Koiki
  new cron '0 0 9 * * *', () ->
    robot.http('https://monstera.herokuapp.com/api/koikijs/next').get() (err, res, body) ->
      data = JSON.parse(body)
      if data.date == moment.utc().format()
        robot.send('本日はkoikijsの開催日　デス')
        robot.send('みなさま　お遅れにならないよう　よろしく　デス')
  , null, true, "Asia/Tokyo"

  robot.hear /(次|つぎ)の(| |　)(小粋|koiki|こいき)(| |　)(は)いつ(|になる|になりそう|ですか)(？|\?)/i, (msg) ->
    robot.http('https://monstera.herokuapp.com/api/koikijs/next').get() (err, res, body) ->
      data = JSON.parse(body)
      if data.date
        msg.send('つぎは　' + moment(data.date).format('LL') + 'に開催できそう　デス')
      else
        msg.send('開催可能な日が　見つけられない　デス')
        msg.send('https://monstera.herokuapp.com/events/koikijs')
        msg.send('みなさん　予定の空いている日を入れてほしい　デス')
