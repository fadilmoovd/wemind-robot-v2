*** Settings ***
Library         SeleniumLibrary
Library         DateTime
Library         OperatingSystem
Library         RequestsLibrary

*** Variables ***
${LOGIN_URL}        https://new.staging.we-mind.app/auth/actor?lang=us
${BROWSER}          Chrome
${USERNAME}         auto-cypress@moovd.nl
${PASSWORD}         Test@1234

${SLACK_WEBHOOK_URL}    https://hooks.slack.com/services/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

${TODAY}    ${EMPTY}

${field_email}      xpath://input[@placeholder='Enter your email']
${field_password}   xpath://input[@placeholder='Your password']
${btn_login}        xpath://button[.//span[text()='Login']]

*** Keywords ***
Open Browser And Login
    Open Browser        ${LOGIN_URL}    ${BROWSER}
    Maximize Browser Window
    Sleep               2s
    Click Button        xpath=//button[.//span[text()='I am a therapist']]
    Wait Until Element Is Visible    ${field_email}       timeout=5s
    Wait Until Element Is Visible    ${field_password}    timeout=5s
    Wait Until Element Is Visible    ${btn_login}         timeout=5s
    Input Text          ${field_email}          ${USERNAME}
    Input Text          ${field_password}       ${PASSWORD}
    Click Button        ${btn_login}

Set Test Date
    ${date}=    Get Current Date    result_format=%Y-%m-%d
    Set Suite Variable    ${TODAY}    ${date}

Auto Screenshot If Failed
    Run Keyword If Test Failed    Create Screenshot Directory And Capture

Create Screenshot Directory And Capture
    [Documentation]    Creates a dated directory and captures a screenshot upon failure.

    # === MATA-MATA KITA MULAI DI SINI ===
    Log To Console    \n--- DEBUGGING SCREENSHOT ---
    Log To Console    [Mata-Mata] Nilai ${TODAY} adalah: '${TODAY}'
    
    ${dir}=    Set Variable    results/${TODAY}
    Log To Console    [Mata-Mata] Direktori yang akan dibuat: '${dir}'
    Create Directory    ${dir}
    
    ${time}=    Get Time    result_format=%H-%M
    # ${filename}=    Set Variable    ${TEST NAME}_${time}.png
    ${filename}=    Set Variable    TES_GANTENG_BERHASIL_${time}.png
    
    ${screenshot_path}=    Set Variable    ${dir}/${filename}
    Log To Console    [Mata-Mata] Path screenshot lengkap: '${screenshot_path}'
    Log To Console    --- SELESAI DEBUGGING ---\n

    Capture Page Screenshot    ${screenshot_path}
    Log To Console    [Screenshot saved to] ${screenshot_path}

Send Slack Message
    [Arguments]    ${message}

    ${headers}=    Create Dictionary    Content-type=application/json
    ${body}=       Create Dictionary    text=${message}
    ${response}=   POST
    ...            url=${SLACK_WEBHOOK_URL}
    ...            json=${body}
    ...            headers=${headers}

    Log To Console    \nNotifikasi Slack Terkirim: ${response.status_code}

Send Result Test
    [Documentation]    Menyiapkan pesan laporan dan mengirimnya ke Slack.
    
    ${status_emoji}=    Set Variable If    '${SUITE_STATUS}' == 'PASS'    ✅    ❌

    ${pesan_laporan}=   Set Variable
    ...                 *Laporan Tes Selesai:* `${SUITE_NAME}`\n*Status:* `${SUITE_STATUS}` ${status_emoji}

    Send Slack Message    ${pesan_laporan}