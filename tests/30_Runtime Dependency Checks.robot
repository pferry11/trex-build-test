*** Settings ***
Resource          ../resources/ssh.resource
Resource          ../resources/common.resource
#Variables         ../variables/trex01.yaml

Suite Setup       Setup SSH Session
Suite Teardown    Close SSH Connection

***Variables ***
#${python_version}    6.9
#${pip_version}    9.0.1

*** Test Cases ***

Verify Python 3 Installation & Version
    [Documentation]    Verifies that Python 3 is installed on the host.
    Python3 version check    ${python_version}  

Check PIP Installation & Version
    [Documentation]    Checks if pip is installed on the host.
    PIP Version check    ${pip_version}    

Check Required PIP Packages
    [Documentation]    Verifies that required pip packages are installed on the host.
    PIP Packages check    @{pip_packages}
     
    
*** Keywords ***
Setup SSH Session
    Load Credentials
    Open SSH Connection    ${host}