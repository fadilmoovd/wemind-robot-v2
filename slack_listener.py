import requests
from robot.api import ExecutionResult, ResultVisitor

class SlackTestResultListener:
    ROBOT_LISTENER_API_VERSION = 3

    def __init__(self):
        self.webhook_url = "https://hooks.slack.com/services/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"
        print("Listener Slack diinisialisasi dengan URL yang di-hardcode.")

    def output_file(self, path):
        result = ExecutionResult(path)
        stats = result.statistics.total
        
        passed = stats.passed
        failed = stats.failed
        total = passed + failed

        # Logika Anda yang sudah ada tetap sama
        percentage = (passed / total) * 100 if total > 0 else 0
        
        # if failed == 0:
        #     emoji = "✅ Passed All"
        # elif passed == 0:
        #     emoji = "❌ Failed All"
        # else:
        #     emoji = "🟠 Not All Passed"

        summary_message = (
            f"*Summary Tests Report:*\n"
            f"- Passed     : {passed}\n"
            f"- Failed     : {failed}\n"
            f"*Total* : *{total}*\n"
            f"*Percentage* : *{percentage:.2f}%*"
        )

        payload = {"text": summary_message}
        headers = {"Content-type": "application/json"}

        try:
            response = requests.post(self.webhook_url, json=payload, headers=headers)
            response.raise_for_status()
            print("Laporan ringkasan berhasil dikirim ke Slack.")
        except requests.exceptions.RequestException as e:
            print(f"Error saat mengirim laporan ke Slack: {e}")