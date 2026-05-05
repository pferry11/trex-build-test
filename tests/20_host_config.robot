*** Settings ***
Resource          ../resources/ssh.resource
Resource          ../resources/common.resource
#Variables         ../variables/trex01.yaml

Suite Setup       Setup SSH Session
Suite Teardown    Close SSH Connection

***Variables ***
#${Hugepages}    4096

*** Test Cases ***

Hugepages Set According
    [Documentation]    Hugepages are set to: ${Hugepages}
    Verify Hugepages    ${Hugepages}

Validation of Mellanox Driver
    [Documentation]    Checks if Mellanox driver is installed on the host.
    Validation of Mellanox Driver    ${host}

Check DOCA-OFED Installation
    [Documentation]    Verifies if DOCA-OFED is installed on the host.
    Check DOCA-OFED Installation    ${host}

Check host network port names & bus addresses
    [Documentation]    Verifies that the network ports have the expected names and bus addresses.
    Check host network port names & bus addresses    @{pci_nics}    

*** Keywords ***
Setup SSH Session
    Load Credentials
    Open SSH Connection    ${host}