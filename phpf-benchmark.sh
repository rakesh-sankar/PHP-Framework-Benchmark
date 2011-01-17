#!/bin/bash

# This program is intend to work in Debian based machines. Please bare with until I release the one 
# for other linux-os 
# setup the basics - required commands to execute the benchmark
BENCHMARK="/usr/bin/ab"
CURL="/usr/bin/curl"
APACHE="/usr/sbin/apache2"
HTTP_RESTART='sudo /etc/init.d/apache2 restart'
CONFIGFILE='CONFIG'
CURTIME=`date "+%Y%m%d-%H%M%S"`
OUTPUTFILE="phpf-benchmark-$CURTIME.txt"

# make sure the syntax is correct
if [ $# -ne 1 ]; then
    echo "Usage:" $0 URL
    echo "where URL is the place where I can access all the framework"
    exit 127
fi

# store the URL given by the user 
URL=$1

# make sure the pre-defined commands exists

echo "Validating Apache"
if [ ! -f $APACHE ]; then
    echo "Apache is not installed.... Please install Apache"
    echo "You can install it by running this command: sudo apt-get install apache2"
    exit 127
fi
echo "..... OK"

echo "Validating Apache Bench (ab)"
which $BENCHMARK >/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Apache Bench is not installed.... Please install Apache Bench"
    echo "You can install it by running this command: sudo apt-get install apache2-utils"
    exit 127
fi
echo "..... OK"

echo "Validating CURL"
which $CURL >/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
    echo "CURL is not installed.... Please install CURL"
    echo "You can install it by running this command: sudo apt-get install curl"
    exit 127
fi
echo "..... OK"

# verify the URL's and make sure all of them works
echo "Should I verify URL's (Y/N)? "
read YESNO
if [ "$YESNO" = "Y" -o "$YESNO" = "y" -o "$YESNO" = 1 ] 
then
    while read URLPATH
    do
        # find the line which starts like "Framework:    /path/to/url" 
        if echo $URLPATH |  grep -v "^#" | grep -q ": \+/"
        then
            # get the part of the string match before ":"
            FRAMEWORK=${URLPATH%:*}
            # get the part of the string after before ":" & remove any blank space
            URI=`echo ${URLPATH#*:} | sed 's/^ *//' | sed 's/ *$//'`
            TEST_URL="$URL$URI"
            echo "Validating $FRAMEWORK: "
            echo "$TEST_URL"
            $CURL $TEST_URL
            echo "..... OK"
            echo "\n"
        fi
    done < $CONFIGFILE
else
    exit 0
fi

# run the benchmark on all of these URL's and show the results
echo "Should I benchmark these URL's (Y/N)? "
read YESNO
if [ "$YESNO" = "Y" -o "$YESNO" = "y" -o "$YESNO" = 1 ]
then
    # ask the user for the time and concurrency level
    echo "Tell me the concurrent level (how many request): "
    read CONCURRENT
    
    echo "How long do you want me to test this (in seconds): "
    read REQTIME
    
    # some useful output 
    echo "The following test run for $REQTIME seconds with $CONCURRENT concurrency level" >> $OUTPUTFILE 
    echo "\n" 

    while read URLPATH
    do
        # find the line which starts like "Framework:    /path/to/url" 
        if echo $URLPATH |  grep -v "^#" | grep -q ": \+/"
        then
            # get the part of the string match before ":"
            FRAMEWORK=${URLPATH%:*}
            
            # label the framework name in the output file
            echo "\n"
            echo "$FRAMEWORK: " >> $OUTPUTFILE
            
            # get the part of the string after before ":" & remove any blank space
            URI=`echo ${URLPATH#*:} | sed 's/^ *//' | sed 's/ *$//'`
            TEST_URL="$URL$URI"
            echo "Benchmarking $FRAMEWORK: "
            echo "$TEST_URL"
            
            # Restart the apache, & make sure there is not even a single bit of cache
            $HTTP_RESTART
            
            # let it sleep for 2 seconds :-)
            sleep 2
            
            # start the benchmarking for 30 seconds with 10 concurrent request
            $BENCHMARK -t $REQTIME -c $CONCURRENT $TEST_URL >> $OUTPUTFILE
            
            echo "\n" "\n" >> $OUTPUTFILE
            
            echo "..... OK"
            echo "\n"
            sleep 2
        fi
    done < $CONFIGFILE
else
    exit 0
fi

# show some results
echo "Results: \n"
cat $OUTPUTFILE | grep -e Path -e Request
echo "\n"
echo "Please see the following file for the detailed report:"
echo $OUTPUTFILE
echo "\n"
