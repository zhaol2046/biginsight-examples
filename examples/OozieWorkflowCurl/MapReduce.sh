#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# abort script if any commands return an error
set -e

# Uncomment to debug
set -x

DIR="/user/${username}/test-$(date +%s)"

FILE="LICENSE"

# create the temporary directory
curl -s -i -k -u ${username}:${password} -X PUT "${gateway}/webhdfs/v1/${DIR}?op=MKDIRS" | grep 'HTTP/1.1 200 OK'

################################################################################
##### upload workflow.xml #####

# register the name for the file, and get the location (use tr to strip header CRLF
LOCATION=$(curl -s -i -k -u ${username}:${password} -X PUT "${gateway}/webhdfs/v1/${DIR}/workflow.xml?op=CREATE" | tr -d '\r' | sed -En "s/^Location: (.*)$/\1/p")

# cmd to send the file to the location
curl -s -i -k -u ${username}:${password} -T workflow-definition.xml -X PUT ${LOCATION} | grep 'HTTP/1.1 201 Created'

################################################################################
##### upload hadoop-examples.jar #####

# register the name for the file, and get the location (use tr to strip header CRLF
LOCATION=$(curl -s -i -k -u ${username}:${password} -X PUT "${gateway}/webhdfs/v1/${DIR}/hadoop-examples.jar?op=CREATE" | tr -d '\r' | sed -En "s/^Location: (.*)$/\1/p")

# cmd to send the file to the location
curl -s -i -k -u ${username}:${password} -T samples/hadoop-examples.jar -X PUT ${LOCATION} | grep 'HTTP/1.1 201 Created'

################################################################################
##### upload LICENSE #####

# register the name for the file, and get the location (use tr to strip header CRLF
LOCATION=$(curl -s -i -k -u ${username}:${password} -X PUT "${gateway}/webhdfs/v1/${DIR}/LICENSE?op=CREATE" | tr -d '\r' | sed -En "s/^Location: (.*)$/\1/p")

# cmd to send the file to the location
curl -s -i -k -u ${username}:${password} -T LICENSE -X PUT ${LOCATION} | grep 'HTTP/1.1 201 Created'

################################################################################

# TODO: add example code below

# 
# # 7. Submit the job via Oozie
# # Take note of the Job ID in the JSON response as this will be used in the next step.
# curl -i -k -u guest:guest-password -H Content-Type:application/xml -T workflow-configuration.xml \
#         -X POST 'https://localhost:8443/gateway/sandbox/oozie/v1/jobs?action=start'
# 
# # 8. Query the job status via Oozie.
# curl -i -k -u guest:guest-password -X GET \
#         'https://localhost:8443/gateway/sandbox/oozie/v1/job/{Job ID from JSON body}'
# 
# # 9. List the contents of the output directory /user/guest/example/output
# curl -i -k -u guest:guest-password -X GET \
#         'https://localhost:8443/gateway/sandbox/webhdfs/v1/user/guest/example/output?op=LISTSTATUS'
# 
# # 10. Optionally cleanup the test directory
# curl -i -k -u guest:guest-password -X DELETE \
#         'https://localhost:8443/gateway/sandbox/webhdfs/v1/user/guest/example?op=DELETE&recursive=true'


################################################################################
# clean up - remove the temporary directory
curl -s -i -k -u ${username}:${password} -X DELETE "${gateway}/webhdfs/v1/${DIR}?op=DELETE&recursive=true" | grep 'HTTP/1.1 200 OK' 

printf "\n>> MapReduce test was successful.\n\n"
