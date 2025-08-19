*** Settings ***
Library         SeleniumLibrary     run_on_failure=Nothing
Library         BuiltIn
Library         allure_robotframework

Resource        ../../Resources/common_keywords.resource

Test Teardown    Close All Browsers

*** Variables ***
${START_SESSION_BUTTON}          xpath=//button[.//span[text()='Start Quick Session']]
${BTN_CLOSE_POPUP}               xpath=//fa-icon[contains(@class, 'close-button')]

${VISUAL_TASK}                   xpath=(//div[contains(@class, 'bar-item') and .//p[text()='Visuals Task']])[2]
${TOGGLE_ON}                     xpath=//app-toggle-button-item[normalize-space()='On']
${SLIDER_XPATH}                  //input[@type='range']
${BUBBLE}                        xpath=//span[contains(@class,'value-bubble') and normalize-space()='75%']
${TOGGLE_FIXED}                  xpath=//app-toggle-button-item[@title='Automatic']
${BADGE_FIXED}                   xpath=//span[contains(@class, 'badge') and normalize-space()='Automatic']
${BALL_MOVEMENT_DROPDOWN}        xpath=//h6[normalize-space()='Ball Movement']/following::button[contains(@class,'input')][1]
${OPTION_HORIZONTAL}             xpath=//button[@type='button' and contains(@class,'option')]//div[contains(@class,'label') and normalize-space()='Horizontal']/ancestor::button
${OPTION_VERTICAL}               xpath=//button[@type='button' and .//div[normalize-space()='Vertical']]
${BINAURAL_SECTION}              xpath=//section[.//h6[normalize-space()='Binaural sounds (Beta)']]
${BINAURAL_CHECKBOX}             ${BINAURAL_SECTION}//input[@type='checkbox']

*** Test Cases ***
Verify Therapist can change Ball Speed
    Navigate to Visuals Task
    Verify Visual Task Toggle Is ON
    Set Ball Speed To 75 Percent
    Verify Slider Bubble Value    75%

Verify Therapist can disable Binaural Sound Feature
    Navigate to Visuals Task
    Select Ball Movement    Vertical
    Verify Binaural Section Hidden

Verify that visual task button is ON by default
    Navigate to Visuals Task
    Verify Visual Task Toggle Is ON

Verify Therapist can switch Ball Speed Control from Fixed to Automatic
    Navigate to Visuals Task
    Switch Ball Speed To Automatic
    Verify Ball Speed Badge Is Automatic
    # Sleep       5s

Verify Therapist can enable Binaural Sound Feature
    Navigate to Visuals Task
    Select Ball Movement    Horizontal
    Verify Binaural Section Visible
    Check Binaural Checkbox

*** Keywords ***
Navigate to Visuals Task
    Login With Credentials
    Wait Until Element is Visible       ${START_SESSION_BUTTON}     2s
    Click button                        ${START_SESSION_BUTTON}
    Wait Until Element Is Visible       xpath=//fa-icon[contains(@class, 'close-button')]    timeout=2s
    Click Element                       xpath=//fa-icon[contains(@class, 'close-button')]
    Sleep                               1s
    Wait Until Element Is Visible       ${VISUAL_TASK}    timeout=5s
    Scroll Element Into View            ${VISUAL_TASK}
    Click Element                       ${VISUAL_TASK}
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

Verify Visual Task Toggle Is ON
    ${class}=    Get Element Attribute    ${TOGGLE_ON}    class
    Run Keyword If    'active' in '${class}'    Log    Visual Task button ON
    ...    ELSE    Fail    Visual Task button OFF

Set Ball Speed To 75 Percent
    Execute JavaScript    var slider = document.evaluate("${SLIDER_XPATH}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; if(slider){ slider.value=75; slider.dispatchEvent(new Event('input')); slider.dispatchEvent(new Event('change')); }
    Sleep    1s

Verify Slider Bubble Value
    [Arguments]    ${expected_value}
    Wait Until Element Is Visible       ${BUBBLE}     5s
    Element Text Should Be              ${BUBBLE}     ${expected_value}
    ${value}=    Get Element Attribute  ${SLIDER_XPATH}    value
    Log          Current slider value:  ${value}

Switch Ball Speed To Automatic
    Wait Until Element Is Visible       ${TOGGLE_FIXED}    timeout=5s
    Click Element                       ${TOGGLE_FIXED}
    Sleep                               1s

Verify Ball Speed Badge Is Automatic
    Wait Until Element Is Visible       ${BADGE_FIXED}    timeout=5s
    Element Text Should Be              ${BADGE_FIXED}    Automatic

Select Ball Movement
    [Arguments]    ${direction}
    Wait Until Element Is Visible    ${BALL_MOVEMENT_DROPDOWN}    5s
    Click Element                    ${BALL_MOVEMENT_DROPDOWN}
    Run Keyword If    '${direction}' == 'Horizontal'    Click Element    ${OPTION_HORIZONTAL}
    ...    ELSE    Click Element    ${OPTION_VERTICAL}
    Sleep   1s

Verify Binaural Section Visible
    Wait Until Element Is Visible    ${BINAURAL_SECTION}    5s
    Element Should Be Visible        ${BINAURAL_SECTION}

Check Binaural Checkbox
    ${checked}=    Run Keyword And Return Status    Checkbox Should Be Selected    ${BINAURAL_CHECKBOX}
    Run Keyword If    not ${checked}    Click Element    ${BINAURAL_CHECKBOX}
    Log    Binaural checkbox is checked

Verify Binaural Section Hidden
    ${present}=    Run Keyword And Return Status    Element Should Be Visible    ${BINAURAL_SECTION}
    Run Keyword If    ${present}    Fail    Binaural section should be hidden after selecting Vertical
    ...    ELSE    Log    Binaural section is hidden as expected