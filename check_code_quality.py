#!/usr/bin/env python
"""
Check code quality before creating a code request.

You must install gdtoolkit beforehand:

pip install gdtoolkit

"""

import subprocess
import json


def _run_and_print(command: list[str]) -> None:
    """Run command and print the result in console."""
    try:
        output = subprocess.check_output(command).decode()
        print(output)
    except subprocess.CalledProcessError as e:
        error_output: str = (e.output or b"").decode()
        for line in error_output.split("\n"):
            print(line)


def run_style_formatter() -> None:  # pragma: no cover
    """Run style formatter (gdformat)."""
    print("========================================")
    print("Running gdformat...")
    _run_and_print(["gdformat", "src"])


def run_linter() -> None:  # pragma: no cover
    """Run code quality review (gdlint)."""
    print("========================================")
    print("Code Quality Review (gdlint)")
    _run_and_print(["gdlint", "src"])


def run_tests() -> None:  # pragma: no cover
    """Run unit tests (GUT)."""
    print("========================================")
    print("Running unit tests (GUT)")
    print("  If a file dialog window opens, select your Godot executable.")
    print("  Now running the tests...")
    _run_and_print(["python", "dev_config.py"])
    with open("dev_config.json", "r") as fid:
        dev_config = json.load(fid)
        _run_and_print(
            [
                dev_config["godot_executable"],
                "-d",
                "-s",
#                "--headless",
                "--path",
                "./src",
                "addons/gut/gut_cmdln.gd",
                "-gdir",
                "tests",
                "-gexit_on_success",
            ]
        )


if __name__ == "__main__":  # pragma: no cover
    run_style_formatter()
    run_linter()
    run_tests()
    print("========================================")
    print("Completed.")
    print("Do not forget to merge main into your")
    print("branch and run these checks again.")
    print("========================================")
