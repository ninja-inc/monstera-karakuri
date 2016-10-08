# coffeelint: disable=max_line_length

moment = require 'moment'
moment.locale 'ja'
cron = require('cron').CronJob
envelope = room: "C0JHEPQ94" # general
test = room: "C217B7QG0" # test
gohan = room: "C2L1Y13R6" # gohan
techtopics = room: "C2LKUHVPD" # techtopics
taka66 = room: "C0JHEPQ94", user: "U0JH92D60" # taka66
# envelope = room: "C217B7QG0" # test
mode = 'normal'

module.exports = (robot) ->

  robot.hear /^channels$/, (msg) ->
    channels = robot.adapter.client.rtm.dataStore.channels
    Object.keys(channels).map (id) ->
      msg.reply "#{id} #{channels[id].name}"

  robot.hear /^users$/, (msg) ->
    users = robot.adapter.client.rtm.dataStore.users
    Object.keys(users).map (id) ->
      msg.reply "#{id} #{users[id].name}"

  sendDM = (name, message) ->
    room = robot.adapter.client.rtm.dataStore.getDMByName name
    robot.messageRoom room.id, message

  # error handling
  robot.error (err, res) ->
    robot.logger.error err
    robot.logger.error res

  robot.hear /^(js|sh)$/, (msg) ->
    mode = msg.match[1];
    msg.send "#{mode} モードを起動します　デス"

  robot.hear /^balse$/, (msg) ->
    msg.send "#{mode} モードを終了します　デス"
    mode = 'normal';

  robot.hear /^(?!(js|sh|balse)).+$/, (msg) ->
    if msg.match[0]
      switch mode
        when 'js'
          evaluated = String( eval msg.match[0] )
          msg.send evaluated
        when 'sh'
          String( eval "require('child_process').exec('#{msg.match[0]}', function(e, so, se){msg.send(so)})" )

  robot.hear /^karakuri put (.*)/, (msg) ->
    msgs = JSON.parse(robot.brain.get('msgs')||'[]')
    msgs.push msg.match[1]
    robot.brain.set('msgs', JSON.stringify msgs)
    msg.send msg.match[1] + ' が追加されました　デス'

  robot.hear /^karakuri delete (\d+)/, (msg) ->
    msgs = JSON.parse(robot.brain.get('msgs')||'[]')
    deleted = msgs.splice msg.match[1], 1
    robot.brain.set('msgs', JSON.stringify msgs)
    msg.send deleted[0] + ' が削除されました　デス'

  robot.hear /^karakuri all$/, (msg) ->
    msgs = JSON.parse(robot.brain.get('msgs')||'[]')
    msg.send msgs.join '\n'

  robot.hear /(|いま|今)(| |　)何時(？|\?)/i, (msg) ->
    msg.send "現在の時刻は　#{moment().format('lll')}　デス"

  # JS eval
  robot.hear /^js (.+)/i, (msg) ->
    console.log 'matched', msg.match[1]
    evaluated = String( eval msg.match[1] )
    console.log 'evaluated', evaluated
    msg.send evaluated

  # Koiki
  new cron '0 35 9 * * *', () ->
    robot.http('https://monstera.herokuapp.com/api/koikijs/next').get() (err, res, body) ->
      data = JSON.parse(body)
      date = moment.utc(data.date).startOf('date').format()
      if data.date == undefined
        robot.send envelope, '開催可能な日が　見つけられない　デス'
        robot.send envelope, 'https://monstera.herokuapp.com/events/koikijs'
        robot.send envelope, 'みなさん　予定の空いている日を入れてほしい　デス'
      if data.date && date == moment.utc().startOf('date').format()
        robot.send envelope, '本日は　koiki　の開催日　デス'
        robot.send envelope, 'みなさま　お遅れにならないよう　お願いします　デス'
        robot.send envelope, 'ご飯　隊長: ninja-inc'
        robot.send envelope, '場所取り　隊長: sideroad'
        robot.send envelope, '議事録　隊長: nabnab'
        robot.send envelope, 'デザイン　隊長: taka66'
      if data.date && date == moment.utc().startOf('date').add(1, 'days').format()
        robot.send envelope, '明日は　koiki　の開催日　デス'
        robot.send envelope, 'みなさま　お忘れの無いよう　お願いします　デス'
      if data.date && date == moment.utc().startOf('date').add(3, 'days').format()
        robot.send envelope, '三日後に　koiki　が開催されます　デス'
        robot.send envelope, "グーグルカレンダーに登録してください　デス\n https://www.google.com/calendar/render?action=TEMPLATE&text=koikijs&dates=#{moment(data.date).format('YYYYMMDD')}T000000/#{moment(data.date).format('YYYYMMDD')}T235959&trp=undefined&trp=true&sprop="
        robot.send envelope, 'みなさま　お忘れの無いよう　お願いします　デス'
      if data.date && date == moment.utc().startOf('date').add(7, 'days').format() ||
         data.date && date == moment.utc().startOf('date').add(10, 'days').format() ||
         data.date && date == moment.utc().startOf('date').add(14, 'days').format()
        robot.send envelope, "次回　koiki　の開催予定日は　#{moment(data.date).format('LL (ddd)')}　デス"
        robot.send envelope, "グーグルカレンダーに登録してください　デス\n https://www.google.com/calendar/render?action=TEMPLATE&text=koikijs&dates=#{moment(data.date).format('YYYYMMDD')}T000000/#{moment(data.date).format('YYYYMMDD')}T235959&trp=undefined&trp=true&sprop="
        robot.send taka66,   "場所の予約のほど　よろしくお願いします　デス"
  , null, true, "Asia/Tokyo"

  robot.hear /(次|つぎ)の(| |　)(小粋|koiki|こいき)(| |　)(|は)(| |　)いつ(|ごろ|頃)(|になる|になりそう|ですか|になりそうですか|にする)(？|\?)/i, (msg) ->
    msg.send 'ただいま確認中　デス'
    robot.http('https://monstera.herokuapp.com/api/koikijs/next').get() (err, res, body) ->
      data = JSON.parse(body)
      if data.date == undefined
        msg.send '開催可能な日が　見つけられない　デス'
        msg.send 'https://monstera.herokuapp.com/events/koikijs'
        msg.send 'みなさん　予定の空いている日を入れてほしい　デス'
      else
        msg.send "つぎの開催予定日は　#{moment(data.date).format('LL (ddd)')}　デス"
        msg.send "次回　koiki　の開催予定日は　#{moment(data.date).format('LL (ddd)')}　デス"
        msg.send "グーグルカレンダーに登録してください　デス\n https://www.google.com/calendar/render?action=TEMPLATE&text=koikijs&dates=#{moment(data.date).format('YYYYMMDD')}T000000/#{moment(data.date).format('YYYYMMDD')}T235959&trp=undefined&trp=true&sprop="

  # startup
  robot.send test, 'むくり'
  setTimeout () ->
    msgs = JSON.parse(robot.brain.get('msgs')||'[]')
    message = msgs[Math.floor(Math.random() * msgs.length)] || ''
    robot.send test, message
  , 5000
