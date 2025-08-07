import requests
# Impor pustaka yang diperlukan dari Robot Framework
from robot.api import ExecutionResult, ResultVisitor

class SlackTestResultListener:
    ROBOT_LISTENER_API_VERSION = 3

    def __init__(self):
        self.webhook_url = "https://hooks.slack.com/services/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"
        print("Listener Slack diinisialisasi dengan URL yang di-hardcode.")

    # Gunakan metode output_file, bukan close. Metode ini dipanggil saat output.xml sudah siap.
    def output_file(self, path):
        # Gunakan ExecutionResult untuk mem-parsing file output.xml
        result = ExecutionResult(path)
        stats = result.statistics.total
        
        passed = stats.passed
        failed = stats.failed
        total = passed + failed

        # Logika Anda yang sudah ada tetap sama
        percentage = (passed / total) * 100 if total > 0 else 0
        
        if failed == 0:
            emoji = "✅ Lulus Semua"
        elif passed == 0:
            emoji = "❌ Gagal Total"
        else:
            emoji = "🟠 Lulus Sebagian"

        summary_message = (
            f"*Summary Tests Report:* {emoji}\n"
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