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

Python3 version check
    [Arguments]    ${expected_version}
    [Documentation]    Verifies that Python 3 is installed and matches the expected version.
    ${output}=    Run Command    python3 --version
    ${clean}=     Strip String    ${output}
    Should Be Equal    ${clean}    Python 3.${expected_version}
    ...    Expected Python 3.${expected_version}, but got: ${clean}

PIP Version check
    [Arguments]    ${expected_version}
    [Documentation]    Checks if pip is installed and matches the expected version.
    ${output}=    Run Command    pip3 --version
    ${clean}=     Strip String    ${output}
    Should Contain    ${clean}    pip ${expected_version}
    ...    Expected pip ${expected_version}, but got: ${clean}

PIP Package check
    [Arguments]    ${package}
    [Documentation]    Verifies that a specific pip package is installed on the host.
    ${output}=    Run Command    pip3 show ${package}
    ${clean}=     Strip String    ${output}
    Should Contain    ${clean}    Name: ${package}
    ...    Pip package ${package} is not installed. Output: ${clean}

PIP Packages check
    [Arguments]    @{packages}
    [Documentation]    Loops through a list of pip packages and verifies each is installed.

    FOR    ${pkg}    IN    @{packages}
        PIP Package check    ${pkg}
    END

#Application Validation Tests

Verify TREX directory exists
    [Arguments]    ${trex_dir}
    [Documentation]    Checks if the TREX directory exists on the host.
    ${output}=    Run Command    test -d ${trex_dir} && echo exists || echo missing
    ${clean}=     Strip String    ${output}
    Should Be Equal    ${clean}    exists
    ...    TREX directory ${trex_dir} is missing. Output: ${clean}

#this version check is more robust as it directly checks the version output from the binary, but it may require additional setup to allow passwordless sudo for the t-rex-64 binary. The folder check is less robust but may be sufficient if the version is always included in the folder name.
TRex Version Check
    [Arguments]    ${trex_dir}    ${expected_version}
    [Documentation]    Extracts TRex version using sudo, ignoring license text.
    ${cmd}=    Set Variable    sudo ${trex_dir}${expected_version}/t-rex-64 --help | grep "^ Version :"
    ${output}=    Run Command   bash -c "${cmd}"
    ${clean}=     Strip String    ${output}
    Should Contain    ${clean}    Version :
    ...    Could not read TRex version. Output: ${clean}

#This Trex Version test requires does not require Sudo like the other verison check but does relies on the version being in the folder name, which is a common but not guaranteed convention. The above test is more robust but may require additional setup to allow passwordless sudo for the t-rex-64 binary.
TRex Version Check - Folder
    [Arguments]    ${trex_dir}    ${expected_version}
    [Documentation]    Validates that the TRex version folder exists and contains the t-rex-64 binary.
    # Normalise base path (remove trailing slash)
    ${base}=    Evaluate    '${trex_dir}'.rstrip('/')
    # Build full path
    ${full_path}=    Set Variable    ${base}/${expected_version}
    Log    Checking TRex version folder: ${full_path}
    # 1. Check folder exists
    ${folder}=    Run Command    test -d ${full_path} && echo exists || echo missing
    ${folder_clean}=    Strip String    ${folder}
    Should Be Equal    ${folder_clean}    exists
    ...    TRex version folder not found: ${full_path}
    # 2. Check binary exists
    ${bin}=    Run Command    test -f ${full_path}/t-rex-64 && echo exists || echo missing
    ${bin_clean}=    Strip String    ${bin}
    Should Be Equal    ${bin_clean}    exists
    ...    TRex binary missing in version folder: ${full_path}/t-rex-64
    Log    TRex version folder and binary validated: ${full_path}

Check DPDK Bound Interfaces
    [Arguments]    @{pci_nics}
    [Documentation]    Verifies that the expected PCI NICs are bound to a DPDK driver without requiring sudo.
    # /sys/bus/pci/drivers/* - if not found or sudo ./dpdk_setup_ports.py -sudo is required, then the test will fail. We check for uio_pci_generic as it's a common DPDK driver, but this may need to be adjusted based on the specific driver used in the environment.
    ${output}=    Run Command    ls -l /sys/bus/pci/drivers/uio_pci_generic 
    FOR    ${pci}    IN    @{pci_nics}
        Should Contain    ${output}    ${pci}
        ...    Expected PCI device ${pci} not bound to any DPDK driver. Output: ${output}
    END

Trex trex_cfg.yaml check
    [Arguments]    ${trex_cfg}
    [Documentation]    Verifies that the TRex configuration file exists on the remote host.
    ${output}=    Run Command    test -f ${trex_cfg} && echo exists || echo missing
    ${clean}=     Strip String    ${output}
    Should Be Equal    ${clean}    exists
    ...    TRex configuration file missing: ${trex_cfg}. Output: ${clean}

Compare TRex cfg.yaml
    [Arguments]    ${trex_cfg}    ${expected}
    [Documentation]    Compares the structure and key fields of the TRex config file.
    # Read remote file
    ${raw}=    Run Command    cat ${trex_cfg}
    # Parse YAML (remote file is a list with one dict)
    ${parsed_list}=    Evaluate    yaml.safe_load('''${raw}''')    yaml
    Should Be True    isinstance(${parsed_list}, list)
    ...    TRex cfg.yaml root must be a list
    ${parsed}=    Set Variable    ${parsed_list}[0]
    # Validate required keys exist
    Should Contain    ${parsed}    version
    Should Contain    ${parsed}    interfaces
    Should Contain    ${parsed}    port_info
    Should Contain    ${parsed}    platform
    Should Contain    ${parsed['platform']}    master_thread_id
    Should Contain    ${parsed['platform']}    latency_thread_id
    Should Contain    ${parsed['platform']}    dual_if
    # Compare version
    Should Be Equal    ${parsed['version']}    ${expected['version']}
    ...    TRex config version mismatch
    # Compare interfaces
    Should Be Equal    ${parsed['interfaces']}    ${expected['interfaces']}
    ...    TRex interfaces mismatch
    # Compare port_info
    Should Be Equal    ${parsed['port_info']}    ${expected['port_info']}
    ...    TRex port_info mismatch
    # Compare platform section
    Should Be Equal    ${parsed['platform']['master_thread_id']}    ${expected['platform']['master_thread_id']}
    Should Be Equal    ${parsed['platform']['latency_thread_id']}   ${expected['platform']['latency_thread_id']}
    Should Be Equal    ${parsed['platform']['dual_if']}             ${expected['platform']['dual_if']}