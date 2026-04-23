*** Settings ***
Resource          ../resources/ssh.resource
Resource          ../resources/common.resource
Variables         ../variables/trex01.yaml

Suite Setup       Setup SSH Session
Suite Teardown    Close SSH Connection

*** Test Cases ***
Verify Host Connectivity
    [Documentation]    Pinging ${host}/${name}
    Verify host is reachable  ${host}

Hugepages Should Be Configured Correctly
    Verify Hugepages    2048

*** Keywords ***
Setup SSH Session
    Load Credentials
    Open SSH Connection    ${host}