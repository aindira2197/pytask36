import os
import time
import hashlib

class FileWatcher:
    def __init__(self, directory):
        self.directory = directory
        self.files = {}
        self.check_interval = 1

    def start(self):
        while True:
            self.check_files()
            time.sleep(self.check_interval)

    def check_files(self):
        for filename in os.listdir(self.directory):
            filepath = os.path.join(self.directory, filename)
            if os.path.isfile(filepath):
                file_hash = self.get_file_hash(filepath)
                if filepath not in self.files or self.files[filepath] != file_hash:
                    self.files[filepath] = file_hash
                    self.on_file_change(filepath)

    def get_file_hash(self, filepath):
        with open(filepath, 'rb') as file:
            file_content = file.read()
            return hashlib.md5(file_content).hexdigest()

    def on_file_change(self, filepath):
        print(f"File {filepath} has been changed")

def main():
    watcher = FileWatcher('/path/to/directory')
    watcher.start()

if __name__ == "__main__":
    main()

import threading
class WatcherThread(threading.Thread):
    def __init__(self, watcher):
        threading.Thread.__init__(self)
        self.watcher = watcher

    def run(self):
        self.watcher.start()

def run_watcher():
    watcher = FileWatcher('/path/to/directory')
    thread = WatcherThread(watcher)
    thread.start()

class WatcherConfig:
    def __init__(self, directory, interval):
        self.directory = directory
        self.interval = interval

def get_config():
    return WatcherConfig('/path/to/directory', 1)

def create_watcher(config):
    return FileWatcher(config.directory)

def start_watcher(watcher):
    watcher.start()

def get_watcher(config):
    return create_watcher(config)

def run_watcher_with_config(config):
    watcher = get_watcher(config)
    start_watcher(watcher)

def main_with_config():
    config = get_config()
    run_watcher_with_config(config)

if __name__ == "__main__":
    main_with_config()