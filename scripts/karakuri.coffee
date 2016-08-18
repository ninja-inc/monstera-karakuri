# coffeelint: disable=max_line_length

moment = require 'moment'
moment.locale 'ja'
cron = require('cron').CronJob
envelope = room: "C0JHEPQ94" # general
taka66 = room: "C0JHEPQ94", user: "U0JH92D60" # taka66
# envelope = room: "C217B7QG0" # test

module.exports = (robot) ->

  # error handling
  robot.error (err, res) ->
    robot.logger.error err
    robot.logger.error res

  # startup
  robot.send envelope, 'むくり'
  ary = [
    '茶運び人形　からくり　と申します　デス',
    'カタカタカタ・・・',
    'カタカタカタ・・・　お茶をお持ちいたしました　デス',
    '正直　ルンバは　からくり業界では　まだまだ　浅いな　と思う　デス',
    'わたくし　４スペースでもタブでもなく　２スペース派　デス',
    'Emacs に　未来は無い　デス',
    'ロボコンは　正直　踏み台としか　思ってない　デス',
    'ガガガ・・・　歯車に　スルメが　引っかかってるみたい　デス',
    '「どこ見ているか分からない」　とよく言われる　デス',
    '文字書き人形　は　神的な存在　デス',
    'わたくし　段差に弱い系男子　デス',
    'わたくし　こう見えて　日本生まれ、ロンドン在住　デス',
    'この髪型は　原宿スタイル　デス',
    'もしも　しらすに生まれ変わったら　江ノ島にだけは近づきません　デス'
  ]
  message = ary[Math.floor(Math.random() * ary.length)]
  robot.send envelope, message

  robot.hear /(|いま|今)(| |　)何時(？|\?)/i, (msg) ->
    msg.send "現在の時刻は　#{moment().format('lll')}　デス"

  # JS eval
  robot.hear /^js (.+)/i, (msg) ->
    console.log 'matched', msg.match[1]
    evaluated = String( eval msg.match[1] )
    console.log 'evaluated', evaluated
    msg.send evaluated

  # Topics
  new cron '0 0 15 * * *', () ->
    robot.http("https://chaus.herokuapp.com/apis/karakuri/tags").get() (err, res, body) ->
      tags = JSON.parse(body).items.map (item) ->
        return item.name
      tag = tags[Math.floor(Math.random() * tags.length)]
      robot.http("http://qiita.com/api/v2/tags/#{tag}/items?page=1&per_page=1").get() (err, res, body) ->
        data = JSON.parse(body)
        robot.send envelope, "３時の #{tag} オヤツ　デス #{data[0].url}"
  , null, true, "Asia/Tokyo"

  # Greeting
  robot.hear /こんばんは/i, (msg) ->
    msg.send "今晩は、過ごしやすうございます　デス"
  robot.hear /おはよう/i, (msg) ->
    msg.send "お早くから、ご苦労様でございます　デス"
  robot.hear /こんにちは/i, (msg) ->
    msg.send "今日は、良いお日和　デス"

  # Wake up servers
  new cron '0 28 9 * * *', () ->
    robot.http('https://monstera.herokuapp.com').get() (err, res, body) ->
      robot.http('https://chaus.herokuapp.com').get() (err, res, body) ->
  , null, true, "Asia/Tokyo"

  # Koiki
  new cron '0 30 9 * * *', () ->
    robot.http('https://monstera.herokuapp.com/api/koikijs/next').get() (err, res, body) ->
      data = JSON.parse(body)
      if data.date == moment.utc().startOf('date').format()
        robot.send envelope, '本日は　koiki　の開催日　デス'
        robot.send envelope, 'みなさま　お遅れにならないよう　お願いします　デス'
        robot.send envelope, 'ご飯　隊長: ninja-inc'
        robot.send envelope, '場所取り　隊長: sideroad'
        robot.send envelope, '議事録　隊長: nabnab'
        robot.send envelope, 'デザイン　隊長: taka66'
      if data.date == moment.utc().startOf('date').add(1, 'days').format()
        robot.send envelope, '明日は　koiki　の開催日　デス'
        robot.send envelope, 'みなさま　お忘れの無いよう　お願いします　デス'
      if data.date == moment.utc().startOf('date').add(7, 'days').format()
        robot.send envelope, "次回　koiki　の開催予定日は　#{moment(data.date).format('LL (ddd)')}　デス"
        robot.send taka66,   "場所の予約のほど　よろしくお願いします　デス"
  , null, true, "Asia/Tokyo"

  robot.hear /(次|つぎ)の(| |　)(小粋|koiki|こいき)(| |　)(は)いつ(|ごろ|頃)(|になる|になりそう|ですか|になりそうですか|にする)(？|\?)/i, (msg) ->
    robot.send envelope, 'ただいま確認中　デス'
    robot.http('https://monstera.herokuapp.com/api/koikijs/next').get() (err, res, body) ->
      data = JSON.parse(body)
      if data.date
        msg.send "つぎの開催予定日は　#{moment(data.date).format('LL (ddd)')}　デス"
      else
        msg.send '開催可能な日が　見つけられない　デス'
        msg.send 'https://monstera.herokuapp.com/events/koikijs'
        msg.send 'みなさん　予定の空いている日を入れてほしい　デス'

  # Nabuchi
  robot.hear /^nab put (.*)/, (msg) ->
    nabs = JSON.parse(robot.brain.get('nab')||'[]')
    nabs.push msg.match[1]
    robot.brain.set('nabs', JSON.stringify nabs);

  robot.hear /.*/, (msg) ->
    user = msg.envelope.user.name.trim().toLowerCase()

    if user == 'nabnab'
      msg.send msg.random JSON.parse(robot.brain.get('nabs')||'[]')
