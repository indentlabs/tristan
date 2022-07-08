# Tristan (bot)

A Discord bot.

## Using the bot

Type `/generate character` to start your template. From there, just select which character fields you'd like to add to your template. After you've built your template, a character will automatically be created using it!

After any character is generated, you can click the "Generate another character with this template" button to instantly create additional characters using the same template, or click the "Use a new template" button to start building a new template to generate from.

## Want to try it out?

### Join the Indent Labs discord to see it in action:
[Click here for an invitation to the Indent Labs server](https://discord.gg/uM6EHxkeUX)

### Add it to your own server
[Click here to invite the bot to your server](https://discord.com/api/oauth2/authorize?client_id=993994793225031810&permissions=277025442880&scope=applications.commands%20bot)

## Have feedback? Suggestions?

I'd love to hear them [here](https://github.com/indentlabs/tristan/issues) or on [Discord](https://discord.gg/uM6EHxkeUX) -- whatever is convenient for you! I'll be adding more generators and expanding the functionality of existing generators over time, so I'd love to hear about what's helpful, what's not, and what else you wish the bot could generate.

Thanks!

## Developing

### To run the bot yourself

1. Install Rails 7
2. Install Redis
3. Create a Discord bot and register it in the [Discord Developer Portal](https://discord.com/developers/applications)
4. Set a `DISCORD_TOKEN` environment variable equal to your Developer Portal-provided bot token
5. Set a `REDIS_URL` environment variable with your Redis connection string. If you're using Heroku (and add a Redis add-on), this will already be set for you.
6. Run the bot with `bundle exec ruby bin/tristan.rb`. If you are using Heroku, this will happen automatically at the end of each deploy.
