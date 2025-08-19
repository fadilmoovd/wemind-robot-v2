*** Settings ***
Library         SeleniumLibrary     run_on_failure=Nothing
Library         BuiltIn
Library         allure_robotframework

Resource        ../../Resources/common_keywords.resource

Test Teardown    Close All Browsers

*** Variables ***
${START_SESSION_BUTTON}          xpath=//button[.//span[text()='Start Quick Session']]
${BTN_CLOSE_POPUP}               xpath=//fa-icon[contains(@class, 'close-button')]

${AUDIO_TASK}                    xpath=//p[contains(text(), 'Audio Task')]
${AUDIO_TOGGLE_ON}           xpath=//div[h6[normalize-space()='Audio Task']]//app-toggle-button-item[normalize-space(text())='On']
${AUDIO_TYPE_DROPDOWN}       xpath=//section[h6[normalize-space()='Audio type']]//button[contains(@class,'button')]
${AUDIO_TYPE_INTENSE2}       xpath=//button[@title='label.intense2' and .//div[text()='Intense 2']]
${AUDIO_TYPE_SELECTED}       xpath=//section[h6[normalize-space()='Audio type']]//div[contains(@class,'label') and normalize-space()='Intense 2']
${AUDIO_VOLUME_SLIDER}       xpath=//section[h6[normalize-space()='Audio Volume']]//input[@type='range']
${AUDIO_VOLUME_LABEL}        xpath=//section[h6[normalize-space()='Audio Volume']]//div[contains(@class,'value-chip')]
${START_PLAY_BTN}            xpath=//button[@id='start-task' and .//span[text()='Start task(s)']]
${TIMER_LABEL}               xpath=//button[@id='start-task']//span
${AUDIO_TYPE_LABEL}          xpath=//section[h6[normalize-space()='Audio type']]//div[contains(@class,'label') and contains(@class,'ng-star-inserted')]
${AUDIO_TOGGLE_ACTIVE}       xpath=//div[h6[normalize-space()='Audio Task']]//app-toggle-button-item[contains(@class,'active')]

*** Test Cases ***
Change audio type to Intense 2
    Navigate to Audio Task
    Sleep    2s
    Click Element    ${AUDIO_TOGGLE_ON}
    Sleep    2s
    Wait Until Element Is Visible    ${AUDIO_TYPE_DROPDOWN}    5s
    Click Element    ${AUDIO_TYPE_DROPDOWN}
    Sleep    2s
    Wait Until Element Is Visible    ${AUDIO_TYPE_INTENSE2}    5s
    Click Element    ${AUDIO_TYPE_INTENSE2}
    Sleep    2s
    ${selected_text}=    Get Text    ${AUDIO_TYPE_SELECTED}
    Log To Console    Audio type selected: ${selected_text}
    Should Be Equal As Strings    ${selected_text}    Intense 2    msg=Failed to change Audio Type to Intense 2
    Sleep       3s

Lower the audio task volume to 50 percent
    Navigate to Audio Task
    Click Element    ${AUDIO_TOGGLE_ON}
    Sleep    2s

    ${slider_element}=    Get WebElement    ${AUDIO_VOLUME_SLIDER}

    Execute Javascript
    ...    const slider = arguments[0];
    ...    slider.value = 50;
    ...    slider.dispatchEvent(new Event('input', { bubbles: true }));
    ...    slider.dispatchEvent(new Event('change', { bubbles: true }));
    ...    ARGUMENTS    ${slider_element}

    Sleep    1s

    ${newVol}=    Get Text    ${AUDIO_VOLUME_LABEL}
    Log To Console      Volume sekarang: ${newVol}
    Should Be Equal    ${newVol}    50%
    Sleep    3s

Play the Task(s)
    Navigate to Audio Task
    Click Element    ${AUDIO_TOGGLE_ON}
    Sleep    1s
    Wait Until Element Is Visible    ${START_PLAY_BTN}    5s
    Click Element    ${START_PLAY_BTN}
    Sleep    3s
    ${timer}=    Get Text    ${TIMER_LABEL}
    Log To Console    ⏱ Current timer: ${timer}
    Should Not Be Equal    ${timer}    00:00:00
    Sleep       3s

Turn ON audio task from OFF
    Navigate to Audio Task
    Click Element    ${AUDIO_TOGGLE_ON}
    Sleep    2s
    Log To Console    Audio task has been turned ON
    Sleep       3s

Verify audio type is Default by default
    Navigate to Audio Task
    ${audio_type}=    Get Text    ${AUDIO_TYPE_LABEL}
    Log To Console    Audio Type default value: ${audio_type}
    Should Be Equal   ${audio_type}    Default
    Sleep       3s

Verify toggle button is OFF by default
    Navigate to Audio Task
    ${toggle_state}=    Get Text    ${AUDIO_TOGGLE_ACTIVE}
    Log To Console      Current Audio Task toggle state: ${toggle_state}
    Should Be Equal     ${toggle_state}    Off
    Sleep       3s

Verify volume is 100 percent by default
    Navigate to Audio Task
    ${volume}=    Get Text    ${AUDIO_VOLUME_LABEL}
    Log To Console    Audio volume value: ${volume}
    Should Be Equal   ${volume}    100%
    Sleep       3s

*** Keywords ***
Navigate to Audio Task
    Login With Credentials
    Wait Until Element is Visible       ${START_SESSION_BUTTON}     2s
    Click button                        ${START_SESSION_BUTTON}
    Wait Until Element Is Visible       ${BTN_CLOSE_POPUP}    timeout=2s
    Click Element                       ${BTN_CLOSE_POPUP}
    Sleep                               1s
    Wait Until Element Is Visible       ${AUDIO_TASK}    timeout=5s
    Scroll Element Into View            ${AUDIO_TASK}
    Click Element                       ${AUDIO_TASK}
    Sleep                               1s

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
    Sleep               3s