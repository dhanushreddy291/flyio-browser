# Cloud Browser on fly.io

This is a simple web browser, firefox that runs on [fly.io](https://fly.io).

# Features

- Private and secure browsing environment.
- High internet speed, as we are using a remote server.
- Easily deployable on fly.io.
- History and Data is stored as we also mount a volume to the VM.

# How to deploy

- Just change the app name in `fly.toml`
- You can deploy to a region that is closest to you to reduce latency. Available regions: [fly.io/docs/reference/regions](https://fly.io/docs/reference/regions). I have selected as `sin` (Singapore) in `fly.toml` as it is closest to me.
- Also do modify the default username and password in `deploy.sh`

## Run

```bash
bash deploy.sh
```

The `deploy.sh` script handles everything, from installing `flyctl` to deploying the app. Upon running the script, you'll be prompted for authentication. The `fly.toml` file already contains the necessary configuration, but you're free to adjust specifications as needed. During deployment, you'll be given the option to utilize the existing configuration or make modifications. Simply press `y` to accept the default settings. It would later ask if you want to add any datbase, redis or any other services. You can press `N` to skip that.

Once deployed, a URL for your Cloud Browser instance will be displayed. Access this URL in your browser, where you'll be prompted for your username and password.

# Approx Charges

For a 2 GB instance on fly.io, the charges are approximately $0.01476 per hour (or $10.7 per month). This is a rough estimate, and the actual cost may vary depending on your bandwidth usage and other factors. Also you can turn off the machine when not in use to avoid any charges, as you are billed to the second on fly.io.

# To set a custom domain
Follow the guide on [fly.io/docs/reference/regions](https://fly.io/docs/reference/regions) to set a custom domain for your app.

# To destroy

Incase if you want to destroy the app and avoid any charges completely, you can run the following command.

```bash
flyctl destroy APP_NAME_WHICH_YOU_GAVE_IN_FLY.TOML
```

# Bonus if you want to automate the start and stop of the VM

Also adding code for a telegram-bot in `telegram` folder which you can deploy easily on [deno.com/deploy](https://deno.com/deploy). I am not going to explain how to create a Telegram bot, you can follow any online tutorial it wont take max 5-10 minutes to set it up.

By using this telegram bot you can start and stop the VM, so as to avoid any charges when not in use.

You also need to set these values in environment variables in deno.com/deploy

- BOT_TOKEN (Your telegram bot token)
- USERNAME (Your telegram username)
- FLY_API_TOKEN (Your fly.io api token, get it here: [fly.io/user/personal_access_tokens](https://fly.io/user/personal_access_tokens))
- FLY_MACHINE_ID (Your fly.io machine id, get it via `fly machine list`)
- FLY_APP (The name of your app, which you gave in `fly.toml`)

Also don't forget to set the webhook of telegram bot to your deployed url on deno.com/deploy.
Set webhhok using this: `https://api.telegram.org/bot<Your Telegram Bot Token>/setWebhook?url=<URL that you got from Deno>`
