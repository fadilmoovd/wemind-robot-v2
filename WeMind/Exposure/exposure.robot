*** Settings ***
Documentation    Test suite for the Exposure feature.
...              This suite covers copying session links, uploading media,
...              and verifying functionality.

Library          SeleniumLibrary
Library          BuiltIn
Library          String

Resource         ../Resource/common_keywords.resource

Suite Setup      Open Browser And Login
Suite Teardown   Close Browser
Test Setup       Navigate To Exposure Session
Test Teardown    Sleep    1s

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
${EXPOSURE_SESSION_HEADER}     xpath=//h1[contains(text(), 'Exposure Session')]
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

    # Visit link and verify
    Go To                       ${clipboard_link}
    Wait Until Location Contains    ${SESSION_URL_PARTIAL}    timeout=20s
    Wait Until Element Is Visible    ${EXPOSURE_SESSION_HEADER}    timeout=10s
    Log    Successfully visited the client session link.

Upload Media From Moovd Library
    [Documentation]    Tests uploading a pre-existing media file from the Moovd library.
    Upload Media From Library    3rd Gradation
    Sleep    5s
    Page Should Contain    3rd Gradation    # Assuming the title appears after upload

Upload Media From Local Storage
    [Documentation]    Tests uploading a standard video file from the local machine.
    Upload Local File    ${VIDEO_FILE_PATH}
    Verify Media Has Loaded

Fail To Upload Media Larger Than 25MB
    [Documentation]    Ensures the application shows an error for files exceeding the size limit.
    Upload Local File    ${LARGE_VIDEO_FILE_PATH}
    Wait Until Page Contains    ${FILE_TOO_LARGE_ERROR}    timeout=5s
    Element Should Be Visible    xpath=//*[contains(text(), '${FILE_TOO_LARGE_ERROR}')]
    Log    Error message for large file was displayed correctly.

Upload Audio From Local Storage
    [Documentation]    Tests uploading an audio file from the local machine.
    Upload Local File    ${AUDIO_FILE_PATH}
    Verify Media Has Loaded

Upload Image From Local Storage
    [Documentation]    Tests uploading an image file from the local machine.
    Upload Local File    ${IMAGE_FILE_PATH}
    Verify Media Has Loaded

Verify Uploaded Video Can Be Played
    [Documentation]    Uploads a video and verifies its duration is correctly loaded, indicating it's ready for playback.
    Upload Local File    ${VIDEO_FILE_PATH}
    Verify Media Has Loaded And Can Play

*** Keywords ***
Navigate To Exposure Session
    [Documentation]    This keyword acts as the 'beforeEach' block from Cypress.
    Wait Until Element Is Visible    ${START_SESSION_BUTTON}    timeout=10s
    Click Element                    ${START_SESSION_BUTTON}

Copy Session Link
    [Documentation]    Clicks the 'Copy Link' button and retrieves the text from the clipboard.
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
    Click Button    xpath=//button[.//span[normalize-space(text())='Moovd media library']]
    Wait Until Element Is Visible    xpath=//div[@class='exposure-library-video-card ng-star-inserted' and @aria-label='Select video: ${media_title}']    timeout=10s
    Click Element    xpath=//div[@class='exposure-library-video-card ng-star-inserted' and @aria-label='Select video: ${media_title}']
    Click Button    xpath=//button[normalize-space(text())='Use Video']

Upload Local File
    [Arguments]    ${file_path}
    Wait Until Element Is Visible    ${FILE_INPUT}
    Choose File    ${FILE_INPUT}    ${file_path}

Verify Media Has Loaded
    [Documentation]    Waits until the media duration is not '00:00', indicating it has processed.
    Wait Until Element Does Not Contain    xpath=//p[contains(@class,'video-duration')]    / 00:00    timeout=60s
    Log    ✅ Media successfully loaded!

Verify Media Has Loaded And Can Play
    [Documentation]    A more robust check that handles cases where the duration might not update immediately.
    Wait Until Element Is Visible    xpath=//p[contains(@class,'video-duration')]    timeout=60s
    ${duration_text}=    Get Text    xpath=//p[contains(@class,'video-duration')]

    IF    "'${duration_text}'.endswith('/ 00:00')"
        Log    ⚠️ Duration is still 00:00, trying to click Play    console=yes
        Click Element    xpath=//button[.//fa-icon//*[contains(@data-icon,'play')]]
        Wait Until Element Does Not Contain    xpath=//p[contains(@class,'video-duration')]    / 00:00    timeout=60s
    END
    Log    ✅ Video successfully loaded and is playable!