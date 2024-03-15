#!/bin/bash

# Things to Modify
LOGIN_USERNAME=ANY_USERNAME
LOGIN_PASSWORD=ANY_PASSWORD

# Set a timezone as per your preference (https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
PREFERRED_TIMEZONE=Asia/Kolkata

FLYCTL_PATH="$HOME/.fly/bin/flyctl"

check_flyctl_installed() {
    if [ -x "$(command -v $FLYCTL_PATH)" ]; then
        echo "flyctl is already installed, Skipping ..."
    else
        echo "flyctl is not installed. Installing it now..."
        curl -L https://fly.io/install.sh | sh
    fi
}

check_logged_in() {
    $FLYCTL_PATH auth whoami > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Already logged in"
    else
        echo "Not logged in. Logging in now..."
        $FLYCTL_PATH auth login
    fi
}

deploy_app() {
    $FLYCTL_PATH deploy
}

launch_app() {
    # Check if app already exists
    APP_EXISTS=$("$FLYCTL_PATH" status | grep -c "$APP_NAME")
    if [ $APP_EXISTS -eq 0 ]; then
        # Launch app
        echo "App does not exist. Launching app..."
        "$FLYCTL_PATH" launch
    else
        # Deploy instead of launch
        echo "App already exists. Deploying app..."
        deploy_app
    fi
}

check_app_status() {
    $FLYCTL_PATH status
}

run_ssh_command() {
    # Stop and remove existing container if it exists
    $FLYCTL_PATH ssh console --pty -C "docker stop firefox"
    $FLYCTL_PATH ssh console --pty -C "docker rm firefox"
    
    # Run the new container
    $FLYCTL_PATH ssh console --pty -C "docker run -d --restart=always --name=firefox --security-opt seccomp=unconfined -e PUID=1000 -e PGID=1000 -e TZ=\"$PREFERRED_TIMEZONE\" -e CUSTOM_USER=\"$LOGIN_USERNAME\" -e PASSWORD=\"$LOGIN_PASSWORD\" -p 3000:3000 -v /data/firefox:/config --shm-size=\"1gb\" --rm=false lscr.io/linuxserver/firefox:latest"
}


open_app() {
    OUTPUT=$($FLYCTL_PATH apps open 2>&1)
    URL=$(echo $OUTPUT | grep -o 'https://[^ ]*')
    if [ -n "$URL" ]; then
        echo "Open this url in browser: $URL"
    else
        echo "Error: failed to get app URL"
    fi
}

main() {
    check_flyctl_installed
    check_logged_in
    launch_app
    check_app_status
    run_ssh_command
    open_app
}

main