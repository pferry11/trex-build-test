*** Settings ***
Resource          ../resources/common.resource
Variables         ../variables/trex01.yaml

***Variables ***


*** Test Cases ***
Verify Host Connectivity
    [Documentation]    Pinging ${host}/${name}
    #Verify host is reachable  10.0.0.199
    # This test is critical for the rest of the suite, so we use "Run Keyword And Return Status" to capture the result and then "Run Keyword Unless" to abort if it fails.
    ${ok}=    Run Keyword And Return Status    Verify host is reachable    ${host}
    IF    not ${ok}
        Fatal Error    Connectivity test failed — aborting suite
    END

