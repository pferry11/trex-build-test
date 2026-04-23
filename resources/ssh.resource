*** Settings ***
Library    SSHLibrary
Library    OperatingSystem
Library    String


*** Variables ***
${SSH_TIMEOUT}    10 seconds

*** Keywords ***
Load Credentials
    [Documentation]    Ensures TREX_USER and TREX_PASS are available.
    ${user}=    Get Environment Variable    TREX_USER
    ${pass}=    Get Environment Variable    TREX_PASS
    Should Not Be Empty    ${user}    TREX_USER is not set. Did you source trex.env?
    Should Not Be Empty    ${pass}    TREX_PASS is not set. Did you source trex.env?
    Set Suite Variable    ${SSH_USER}    ${user}
    Set Suite Variable    ${SSH_PASS}    ${pass}

Open SSH Connection
    [Arguments]    ${host}
    [Documentation]    Opens SSH connection using credentials loaded earlier.
    SSHLibrary.Open Connection    ${host}    timeout=${SSH_TIMEOUT}
    SSHLibrary.Login    ${SSH_USER}    ${SSH_PASS}

Run Command
    [Arguments]    ${cmd}
    [Documentation]    Runs a command and returns stdout.
    ${output}=    SSHLibrary.Execute Command    ${cmd}
    RETURN    ${output}

Run Command And Log
    [Arguments]    ${cmd}
    ${output}=    Run Command    ${cmd}
    Log    ${output}
    RETURN   ${output}

Close SSH Connection
    [Documentation]    Closes the SSH session.
    SSHLibrary.Close All Connections