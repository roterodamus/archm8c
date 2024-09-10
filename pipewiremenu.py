import curses
import os
import subprocess

# Update the CONFIG_FILE path to the user's home directory
CONFIG_FILE = os.path.expanduser('~/.config/pipewire/pipewire.conf')

def read_config():
    try:
        with open(CONFIG_FILE, 'r') as file:
            return file.readlines()
    except FileNotFoundError:
        return []

def write_config(lines):
    try:
        with open(CONFIG_FILE, 'w') as file:
            file.writelines(lines)
        print("Successfully wrote to the config file.")
    except Exception as e:
        print(f"Error writing to config file: {e}")

def update_parameter(param, new_value):
    lines = read_config()
    updated = False
    for i, line in enumerate(lines):
        if line.strip().startswith(param):
            lines[i] = f"{param} = {new_value}\n"
            updated = True
            break
    if not updated:
        lines.append(f"{param} = {new_value}\n")
    write_config(lines)

def get_current_settings():
    lines = read_config()
    current_settings = {}
    for line in lines:
        if '=' in line:
            key, value = line.split('=', 1)
            current_settings[key.strip()] = value.strip()
    return current_settings

def display_options(stdscr, options, title):
    stdscr.clear()
    stdscr.addstr(0, 0, title)
    stdscr.addstr(1, 0, "Use arrow keys to navigate and Enter to select.")

    current_row = 0
    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, title)
        stdscr.addstr(1, 0, "Use arrow keys to navigate and Enter to select.")

        for idx, option in enumerate(options):
            if idx == current_row:
                stdscr.addstr(idx + 2, 0, option, curses.A_REVERSE)
            else:
                stdscr.addstr(idx + 2, 0, option)

        stdscr.refresh()

        key = stdscr.getch()

        if key == curses.KEY_UP and current_row > 0:
            current_row -= 1
        elif key == curses.KEY_DOWN and current_row < len(options) - 1:
            current_row += 1
        elif key == curses.KEY_ENTER or key in [10, 13]:
            return options[current_row]

def restart_pipewire(stdscr):
    stdscr.clear()
    stdscr.addstr(0, 0, "Restarting pipewire...")
    stdscr.refresh()
    subprocess.run(['systemctl', '--user', 'restart', 'pipewire'])
    stdscr.clear()
    stdscr.addstr(0, 0, "pipewire restarted successfully.")
    stdscr.refresh()
    stdscr.getch()  # Wait for user to press a key

def main(stdscr):
    stdscr.clear()

    options = [
        "Change default.clock.rate",
        "Change default.clock.allowed-rates",
        "Change default.clock.quantum",
        "Change default.clock.min-quantum",
        "Change default.clock.max-quantum",
        "Restart pipewire",
        "Exit"
    ]

    param_map = {
        0: 'default.clock.rate',
        1: 'default.clock.allowed-rates',
        2: 'default.clock.quantum',
        3: 'default.clock.min-quantum',
        4: 'default.clock.max-quantum'
    }

    sensible_options = {
        'default.clock.rate': ['44100', '48000', '96000', '192000'],
        'default.clock.allowed-rates': ['44100', '48000', '96000', '192000'],
        'default.clock.quantum': ['32', '64', '128', '256', '512', '1024', '2048'],
        'default.clock.min-quantum': ['32', '64', '128', '256', '512', '1024', '2048'],
        'default.clock.max-quantum': ['32', '64', '128', '256', '512', '1024', '2048']
    }

    current_row = 0
    current_settings = get_current_settings()

    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, "Current Settings:")
        for idx, param in enumerate(param_map.values()):
            current_value = current_settings.get(param, "Not Set")
            stdscr.addstr(idx + 1, 0, f"{param}: {current_value}")

        stdscr.addstr(len(param_map) + 2, 0, "Options:")
        for idx, option in enumerate(options):
            if idx == current_row:
                stdscr.addstr(len(param_map) + 3 + idx, 0, option, curses.A_REVERSE)
            else:
                stdscr.addstr(len(param_map) + 3 + idx, 0, option)

        stdscr.refresh()

        key = stdscr.getch()

        if key == curses.KEY_UP and current_row > 0:
            current_row -= 1
        elif key == curses.KEY_DOWN and current_row < len(options) - 1:
            current_row += 1
        elif key == curses.KEY_ENTER or key in [10, 13]:
            if current_row == len(options) - 1:  # Exit option
                break
            elif current_row == len(options) - 2:  # Restart pipewire option
                restart_pipewire(stdscr)
            else:
                param = param_map[current_row]
                new_value = display_options(stdscr, sensible_options[param], f"Select a new value for {param}:")
                update_parameter(param, new_value)
                stdscr.clear()
                stdscr.addstr(f"Updated {param} to {new_value}. Press any key to continue...")
                stdscr.refresh()
                stdscr.getch()  # Wait for user to press a key
                current_settings = get_current_settings()  # Refresh current settings after update

if __name__ == "__main__":
    curses.wrapper(main)
