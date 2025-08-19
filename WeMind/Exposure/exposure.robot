*** Settings ***
Library          SeleniumLibrary  run_on_failure=Nothing
Library          BuiltIn
Library          String
Library          OperatingSystem
Library          ../../ClipboardLibrary.py
Library         allure_robotframework

Resource         ../Resource/common_keywords.resource

Test Setup    Open Browser And Login And Navigate To Exposure Session
Test Teardown    Close All Browsers

*** Variables ***
${START_SESSION_BUTTON}        xpath=//button[.//span[text()='Start Quick Session']]
${COPY_LINK_BUTTON}            xpath=(//span[@class='ng-star-inserted' and normalize-space(text())='Copy Link'])[1]
${FILE_INPUT}                  css=input[type='file']

# File Paths
${VIDEO_REL_PATH}     ${CURDIR}/../../assets/video.mp4
${AUDIO_REL_PATH}     ${CURDIR}/../../assets/audio.mp3
${IMAGE_REL_PATH}     ${CURDIR}/../../assets/png.png

${LARGE_VIDEO_FILE_PATH}       ${CURDIR}/assets/video_30mb.mp4
${AUDIO_FILE_PATH}             ${CURDIR}/assets/audio.mp3
${IMAGE_FILE_PATH}             ${CURDIR}/assets/png.png

${SESSION_URL_PARTIAL}         /client/session?sessionId=
${FILE_TOO_LARGE_ERROR}        Error: file you want to upload is too large (max. 25MB).

*** Test Cases ***
Copy Link And Visit The Link
    [Documentation]    Verifies that the session link can be copied and visited.
    ...                Corresponds to the 'it.only' test.
    [Tags]             smoke    focus
    ${clipboard_link}=    Copy Session Link
    Log    Copied Link: ${clipboard_link}

    # Assertions
    Should Not Be Empty         ${clipboard_link}
    Should Contain              ${clipboard_link}    https://
    Should Contain              ${clipboard_link}    ${SESSION_URL_PARTIAL}

    Sleep    2s

    Open Browser    ${clipboard_link}    chrome
    Set Window Size    1280    800

    Wait Until Location Contains    ${SESSION_URL_PARTIAL}    timeout=2s
    Log    Successfully visited the client session link in a new browser session.

    Click Element                   xpath=//button[.//span[text()='Enter Session']]
    Sleep   1s
    Wait Until Element Is Not Visible    xpath=//button[.//span[text()='Enter Session']]    timeout=2s
    Log    Enter Session button is no longer visible.

Upload Media From Moovd Library
    Prepare Copy Link
    # Navigate To Exposure Session
    Upload Media From Library    3rd Gradation
    Sleep    8s
    Page Should Contain    3rd Gradation

Upload Video From Local
    Prepare Copy Link
    Upload Media From Local    ${VIDEO_REL_PATH}
    Sleep   8s

Upload Audio From Local
    Prepare Copy Link
    Upload Media From Local    ${AUDIO_REL_PATH}
    Sleep   8s

Upload Image From Local
    Prepare Copy Link
    Upload Media From Local    ${IMAGE_REL_PATH}
    Sleep   8s

*** Keywords ***
Navigate To Exposure Session
    Wait Until Element Is Visible    ${START_SESSION_BUTTON}    timeout=10s
    Click Element                    ${START_SESSION_BUTTON}

Copy Session Link
    Wait Until Element Is Visible    ${COPY_LINK_BUTTON}
    Click Element                    ${COPY_LINK_BUTTON}
    Sleep    1s    # Allow a moment for the clipboard action to complete
    ${clipboard_text}=    Get Text From Clipboard
    [Return]    ${clipboard_text}

Get Text From Clipboard
    [Documentation]    Executes JavaScript to read text from the browser's clipboard.
    ${script}=    Catenate
    ...    "const text = await navigator.clipboard.readText();"
    ...    "arguments[0](text);"
    ${text}=    Execute Async Javascript    ${script}
    [Return]    ${text}

Upload Media From Library
    [Arguments]    ${media_title}
    Sleep    2s
    Wait Until Element Is Visible    xpath=(//div[contains(@class, 'bar-item') and .//p[text()='Exposure']])[2]    timeout=10s
    Scroll Element Into View         xpath=(//div[contains(@class, 'bar-item') and .//p[text()='Exposure']])[2]
    Click Element                    xpath=(//div[contains(@class, 'bar-item') and .//p[text()='Exposure']])[2]

    Wait Until Element Is Visible   xpath=//button[.//span[normalize-space(text())='Moovd media library']]
    Click Button    xpath=//button[.//span[normalize-space(text())='Moovd media library']]
    Wait Until Element Is Visible    xpath=//div[@class='exposure-library-video-card ng-star-inserted' and @aria-label='Select video: ${media_title}']    timeout=10s
    Click Element    xpath=//div[@class='exposure-library-video-card ng-star-inserted' and @aria-label='Select video: ${media_title}']
    Sleep           2s
    Click Button    xpath=//button[normalize-space(text())='Use Video']
    Sleep           3s

Prepare Copy Link
    Switch Browser          main_browser
    ${clipboard_link}=    Copy Session Link
    Log    Copied Link: ${clipboard_link}

    Should Not Be Empty         ${clipboard_link}
    Should Contain              ${clipboard_link}    https://
    Should Contain              ${clipboard_link}    ${SESSION_URL_PARTIAL}

    Sleep    2s

    Open Browser            ${clipboard_link}    chrome    alias=client_browser
    Set Window Size    1280    800

    Wait Until Location Contains    ${SESSION_URL_PARTIAL}    timeout=2s
    Log    Successfully visited the client session link in a new browser session.

    Click Element                   xpath=//button[.//span[text()='Enter Session']]
    Sleep   1s
    Wait Until Element Is Not Visible    xpath=//button[.//span[text()='Enter Session']]    timeout=2s
    Log    Enter Session button is no longer visible.
    Switch Browser          main_browser
    Wait Until Element Is Visible       xpath=//fa-icon[contains(@class, 'close-button')]    timeout=2s
    Click Element                       xpath=//fa-icon[contains(@class, 'close-button')]

Upload Media From Local
    [Arguments]    ${file_path}
    Sleep    2s
    Wait Until Element Is Visible    xpath=(//div[contains(@class, 'bar-item') and .//p[text()='Exposure']])[2]    timeout=10s
    Scroll Element Into View         xpath=(//div[contains(@class, 'bar-item') and .//p[text()='Exposure']])[2]
    Click Element                    xpath=(//div[contains(@class, 'bar-item') and .//p[text()='Exposure']])[2]
    # Wait Until Element Is Visible    ${FILE_INPUT}    timeout=10s
    # Choose File                      ${FILE_INPUT}    ${file_path}
    ${canonical_path}=              Get Canonical Path    ${file_path}
    Choose File                     xpath=//input[@type="file"]    ${canonical_path}
    Sleep    2s

Get Canonical Path
    [Arguments]    ${relative_path}
    ${abs_path}=    Normalize Path    ${relative_path}
    [Return]    ${abs_path}

Open Browser And Login And Navigate To Exposure Session
    Open Browser    ${LOGIN_URL}    chrome    alias=main_browser
    Set Window Size    1280    800
    Login With Credentials
    Navigate To Exposure Session

Login With Credentials
    Open Browser        ${LOGIN_URL}    ${BROWSER}  alias=main_browser
    Maximize Browser Window
    Sleep               3s
    Wait Until Element Is Visible    xpath=//button[.//span[text()='I am a therapist']]    timeout=3
    Click Button        xpath=//button[.//span[text()='I am a therapist']]
    Wait Until Element Is Visible    ${field_email}       timeout=2s
    Wait Until Element Is Visible    ${field_password}    timeout=2s
    Wait Until Element Is Visible    ${btn_login}         timeout=2s
    Input Text          ${field_email}          ${USERNAME}
    Input Text          ${field_password}       ${PASSWORD}
    Click Button        ${btn_login}
