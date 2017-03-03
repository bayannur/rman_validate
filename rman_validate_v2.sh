#!/bin/bash

# +-----------------------------------------------------------------------+
# |                              Quanwen Zhao                             |
# |                            guestart@163.com                           |
# |                        guestart.blog.51cto.com                        |
# |-----------------------------------------------------------------------|
# |      Copyright (c) 2016-2017 Quanwen Zhao. All rights reserved.       |
# |-----------------------------------------------------------------------|
# | DATABASE   : Oracle                                                   |
# | OS ENV     : CentOS 6.6 X86_64 Bit                                    |
# | File       : rman_validate.sh                                         |
# | CLASS      : LINUX Bourne-Again Shell Scripts                         |
# | PURPOSE    : This bash script file used to validate rman backupset    |
# |              that is generated last night via validate command on     |
# |              Oracle Database Server.                                  |
# |                                                                       |
# | PARAMETERS : None.                                                    |
# |                                                                       |
# | MODIFIED   : 03/02/2017 (dd/mm/yyyy)                                  |
# |                                                                       |
# | NOTE       : As with any code,ensure to test this script in a         |
# |              development environment before attempting to run it in   |
# |              production.                                              |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# | EXPORT ENVIRONMENT VARIABLE OF ORACLE USER                            |
# +-----------------------------------------------------------------------+

source ~/.bash_profile;

# +-----------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT THE ABSOLUTE PATH OF THE SHELL COMMAND         |
# +-----------------------------------------------------------------------+

export AWK='/bin/awk'
export DATE='/bin/date'

# +-----------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT STRINGS AND BACKTICK EXECUTION RESULT OF SHELL |
# +-----------------------------------------------------------------------+

export BACK_LOG=~/rman_backup/log
export RMAN=$ORACLE_HOME/bin/rman
export SQLPLUS=$ORACLE_HOME/bin/sqlplus
export YESTERDAY=`$DATE +%Y-%m-%d -d yesterday`
export BSKEY_LIST=
export BSKEY_LIST_WITH_COMMA=

# +-----------------------------------------------------------------------+
# | QUERY ALL OF BS_KEY VALUE OF RMAN BACKUPSET YESTERDAY INTO BSKEY_LIST |
# +-----------------------------------------------------------------------+

BSKEY_LIST=`
$SQLPLUS -S /nolog << EOF
connect / as sysdba
set echo off feedback off heading off underline off
select bs_key from v\\$backup_set_details where device_type='DISK' and completion_time > to_date('$YESTERDAY','yyyy-mm-dd') order by 1;
exit;
EOF`

# +-----------------------------------------------------------------------+
# | WITH AWK COMMAND TO PROCESS BSKEY_LIST SAVE TO BSKEY_LIST_WITH_COMMA  |
# +-----------------------------------------------------------------------+

BSKEY_LIST_WITH_COMMA=`echo $BSKEY_LIST | $AWK -F' ' '{ for ( i=1; i<NF; i++ ) print $i","; print $NF }'`

# +-----------------------------------------------------------------------+
# | VALIDATE RMAN BACKUPSET THAT IS GENERATED LAST NIGHT                  |
# +-----------------------------------------------------------------------+

$RMAN nocatalog log $BACK_LOG/validate_`date +%Y-%m-%d`.log <<EOF
connect target /
validate backupset $BSKEY_LIST_WITH_COMMA check logical;
exit;
EOF
