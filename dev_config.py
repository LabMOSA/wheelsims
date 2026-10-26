from tkinter import filedialog
import json

if __name__ == "__main__":  # pragma: no cover
    try:
        with open("dev_config.json", "r") as fid:
            dev_config = json.load(fid)
    except FileNotFoundError:
        dev_config = {}

    if (
        "godot_executable" not in dev_config
        or dev_config["godot_executable"] is None
    ):
        print("Select Godot executable")
        dev_config["godot_executable"] = filedialog.askopenfilename()
        if dev_config["godot_executable"].endswith(".app"):
            # macOS
            dev_config["godot_executable"] += "/Contents/MacOS/Godot"
        with open("dev_config.json", "w") as fid:
            json.dump(dev_config, fid)
