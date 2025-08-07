import pyperclip

class ClipboardLibrary:
    def get_clipboard_text(self):
        return pyperclip.paste()