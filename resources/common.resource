*** Settings ***
Library    Process
Library    OperatingSystem

*** Variables ***

*** Keywords ***

#Connectivity Tests

Verify host is reachable
    [Arguments]    ${Address}
    [Documentation]    Pings the host to ensure it's reachable.
    ${platform}=    Evaluate    platform.system()   modules=platform
    ${count_flag}=     Set Variable If    
    ...    "${platform}"=="Windows"    -n    -c

    ${result}=    Run Process    ping    ${count_flag} 2    ${Address}    shell=False    stdout=PIPE    stderr=PIPE
    Should Be Equal As Integers    ${result.rc}    0    Host ${Address} is not reachable. Ping output:\n ${result.stdout}\n 
    #...    ${result.stderr}

#Host Configuration Tests
Validation of Mellanox Driver
    [Arguments]    ${host}
    [Documentation]    Checks if Mellanox driver is installed on the host.
    ${output}=    Run Command    lsmod | grep mlx5_core
    Should Contain    ${output}    mlx5_core
    ...    Mellanox driver is not installed on host ${host}. Output: ${output}

Check DOCA-OFED Installation
    [Arguments]    ${host}
    [Documentation]    Verifies if DOCA-OFED is installed on the host.
    ${output}=    Run Command    dpkg -l | grep doca-ofed
    Should Contain    ${output}    doca-ofed
    ...    DOCA-OFED is not installed on host ${host}. Output: ${output}

Verify Hugepages
    [Arguments]    ${expected}
    ${output}=    Run Command    sysctl vm.nr_hugepages
    ${clean}=     Strip String    ${output}
    # Split on spaces
    @{parts}=     Split String    ${clean}    ${SPACE}
    # Last element is the number
    ${actual}=    Set Variable    ${parts[-1]}
    Should Be Equal As Integers    ${actual}    ${expected}
    ...    Expected ${expected}, got ${actual}
    
Check host network port names & bus addresses
    [Arguments]    @{pci_nics}
    [Documentation]    Verifies that the network ports have the expected names and bus addresses.
    ${pci_output}=    Run Command    lspci -nn | grep Ethernet
    FOR    ${pci}    IN    @{pci_nics}
        Should Contain    ${pci_output}    ${pci}
    END

#Runtime Dependency Tests

Pyhon3 version check
    [Arguments]    ${host}
    [Documentation]    Verifies that Python 3 is installed on the host.
    ${cmd}=    Set Variable    ssh ${host} "python3 --version"
    ${result}=    Run Process    ${cmd}    stdout=PIPE    stderr=PIPE
    Should Contain    ${result.stdout}    Python 3    Python 3 is not installed on host ${host}. Command output: ${result.stdout}

PIP Version check
    [Arguments]    ${host}
    [Documentation]    Checks if pip is installed on the host.
    ${cmd}=    Set Variable    ssh ${host} "pip3 --version"
    ${result}=    Run Process    ${cmd}    stdout=PIPE    stderr=PIPE
    Should Contain    ${result.stdout}    pip 20.0.2    Pip is not installed or version is incorrect on host ${host}. Command output: ${result.stdout}

PIP Package check
    [Arguments]    ${host}    ${package}
    [Documentation]    Verifies that a specific pip package is installed on the host.
    ${cmd}=    Set Variable    ssh ${host} "pip3 show ${package}"
    ${result}=    Run Process    ${cmd}    stdout=PIPE    stderr=PIPE
    Should Contain    ${result.stdout}    Name: ${package}    Pip package ${package} is not installed on host ${host}. Command output: ${result.stdout}

#Application Validation Tests

Verify TREX directory exists
    [Arguments]    ${host}    ${trex_dir}
    [Documentation]    Checks if the TREX directory exists on the host.
    ${cmd}=    Set Variable    ssh ${host} "test -d ${trex_dir} && echo 'exists' || echo 'missing'"
    ${result}=    Run Process    ${cmd}    stdout=PIPE    stderr=PIPE
    Should Contain    ${result.stdout}    exists    TREX directory ${trex_dir} is missing on host ${host}. Command output: ${result.stdout}

TRex Version Check
    [Arguments]    ${host}    ${trex_dir}
    [Documentation]    Verifies that TREX is installed and can report its version on the host.
    ${cmd}=    Set Variable    ssh ${host} "${trex_dir}/t-rex-64 -v"
    ${result}=    Run Process    ${cmd}    stdout=PIPE    stderr=PIPE
    Should Contain    ${result.stdout}    T-Rex Version    TREX is not properly installed or cannot report version on host ${host}. Command output: ${result.stdout}

TRex Bound Interfaces Check
    [Arguments]    ${host}    ${trex_dir}
    [Documentation]    Checks if TREX has bound the expected network interfaces on the host.
    ${cmd}=    Set Variable    ssh ${host} "${trex_dir}/t-rex-64 -i"
    ${result}=    Run Process    ${cmd}    stdout=PIPE    stderr=PIPE
    Should Contain    ${result.stdout}    Bound interfaces: 4    TREX does not have the expected number of bound interfaces on host ${host}. Command output: ${result.stdout}

Test .pyfiles IP range configuration
    [Arguments]    ${host}    ${trex_cfg}
    [Documentation]    Verifies that the .pyfiles configuration has the expected IP range on the host.
    ${cmd}=    Set Variable    ssh ${host} "cat ${trex_cfg} | grep -E 'ip_range:'"
    ${result}=    Run Process    ${cmd}    stdout=PIPE    stderr=PIPE
    Should Contain    ${result.stdout}    ip_range:



