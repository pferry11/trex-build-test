*** Settings ***
Library    SSHLibrary
Library    OperatingSystem
Library    ../libraries/YamlCompare.py

*** Variables ***
${TREX_HOST}      %{TREX_HOST}
${TREX_USER}      %{TREX_USER}
${TREX_PASS}      %{TREX_PASS}

${TREX_DIR}       /opt/trex-3.06
${TREX_CFG}       /opt/trex-3.06/trex_cfg.yaml
${EXPECTED_CFG_FILE}    ${EXECDIR}/tests/expected/trex_cfg_expected.yaml


*** Test Cases ***
Verify TRex Server Environment
    [Documentation]    Verifies Python version, TRex directory, and TRex config file contents on remote TRex server.
    Open Connection And Login
    Verify Python Version Is Correct
    Verify TRex Directory Exists
    Verify TRex Config File Matches Expected
    Close All Connections


*** Keywords ***
Open Connection And Login
    Open Connection    ${TREX_HOST}
    Login    ${TREX_USER}    ${TREX_PASS}    loglevel=NONE

Verify Python Version Is Correct
    ${out}=    Execute Command    python3 --version
    Should Contain    ${out}    Python 3.6.9

Verify TRex Directory Exists
    ${out}=    Execute Command    test -d ${TREX_DIR} && echo OK
    Should Be Equal    ${out}    OK

Verify TRex Config File Matches Expected
    ${actual_text}=       Execute Command    cat ${TREX_CFG}
    ${actual}=            Load Yaml          ${actual_text}

    #Log To Console    EXPECTED PATH: "${EXPECTED_CFG_FILE}"

    ${expected_text}=     OperatingSystem.Get File    ${EXPECTED_CFG_FILE}
    ${expected}=          Load Yaml          ${expected_text}

    Should Be Equal       ${actual}          ${expected}