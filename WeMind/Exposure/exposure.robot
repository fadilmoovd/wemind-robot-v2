*** Settings ***
Documentation    Test suite for the Exposure feature.
...              This suite covers copying session links, uploading media,
...              and verifying functionality.

Library          SeleniumLibrary
Library          BuiltIn
Library          String
Library          OperatingSystem
Library          ../../ClipboardLibrary.py

Resource         ../../Resources/common_keywords.resource

Suite Setup      Run Keywords    Open Browser And Login    AND    Set Test Date
Test Teardown    Run Keywords    Auto Screenshot If Failed    AND    Sleep    1s
Suite Teardown   Close Browser
Test Setup       Navigate To Exposure Session

*** Variables ***
${START_SESSION_BUTTON}        xpath=//button[.//span[text()='Start Quick Session']]
${COPY_LINK_BUTTON}            xpath=(//span[@class='ng-star-inserted' and normalize-space(text())='Copy Link'])[1]
${FILE_INPUT}                  css=input[type='file']

# File Paths
${VIDEO_FILE_PATH}             ${CURDIR}/assets/video.mp4
${LARGE_VIDEO_FILE_PATH}       ${CURDIR}/assets/video_30mb.mp4
${AUDIO_FILE_PATH}             ${CURDIR}/assets/audio.mp3
${IMAGE_FILE_PATH}             ${CURDIR}/assets/png.png

# Expected Texts & URLs
${SESSION_URL_PARTIAL}         /client/session?sessionId=
${FILE_TOO_LARGE_ERROR}        Error: file you want to upload is too large (max. 25MB).

*** Test Cases ***
Copy Link And Visit The Link
    [Documentation] 
    [Tags]             smoke    focus
    ${clipboard_link}=    Copy Session Link
    Log    Copied Link: ${clipboard_link}

    Should Not Be Empty         ${clipboard_link}
    Should Contain              ${clipboard_link}    https://
    Should Contain              ${clipboard_link}    ${SESSION_URL_PARTIAL}

    Sleep    2s

    Open Browser    ${clipboard_link}    chrome
    Set Window Size    1280    800

    Wait Until Location Contains    ${SESSION_URL_PARTIAL}    timeout=10s
    Log    Successfully visited the client session link in a new browser session.

    Click Element                   xpath=//button[.//span[text()='Enter Session']]
    Sleep   1s
    Wait Until Element Is Not Visible    xpath=//button[.//span[text()='Enter Session']]    timeout=2s
    Log    Enter Session button is no longer visible.

    Close Browser

Upload Media From Moovd Library
    [Documentation]    Tests uploading a pre-existing media file from the Moovd library.
    Upload Media From Library    3rd Gradation
    Sleep    5s
    Page Should Contain    3rd Gradation

*** Keywords ***
Navigate To Exposure Session
    [Documentation]    This keyword acts as the 'beforeEach' block from Cypress.
    Wait Until Element Is Visible    ${START_SESSION_BUTTON}    timeout=10s
    Click Element                    ${START_SESSION_BUTTON}

Copy Session Link
    [Documentation]    Clicks the 'Copy Link' button and retrieves the text from the clipboard.
    Wait Until Element Is Visible    ${COPY_LINK_BUTTON}
    Click Element                    ${COPY_LINK_BUTTON}
    Sleep    1s
    ${clipboard_text}=              Get Clipboard Text
    [Return]    ${clipboard_text}

Upload Media From Library
    [Arguments]    ${media_title}
    Click Button    xpath=//button[.//span[normalize-space(text())='Moovd media library']]
    Wait Until Element Is Visible    xpath=//div[@class='exposure-library-video-card ng-star-inserted' and @aria-label='Select video: ${media_title}']    timeout=10s
    Click Element    xpath=//div[@class='exposure-library-video-card ng-star-inserted' and @aria-label='Select video: ${media_title}']
    Click Button    xpath=//button[normalize-space(text())='Use Video']