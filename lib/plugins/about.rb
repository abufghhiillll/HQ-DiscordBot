module About
  extend Discordrb::Commands::CommandContainer

  command(:help, aliases: [:about]) do |event|
    begin
      event.channel.send_embed do |embed|
        embed.title = 'Welcome to the HQ Discord Bot'
        embed.colour = '36399A'
        embed.description = 'The HQ bot allows you to get statistics about the game!'

        embed.add_field(name: 'Commands', value: 'Command list can be found with `hq, commands`', inline: true)
        embed.add_field(name: 'Invite me!', value: 'You can invite me to your server with [this link](https://discordapp.com/oauth2/authorize?client_id=578544051901431821&permissions=18432&scope=bot).', inline: true)
        embed.add_field(name: 'Help Server', value: 'Click [me](https://discord.gg/59N3FcX) to join the help server.', inline: true)
        embed.add_field(name: 'More Bot Stats', value: 'Run `hq, info` to see more stats!', inline: true)
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey! It\'s me, money-flippin\' Matt Richards! I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end

  command(:commands) do |event|
    begin
      event.channel.send_embed do |embed|
        embed.title = 'HQ Discord Bot Commands'
        embed.colour = '36399A'

        embed.add_field(name: 'Basic Commands', value: [
          '`hq, help` - Find bot help',
          '`hq, commands` - Find bot commands',
          '`hq, ping` - Ping the bot',
          '`hq, invite` - Invite the bot',
          '`hq, info` - Find stats on the bot',
          '`hq, lib` - HQ Bot Open-Source Libraries',
          '`hq, votes` - See your votes!',
          '`hq, servers` - See HQ Bot server stats'
        ].join("\n"), inline: false)

        embed.add_field(name: 'HQ Stats Commands', value: [
          '`hq, rank` - Find HQ leaderboard rankings. Add arg `all` for all time.',
          '`hq, user (name)` - Find stats for a user, leave name blank to just use your discord display name',
          '`hq, badges (name)` - Find badge stats for a user.',
          '`hq, nextgame (us|uk|words|trivia|sports)` - Find the next game time and prize, give argument for different game types'
        ].join("\n"), inline: false)

        embed.add_field(name: 'HQ Bot Profile Commands', value: [
          '`hq, profile` - See your profile.',
          '`hq, set username (name)` - Set your username, so that `hq, user` returns your stats.',
          '`hq, set region (us/uk/de/au)` - Set your region, so that `hq, nextgame` returns your region'
        ].join("\n"), inline: false)

        embed.add_field(name: 'Bonus Commands', value: [
          '`hq, dab` - Make the bot dab!',
          '`hq, life` - A totally legit guide on how to get lives.',
          '`hq, answer` - A totally legit answer bot.',
          '`hq, epic` - Okay, now this is epic.',
          '`hq, its` - Grammar command! Fix your friends\' spelling of its vs it\'s!'
        ].join("\n"), inline: false)
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey! It\'s me, money-flippin\' Matt Richards! I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end

  command(:donate) do |event|
    begin
      event.channel.send_embed do |embed|
        embed.title = 'Donate to Chew!'

        embed.description = 'I have various open donation windows.'

        embed.add_field(name: 'Money', value: 'You can donate money [here](https://donate.chew.pw).')
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey! It\'s me, money-flippin\' Matt Richards! I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end

  command(:ping, min_args: 0, max_args: 1) do |event, noedit|
    if noedit == 'noedit'
      event.respond "Pong! Time taken: #{((Time.now - event.timestamp) * 1000).to_i} milliseconds."
    else
      m = event.respond('Pinging...')
      m.edit "Pong!! Time taken: #{((Time.now - event.timestamp) * 1000).to_i} milliseconds."
    end
  end

  command(:invite) do |event|
    event.respond 'Hello! Invite me to your server here: <https://discordapp.com/oauth2/authorize?client_id=578544051901431821&permissions=18432&scope=bot>. Join my help server here: https://discord.gg/59N3FcX'
  end

  command(:info, aliases: [:bot]) do |event|
    t = Time.now - Starttime
    mm, ss = t.divmod(60)
    hh, mm = mm.divmod(60)
    dd, hh = hh.divmod(24)
    days = format("%d days\n", dd) if dd != 0
    hours = format("%d hours\n", hh) if hh != 0
    mins = format("%d minutes\n", mm) if mm != 0
    secs = format('%d seconds', ss) if ss != 0

    commits = `git rev-list master | wc -l`.to_i

    botversion = if commits.zero?
                   ''
                 else
                   "Commit: #{commits}"
                 end

    begin
      event.channel.send_embed do |e|
        e.title = 'HQ Trivia Bot Stats!'

        e.add_field(name: 'Author', value: event.bot.user(CONFIG['owner_id']).distinct, inline: true)
        e.add_field(name: 'Code', value: '[Code on GitHub](http://github.com/Chew/HQ-DiscordBot)', inline: true)
        e.add_field(name: 'Bot Version', value: botversion, inline: true) unless botversion == ''
        e.add_field(name: 'Library', value: 'discordrb 3.3.0', inline: true)
        e.add_field(name: 'Uptime', value: "#{days}#{hours}#{mins}#{secs}", inline: true)
        e.add_field(name: 'Server Count', value: DBL.stats.servers, inline: true) unless CONFIG['dbotsorg'].nil?
        # e.add_field(name: 'Commands Ran', value: Commands.get, inline: true)
        e.add_field(name: 'Total User Count', value: event.bot.users.count, inline: true)
        e.add_field(name: 'Shard', value: event.bot.shard_key[0], inline: true)
        e.color = '36399A'
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey! It\'s me, money-flippin\' Matt Richards! I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end

  command(:servers) do |event|
    servers = []
    counts = []
    DBL.self.shards.each_with_index do |serv, e|
      servers.push "Shard \##{e}: #{serv} servers"
      counts.push serv
    end
    servers.push ''
    servers.push "Total: #{counts.sum}"
    servers.push "Average: #{counts.average}"
    begin
      event.channel.send_embed do |e|
        e.title = 'HQ Trivia Bot Server Stats!'

        e.description = servers.join("\n")
        e.color = '36399A'
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey! It\'s me, money-flippin\' Matt Richards! I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end

  command(:lib) do |event|
    gems = `gem list`.split("\n")
    libs = ['discordrb', 'rest-client', 'json', 'dblruby', 'coinbase', 'sentry-raven', 'rufus-scheduler']
    versions = []
    libs.each do |name|
      version = gems[gems.index { |s| s.include?(name) }].split(' ')[1]
      versions[versions.length] = version.delete('(').delete(',').delete(')')
    end
    begin
      event.channel.send_embed do |e|
        e.title = 'HQ - Open Source Libraries'

        (0..libs.length - 1).each do |i|
          url = "http://rubygems.org/gems/#{libs[i]}/versions/#{versions[i]}"
          e.add_field(name: libs[i], value: "[#{versions[i]}](#{url})", inline: true)
        end
        e.color = '36399A'
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey! It\'s me, money-flippin\' Matt Richards! I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end

  command(:load) do |event|
    break unless CONFIG['owner_id'] == event.user.id

    data = JSON.parse(RestClient.get(CONFIG['web_loc']))

    event.channel.send_embed do |embed|
      embed.title = 'HQ Bot Server Load Average'

      data['processes'].each do |process|
        next if process['name'] != 'ruby run'

        embed.add_field(name: "Bot \##{process['pm_id']}", value: ["CPU: #{process['monit']['cpu']}%", "Memory #{(process['monit']['memory'].to_f / 1_000_000).round(2)} MB", "Uptime: #{seconds_to_format(process['pm2_env']['created_at'])}"].join("\n"), inline: true)
      end
    end
  end
end
