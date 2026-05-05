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

Validate SSH Credentials
    [Arguments]    ${host}
    [Documentation]    Loads credentials and attempts an SSH login with detailed error reporting.

    Load Credentials

    # Try opening the SSH connection
    ${status}    ${message}=    Run Keyword And Ignore Error
    ...    SSHLibrary.Open Connection    ${host}    timeout=${SSH_TIMEOUT}

    IF    '${status}' != 'PASS'
        IF    'Connection refused' in '${message}'
            Fatal Error    SSH connection refused — host reachable but port 22 is closed.
        ELSE IF    'timed out' in '${message}' or 'Timeout' in '${message}'
            Fatal Error    SSH connection timed out — host unreachable or firewall blocking.
        ELSE
            Fatal Error    SSH connection failed: ${message}
        END
    END

    # Try logging in
    ${login_status}    ${login_message}=    Run Keyword And Ignore Error
    ...    SSHLibrary.Login    ${SSH_USER}    ${SSH_PASS}

    IF    '${login_status}' != 'PASS'
        IF    'Authentication failed' in '${login_message}'
            Fatal Error    SSH login failed — invalid username or password.
        ELSE
            Fatal Error    SSH login failed: ${login_message}
        END
    END

    SSHLibrary.Close All Connections

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