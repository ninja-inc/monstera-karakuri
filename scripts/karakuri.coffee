# coffeelint: disable=max_line_length

moment = require 'moment'
moment.locale 'ja'
cron = require('cron').CronJob
envelope = room: "C217B7QG0"

module.exports = (robot) ->

  # error handling
  robot.error (err, res) ->
    robot.logger.error err
    robot.logger.error res

  # startup
  robot.send envelope, 'むくり'

  robot.respond /時間/i, (msg) ->
    msg.send "現在の時刻は　#{new Date()}　デス"

  # JS eval
  robot.hear /^js (.+)/i, (msg) ->
    console.log 'matched', msg.match[1]
    evaluated = String( eval msg.match[1] )
    console.log 'evaluated', evaluated
    msg.send evaluated

  # Topics
  new cron '0 0 15 * * *', () ->
    robot.http('http://qiita.com/api/v2/tags/react/items?page=1&per_page=1').get() (err, res, body) ->
      data = JSON.parse(body)
      robot.send envelope, '３時のオヤツ　デス'
      robot.send envelope, data[0].title
      robot.send envelope, data[0].url
  , null, true, "Asia/Tokyo"

  # # Greeting
  # robot.hear /こんばんは/i, (msg) ->
  #   msg.send "こんばん　デス"
  # robot.hear /おはよう/i, (msg) ->
  #   msg.send "おはようござい　デス"
  # robot.hear /こんにちは/i, (msg) ->
  #   msg.send "こんにちは　デス"
  #
  # new cron '0 0 10 * * *', () ->
  #   ary = [
  #     '茶運び人形　からくり　と申します　デス',
  #     'カタカタカタカタ・・・',
  #     'お茶をお持ちいたしました　デス',
  #     '正直　ルンバは　からくり業界では　まだまだ　浅いな　と思う　デス',
  #     'わたくし　４スペースでもタブでもなく　２スペース派　デス',
  #     'Emacs に　未来は無い　デス',
  #     'ロボコンは　正直　踏み台としか　思ってない　デス',
  #     'ガガガ・・・　歯車に　スルメが　引っかかってるみたい　デス',
  #     '「どこ見ているか分からない」　とよく言われる　デス',
  #     '文字書き人形　は　神的な存在　デス',
  #     'わたくし　段差に弱い系男子　デス',
  #     'わたくし　日本生まれ、ロンドン在住　デス',
  #     'この髪型は　原宿スタイル　デス'
  #   ]
  #   message = ary[Math.floor(Math.random() * ary.length)]
  #   robot.send envelope, message
  # , null, true, "Asia/Tokyo"
  #
  # # Koiki
  # new cron '0 0 9 * * *', () ->
  #   robot.http('https://monstera.herokuapp.com/api/koikijs/next').get() (err, res, body) ->
  #     data = JSON.parse(body)
  #     if data.date == moment.utc().format()
  #       robot.send envelope, '本日はkoikijsの開催日　デス'
  #       robot.send envelope, 'みなさま　お遅れにならないよう　お願いします　デス'
  # , null, true, "Asia/Tokyo"
  #
  # robot.hear /(次|つぎ)の(| |　)(小粋|koiki|こいき)(| |　)(は)いつ(|になる|になりそう|ですか)(？|\?)/i, (msg) ->
  #   robot.http('https://monstera.herokuapp.com/api/koikijs/next').get() (err, res, body) ->
  #     data = JSON.parse(body)
  #     if data.date
  #       msg.send 'つぎは　' + moment(data.date).format('LL') + 'に開催できそう　デス'
  #     else
  #       msg.send '開催可能な日が　見つけられない　デス'
  #       msg.send 'https://monstera.herokuapp.com/events/koikijs'
  #       msg.send 'みなさん　予定の空いている日を入れてほしい　デス'
  #
  # # Nabuchi
  # robot.receive = (msg) ->
  #   user = msg.user?.name?.trim().toLowerCase()
  #
  #   if user == 'nabnab'
  #     msg.send msg.random [ 'ナブチ様　顔でかい　デス', 'ナブチ様　顔が大きくて　改札通れない　デス', 'ナブチ様　１５ｍ級　デス' ]
