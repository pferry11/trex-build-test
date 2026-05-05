*** Settings ***
Resource    ../resources/ssh.resource
Variables   ../variables/trex01.yaml

*** Test Cases ***
Validate SSH Credentials
    [Documentation]    Ensures SSH credentials and login work before running full suite.
    Validate SSH Credentials    ${host}