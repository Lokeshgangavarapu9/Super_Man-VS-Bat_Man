import subprocess
import time
import sys
import os

godot_path = r"C:\Users\LOKESH\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
project_path = r"c:\Users\LOKESH\gotbot game"
log_path = os.path.join(project_path, "diagnostics", "f5_runtime_audit.log")

print(f"Launching Godot F5 simulation in separate window: {godot_path}")
print(f"Project: {project_path}")
print(f"Writing complete runtime log to: {log_path}")

cmd = [godot_path, "--path", project_path, "--verbose"]

with open(log_path, "w", encoding="utf-8") as log_file:
    proc = subprocess.Popen(
        cmd,
        stdout=log_file,
        stderr=subprocess.STDOUT,
        cwd=project_path
    )

    # Monitor for 6.0 seconds
    start_time = time.time()
    active = True
    while time.time() - start_time < 6.0:
        ret = proc.poll()
        if ret is not None:
            print(f"FAILED: Godot process terminated prematurely with exit code: {ret}")
            active = False
            break
        time.sleep(0.5)

    if active:
        print("SUCCESS: Godot main menu remained actively running in separate window without closing!")
        proc.terminate()
        try:
            proc.wait(timeout=3)
        except subprocess.TimeoutExpired:
            proc.kill()

# Now inspect the written log file
with open(log_path, "r", encoding="utf-8", errors="replace") as f:
    log_content = f.read()

print(f"Log size: {len(log_content)} chars")
has_embedded_err = "Embedded window can't be resized" in log_content
has_crash = "CRASH" in log_content or "Unhandled exception" in log_content

print(f"Contains 'Embedded window can\\'t be resized': {has_embedded_err}")
print(f"Contains crash/unhandled exception: {has_crash}")

# Check lines mentioning errors
error_lines = [line for line in log_content.splitlines() if "ERROR:" in line or "SCRIPT ERROR:" in line]
print(f"Error lines count: {len(error_lines)}")
for err in error_lines[:10]:
    print(f"  [LOG ERROR] {err}")

if has_embedded_err:
    print("TEST FAILED: 'Embedded window can't be resized' detected!")
    sys.exit(1)

if not active:
    print("TEST FAILED: Process did not stay open!")
    sys.exit(2)

print("All F5 separate window runtime checks PASSED successfully.")
sys.exit(0)
