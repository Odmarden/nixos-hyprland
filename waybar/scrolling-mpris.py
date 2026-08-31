#!/usr/bin/env python3
import subprocess
import time
import json
import shutil

GLYPHS = {
    "paused": "",
    "playing": "",
    "stopped": ""
}
DEFAULT_GLYPH = ""
TEXT_WHEN_STOPPED = "Nothing playing"
SCROLL_TEXT_LENGTH = 24
REFRESH_INTERVAL = 0.5
PLAYERCTL = shutil.which("playerctl") or "playerctl"

def get_player_status():
    try:
        result = subprocess.run([PLAYERCTL, "status"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        status = result.stdout.strip().lower()
        if result.returncode != 0 or not status:
            return "stopped"
        return status
    except Exception:
        return "stopped"

def get_current_song():
    try:
        result = subprocess.run([PLAYERCTL, "metadata", "--format", "{{artist}} - {{title}}"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        song_title = result.stdout.strip()
        if result.returncode != 0 or not song_title or song_title == " - ":
            # Fallback to title only
            res2 = subprocess.run([PLAYERCTL, "metadata", "title"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            song_title = res2.stdout.strip()
            if not song_title:
                return None
        return song_title
    except Exception:
        return None

def scroll_text(text, length=SCROLL_TEXT_LENGTH):
    text = text.ljust(length)
    scrolling_text = text + " | " + text[:length]
    for i in range(len(scrolling_text) - length):
        yield scrolling_text[i:i + length]

if __name__ == "__main__":
    scroll_generator = None
    last_song = None
    
    while True:
        output = {}
        try:
            status = get_player_status()
            song = get_current_song()
            glyph = GLYPHS.get(status, DEFAULT_GLYPH)

            if song:
                if song != last_song:
                    last_song = song
                    scroll_generator = None

                if len(song) > SCROLL_TEXT_LENGTH:
                    if scroll_generator is None:
                        scroll_generator = scroll_text(song)
                    try:
                        song_text = next(scroll_generator)
                    except StopIteration:
                        scroll_generator = scroll_text(song)
                        song_text = next(scroll_generator)
                else:
                    song_text = song.ljust(SCROLL_TEXT_LENGTH)
                    scroll_generator = None
                output["text"] = f"{glyph} {song_text}"
            else:
                last_song = None
                scroll_generator = None
                output["text"] = f"{glyph} {TEXT_WHEN_STOPPED}"

        except Exception as e:
            output["text"] = f" Error: {str(e)}"

        print(json.dumps(output), flush=True)
        time.sleep(REFRESH_INTERVAL)
