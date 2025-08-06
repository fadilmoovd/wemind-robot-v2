*** Settings ***
Library         SeleniumLibrary

*** Variables ***
${LOGIN_URL}      "https://new.staging.we-mind.app/auth/actor?lang=us"
${BROWSER}        Chrome
${USERNAME}       auto-cypress@moovd.nl
${PASSWORD}       Test@1234

*** Keywords ***
Open Browser And Login
    Open Browser        ${LOGIN_URL}    ${BROWSER}
    Maximize Browser Window
    Input Text          "//input[@placeholder='Enter your email']"    ${USERNAME}
    Input Text          id=password    ${PASSWORD}
    Click Button        css=button[type='submit']
    Wait Until Page Contains    Dashboard    timeout=15s