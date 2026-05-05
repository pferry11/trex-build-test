*** Settings ***
Resource          ../resources/ssh.resource
Resource          ../resources/common.resource
#Variables         ../variables/trex01.yaml

Suite Setup       Setup SSH Session
Suite Teardown    Close SSH Connection

***Variables ***
${trex_dir}   /opt/Trex
${trex_Version}    3.06

*** Test Cases ***

Verify TREX master directory exists
    [Documentation]    Checks if the master TREX directory exists on the host.
    Verify TREX directory exists    ${trex_dir}    

TRex Version Check    
    [Documentation]    Validated the folder name contains the expected version number, and that the t-rex-64 binary exists within that folder.
    TRex Version Check - Folder    ${trex_dir}     ${trex_Version}

Check DPDK Bound Interfaces
    [Documentation]    Verifies that the expected PCI NICs are bound to a DPDK driver without requiring sudo.
    Check DPDK Bound Interfaces    @{pci_nics}

Check TRex configuration file exists
    [Documentation]    Verifies that the TRex configuration file exists on the remote host.
    Trex trex_cfg.yaml check    ${trex_cfg}   

Validate TRex configuration file
    [Documentation]    Compares the TRex configuration file on the host with an expected version to ensure it is correct.
    Compare TRex cfg.yaml    ${trex_cfg}    ${trex_expected_cfg}

*** Keywords ***
Setup SSH Session
    Load Credentials
    Open SSH Connection    ${host}