#!/bin/bash

# Backup of the Jenkin job/script I put together to automatically update my home ngrok tunnel.
# When the tunnel dies, this script will (via Jenkins) create a new one and update a PHP redirect file on my
# AWS Host that allows me to connect to my CGNET'd home server via my AWS website using a dynamic ngrok end point
# It's a little bit mental, but it's worked without a hitch for 6 months and counting :-)
# Uses:
# - Jenkins
# - bash
# - ngrok
# - jq
# - grep and awk
# - PHP
# - Apache
# - AWS


# check if ngrok is running
pidof  ngrok >/dev/null
if [[ $? -ne 0 ]] ; then
		# A restart and update is required
        echo "Restarting ngrok on $(date)"
        # Start up a new instance of ngrok
        BUILD_ID=dontKillMe nohup /root/ngrok/ngrok http -region eu 80 &
		# Give it a moment
		echo "Sleeping for 15 seconds..."
        sleep 15
        # Get the updated publish_url value from the ngrok api
		export NGROKURL=`curl -s http://127.0.0.1:4040/api/tunnels | jq '.' | grep public_url | grep https | awk -F\" '{print $4}'`
        echo "NGROKURL is $NGROKURL"
        # add that to a one-line PHP redirect page
		echo "<?php header('Location: $NGROKURL/zm'); exit;?>" > zm.php
        # upload that to my AWS host
        echo "scp'ing file to AWS host..."
		scp -i /hMY_AWS_KEY_FILE.pem zm.php MY_AWS_USER@MY_AWS_HOST.amazonaws.com:/MY_HTDOCS_DIR/ZoneMinder.php 
		echo "Transfer complete."
        # Send an update message via email
		echo "New ngrok url is $NGROKURL/zm" | mailx -s "ngrok zm url updated" MY_EMAIL@gmail.com
else
		# Nothing needed, carry on
		echo "ngrok is running, nothing to do"
fi


