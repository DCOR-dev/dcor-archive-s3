#!/bin/bash
# Create a cron job for this bash script with the following content:
#
#   ARCHIVE_MAIL=mymail@example.com
#   # regular archiving jobs during the week
#   0 */6 * * 1,2,3,4,5,6 ~/repos/archive-s3/archive-s3.sh >> /dev/null 2>&1
#   # one summary job on Sunday
#   0 18 * * 7 ~/repos/archive-s3/archive-s3.sh report >> /dev/null 2>&1
#
LOGFILE=$(mktemp)

# run the python script
source ~/env_archive_s3/bin/activate
python ~/repos/archive-s3/archive-s3.py "$1" >> "$LOGFILE" 2>&1

# check for errors
retVal=$?
if [ $retVal -ne 0 ] && [ -n "$ARCHIVE_MAIL" ]; then
    # if errors occurred and mail address is specified, send email
    /usr/bin/mail -s "S3 archive errors" "$ARCHIVE_MAIL" < "$LOGFILE"
elif [ "$1" = "report" ]; then
    # if a report is requested, send it
    /usr/bin/mail -s "S3 archive report" "$ARCHIVE_MAIL" < "$LOGFILE"
fi


# cleanup
rm -f "$LOGFILE"

exit $retVal
