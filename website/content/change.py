import os
import re

# Define the root folder
root_folder = "."  # <-- Change this to your actual folder path

# Regex pattern to match \ket(...)
pattern = re.compile(r"\\ket\(([^()]+)\)")


def process_file(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Replace all \ket(...) with \ket{...}
    new_content = pattern.sub(r"\\ket{\1}", content)

    if new_content != content:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(new_content)
        print(f"Updated: {filepath}")


def walk_folder(folder):
    for dirpath, _, filenames in os.walk(folder):
        for filename in filenames:
            if filename.endswith(
                (".tex", ".txt", ".md")
            ):  # Adjust file types as needed
                process_file(os.path.join(dirpath, filename))


if __name__ == "__main__":
    walk_folder(root_folder)
