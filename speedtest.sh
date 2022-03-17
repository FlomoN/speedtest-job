#!/bin/sh

# From https://github.com/robinmanuelthiel/speedtest/blob/master/speedtest.sh

# These values can be overwritten with env variables
DB_SAVE="${DB_SAVE:-false}"
DB_HOST="${DB_HOST:-http://localhost:8086}"
DB_NAME="${DB_NAME:-speedtest}"
DB_USERNAME="${DB_USERNAME:-admin}"
DB_PASSWORD="${DB_PASSWORD:-password}"

run_speedtest()
{
    DATE=$(date +%s)
    HOSTNAME=$(hostname)

    # Start speed test
    echo "Running a Speed Test..."
    JSON=$(./speedtest --accept-license --accept-gdpr -f json)
    DOWNLOAD="$(echo $JSON | jq -r '.download.bandwidth')"
    UPLOAD="$(echo $JSON | jq -r '.upload.bandwidth')"
    PING="$(echo $JSON | jq -r '.ping.latency')"
    JITTER="$(echo $JSON | jq -r '.ping.jitter')"
    echo "Your download speed is $(($DOWNLOAD  / 125000 )) Mbps ($DOWNLOAD Bytes/s)."
    echo "Your upload speed is $(($UPLOAD  / 125000 )) Mbps ($UPLOAD Bytes/s)."
    echo "Your ping is $PING ms."
    echo "Your jitter is $JITTER ms."

    # Save results in the database
    if $DB_SAVE; 
    then
        echo "Saving values to database..."
        curl -s -S -XPOST "$DB_HOST/write?db=$DB_NAME&precision=s&u=$DB_USERNAME&p=$DB_PASSWORD" \
            --data-binary "download,host=$HOSTNAME value=$DOWNLOAD $DATE"
        curl -s -S -XPOST "$DB_HOST/write?db=$DB_NAME&precision=s&u=$DB_USERNAME&p=$DB_PASSWORD" \
            --data-binary "upload,host=$HOSTNAME value=$UPLOAD $DATE"
        curl -s -S -XPOST "$DB_HOST/write?db=$DB_NAME&precision=s&u=$DB_USERNAME&p=$DB_PASSWORD" \
            --data-binary "ping,host=$HOSTNAME value=$PING $DATE"
        curl -s -S -XPOST "$DB_HOST/write?db=$DB_NAME&precision=s&u=$DB_USERNAME&p=$DB_PASSWORD" \
            --data-binary "jitter,host=$HOSTNAME value=$JITTER $DATE"
        echo "Values saved."
    fi
}

run_speedtest