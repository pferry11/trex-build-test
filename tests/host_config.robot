*** Settings ***
Resource          ../resources/ssh.resource
Resource          ../resources/common.resource
Variables         ../variables/trex01.yaml

Suite Setup       Setup SSH Session
Suite Teardown    Close SSH Connection

***Variables ***
${Hugepages}    2048

*** Test Cases ***
Verify Host Connectivity
    [Documentation]    Pinging ${host}/${name}
    Verify host is reachable  ${host}

Hugepages Set According
    [Documentation]    Hugepages are set to: ${Hugepages}
    Verify Hugepages    ${Hugepages}

*** Keywords ***
Setup SSH Session
    Load Credentials
    Open SSH Connection    ${host}