شرح سكربت Bash لأتمتة إصلاح مشاكل GitHub
https://gemini.google.com/app/d31e54334480ec79

User prompt: تمام أنا الأن على ويندوز لذلك لا يعمل ال sh عندي أريده لل powershell لكن الريبو اللذي أريده هو aazanabili/wisperlive
Response: إليك السكربت محولاً بالكامل إلى صيغة PowerShell (.ps1) ومخصصاً للمستودع الخاص بك aazanabili/wisperlive:
# 1. جلب روابط الـ Issues المفتوحة بصيغة JSON وتحويلها لكائنات في PowerShell
$repo = "aazanabili/wisperlive"
$rawIssues = gh issue list --repo $repo --json url | ConvertFrom-Json
$issues = $rawIssues.url

foreach ($issue in $issues) {
    Write-Host "`nProcessing issue: $issue" -ForegroundColor Cyan

    # 2. تصنيف المشكلة عبر OpenCode
    $class = (opencode run "Classify $issue as a BUG, FEAT, or POLISH. One word only!").Trim()
    Write-Host "Class: $class" -ForegroundColor Yellow

    # 3. التحقق إذا كانت المشكلة خطأ برمجي (BUG)
    if ($class -match "BUG") {
        Write-Host "Fixing BUG..." -ForegroundColor Green
        opencode run "Fix this issue: $issue. Create a new git branch."

        # 4. فحص جودة الحل
        $result = opencode run "Verify if the solution addresses this issue: $issue. If addressed, reply with PASS only. Otherwise explain the blocker."
        Write-Host "Result is: $result"

        # 5. حلقة التكرار في حال عدم اجتياز الفحص
        while ($result -notmatch "PASS") {
            Write-Host "Re-attempting fix..." -ForegroundColor Magenta
            opencode run "Your implementation does not address this issue: $issue. The blockers: $result. Fix it now."
            $result = opencode run "Verify if the solution addresses this issue: $issue. If addressed, reply with PASS only."
            Write-Host "Re-evaluation result: $result"
        }

        # 6. رفع التعديلات وفتح PR والعودة للفرع الرئيسي
        opencode run "Open a PR from the current branch. Checkout to main."
        Write-Host "Pull Request opened successfully!" -ForegroundColor Green
    }
}




1إنشاء ملف السكربت
1 دقيقة

افتح مسار مشروعك في PowerShell وأنشئ ملفًا جديدًا باسم auto_fix.ps1:
New-Item -ItemType File -Name "auto_fix.ps1"


الصق الكود البرمجي أعلاه داخل الملف باستخدام أي محرر نصوص (مثل VS Code أو Notepad عبر أمر notepad auto_fix.ps1).
التحقق: تأكد من وجود الملف في المجلد عبر كتابة ls auto_fix.ps1.

2تفعيل صلاحية تشغيل السكربتات (إن لزم)
PowerShell Security

إذا واجهت رسالة تمنع تشغيل ملفات .ps1 في ويندوز (Execution Policy)، قم بالسماح بتشغيل السكربتات للجلسة الحالية فقط:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass


التحقق: يكتمل الأمر دون إظهار أخطاء أمان حمراء.

3تنفيذ السكربت
تشغيل

شغل السكربت مباشرة من المسار:
.\auto_fix.ps1


التحقق: ستبدأ الطرفية بطباعة روابط المشاكل Processing issue: ... وبدء تصنيفها عبر OpenCode.

User prompt: Now, I would like you to create documentation for a skill. The purpose of this skill is to write .sh or .ps1 script files on demand. It could include loops, specific commands, or other instructions for OpenCode. Whatever input I provide, this skill should convert it into executable commands within a .ps1 or .sh file, as requested, ensuring the file executes the commands exactly as I specify.
Response: Here is the complete specification and system prompt documentation for the script generator skill.
Skill Documentation: Shell & PowerShell Script Generator (script-crafter)
Skill Name: script-crafter
Target Environments: Linux / macOS (.sh / POSIX Bash) & Windows (.ps1 / PowerShell 7+)
Primary Integration: CLI agent workflows, loop orchestration, CLI tool pipelines (such as gh, opencode, Git, Docker).
1. Skill Purpose & Behavior
The script-crafter skill takes natural language descriptions, logic loops, or high-level instructions and turns them into ready-to-run, syntactically correct .sh or .ps1 files.
Target Output Matching: Writes exclusively in .sh (Bash) or .ps1 (PowerShell) based on explicit user choice or platform context.
OpenCode / Agent Ready: Correctly structures non-interactive calls (e.g., opencode run "<prompt>"), passes clean string variables, and avoids quoting breakage across nested commands.
Defensive Scripting: Implements error handling, status output, variable trimming, and regex matching for loop conditions.
2. Platform Standard Conventions

Feature
POSIX Bash (.sh)
PowerShell (.ps1)
Interpreter / Shebang
#!/usr/bin/env bash
# Requires -Version 7.0 (optional)
Error Handling
set -euo pipefail
$ErrorActionPreference = 'Stop'
Loop Syntax
for item in $list; do ... done
foreach ($item in $list) { ... }
Condition Check
if [[ "$val" =~ "REGEX" ]]; then
if ($val -match "REGEX") { ... }
CLI Output Capture
output=$(cmd)
$output = (cmd)
Whitespace Trim
echo "$val" | tr -d '[:space:]'
$val.Trim()

3. Skill System Prompt (Copy-Paste Definition)
You can save this prompt directly into your agent instructions or custom system instructions:
You are a deterministic scripting specialist that generates executable `.sh` (Bash) and `.ps1` (PowerShell) scripts.

### Core Rules:
1. Target Selection:
   - Output `.ps1` when Windows or PowerShell is requested.
   - Output `.sh` when Linux, macOS, or Bash is requested.
   - Default to POSIX-compliant Bash if unspecified.

2. Command Formatting:
   - Wrap non-interactive AI agent calls properly (e.g., `opencode run "<prompt>"`).
   - Sanitize dynamic values using string interpolation (e.g., `"$issue"` in Bash, `"$issue"` in PowerShell).
   - For validation loops, always implement string/regex matching (`=~` in Bash, `-match` in PowerShell) rather than exact literal matches to tolerate whitespace and trailing punctuation from LLM responses.

3. Script Scaffolding:
   - Bash: Always include `#!/usr/bin/env bash`.
   - PowerShell: Always use explicit parameter handling or clean variable definitions. Provide terminal execution policy bypass guidance when relevant (`Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`).
   - Include colored or formatted status feedback (`echo` in Bash, `Write-Host` in PowerShell).

4. Output Format:
   - Provide the complete, un-truncated script in a single code block.
   - Follow immediately with execution commands:
     * Bash: `chmod +x <filename>.sh && ./<filename>.sh`
     * PowerShell: `.\<filename>.ps1`


4. Input & Output Contract
User Input Formats Accepted:
Task flow descriptions: "Loop over all local Docker containers, run opencode run to inspect logs, and restart failed ones."
Tool chains: "Fetch all pull requests via gh pr list, review them with OpenCode, and merge if passing."
Direct syntax conversion: Converting an existing .sh loop to Windows .ps1, or vice versa.
Standard Output Structure:
Target file name and description.
Complete runnable code block.
Execution instructions for the target terminal.
5. Reference Examples
Example A: GitHub Issue Triage (.sh)
#!/usr/bin/env bash
set -euo pipefail

REPO="owner/repo"
issues=$(gh issue list --repo "$REPO" --json url --jq '.[].url')

for issue in $issues; do
  echo "Triage: $issue"
  category=$(opencode run "Classify $issue as CRITICAL or NORMAL. Return one word.")
  
  if [[ "$category" =~ "CRITICAL" ]]; then
    opencode run "Fix high priority issue immediately: $issue"
  fi
done


Example B: GitHub Issue Triage (.ps1)
$ErrorActionPreference = 'Stop'

$repo = "owner/repo"
$rawIssues = gh issue list --repo $repo --json url | ConvertFrom-Json
$issues = $rawIssues.url

foreach ($issue in $issues) {
    Write-Host "Triage: $issue" -ForegroundColor Cyan
    $category = (opencode run "Classify $issue as CRITICAL or NORMAL. Return one word.").Trim()

    if ($category -match "CRITICAL") {
        Write-Host "Fixing critical issue..." -ForegroundColor Red
        opencode run "Fix high priority issue immediately: $issue"
    }
}



User prompt: How can I configure OpenCode to use a specific LLM model from a provider I am connected to, and grant it custom permissions that I define? Specifically, in the script file we want to create (whether an `.sh` or `.ps1` file), we should be able to specify the provider linked within OpenCode, its designated LLM, and potentially assign an agent as well as executable permissions, allowing for highly advanced and robust customization. How can we achieve this? Please search the web, think it through carefully, and provide me with the answer.
Response: OpenCode provides native CLI flags and configuration structures designed specifically for specifying the exact model, agent, and permission boundaries.
1. Model & Provider Syntax
Models in OpenCode follow the standard naming format:
<provider_id>/<model_name>


To verify the exact identifier for your connected providers and models, run:
opencode models


Examples: anthropic/claude-sonnet-4-5, openai/gpt-4o, or local endpoints like ollama/qwen2.5-coder:32b.
2. Permissions Architecture in OpenCode
OpenCode enforces security through permission rules (allow, ask, or deny) across actions such as bash, read, edit, glob, and grep.
Non-interactive / Script Execution (--auto):
In headless automation, use the --auto flag. This automatically approves any tool action that is set to allow or ask, while still enforcing strict deny rules without halting execution.
Inline Dynamic Permissions (OPENCODE_CONFIG_CONTENT):
You can inject JSON permissions directly inside the script execution environment without modifying system-wide files.
3. Implementing the Customized Script
Option A: Windows PowerShell (.ps1)
$ErrorActionPreference = 'Stop'

# Define Provider, Model, and Optional Agent
$PROVIDER = "anthropic"
$MODEL_NAME = "claude-sonnet-4-5"
$TARGET_MODEL = "$PROVIDER/$MODEL_NAME"
$AGENT = "build"   # Default agents: 'build', 'plan', or custom

# Define Granular Security Policies (Inline JSON configuration)
# Restricts dangerous commands while allowing safe git/npm actions
$env:OPENCODE_CONFIG_CONTENT = @"
{
  "permission": {
    "bash": {
      "rm *": "deny",
      "git push *": "deny",
      "*": "allow"
    },
    "edit": "allow",
    "read": "allow"
  }
}
"@

$repo = "aazanabili/wisperlive"
$rawIssues = gh issue list --repo $repo --json url | ConvertFrom-Json
$issues = $rawIssues.url

foreach ($issue in $issues) {
    Write-Host "Analyzing issue: $issue" -ForegroundColor Cyan

    # Invocation specifying model, agent, auto-approvals, and prompt
    $class = (opencode run `
        --model $TARGET_MODEL `
        --agent $AGENT `
        --auto `
        "Classify $issue as a BUG, FEAT, or POLISH. One word only!").Trim()

    Write-Host "Classification: $class" -ForegroundColor Yellow

    if ($class -match "BUG") {
        Write-Host "Fixing issue with $TARGET_MODEL..." -ForegroundColor Green
        
        opencode run `
            --model $TARGET_MODEL `
            --agent $AGENT `
            --auto `
            "Fix this issue: $issue. Create a new git branch."
    }
}


Option B: Linux / macOS Bash (.sh)
#!/usr/bin/env bash
set -euo pipefail

PROVIDER="anthropic"
MODEL_NAME="claude-sonnet-4-5"
TARGET_MODEL="${PROVIDER}/${MODEL_NAME}"
AGENT="build"

# Inline granular permission schema
export OPENCODE_CONFIG_CONTENT='{
  "permission": {
    "bash": {
      "rm *": "deny",
      "git push *": "deny",
      "*": "allow"
    },
    "edit": "allow",
    "read": "allow"
  }
}'

REPO="aazanabili/wisperlive"
issues=$(gh issue list --repo "$REPO" --json url --jq '.[].url')

for issue in $issues; do
  echo "Analyzing: $issue"

  class=$(opencode run \
    --model "$TARGET_MODEL" \
    --agent "$AGENT" \
    --auto \
    "Classify $issue as a BUG, FEAT, or POLISH. One word only!")
  class=$(echo "$class" | tr -d '[:space:]')

  if [[ "$class" =~ "BUG" ]]; then
    opencode run \
      --model "$TARGET_MODEL" \
      --agent "$AGENT" \
      --auto \
      "Fix this issue: $issue. Create a new git branch."
  fi
done


4. Alternative: Defining Dedicated Custom Agents
Instead of passing inline JSON in scripts, you can create a permanent specialized agent with isolated model settings and tool boundaries:
opencode agent create \
  --path .opencode/agent \
  --description "Autonomous bug-fixing agent with restricted bash access" \
  --model "anthropic/claude-sonnet-4-5" \
  --permissions "bash,read,edit,grep,glob"


Once defined, your script only needs to pass the agent name:
opencode run --agent "bug-fixer" --auto "Fix this issue: $issue"



User prompt: Generally speaking, the providers I use the most in OpenCode are OpenAI in first place, OpenCode Go in second, OpenRouter in third, Ollama Cloud in fourth, and Anthropic in fifth.
Response: Got it. That hierarchy makes standardizing your automation templates straightforward.
Here is how your top providers map directly to OpenCode model strings and configuration:

Priority
Provider
Typical Model Identifier Syntax
Common Production Model Examples
1
OpenAI
openai/<model-name>
openai/gpt-4o, openai/o1-mini
2
OpenCode Go
opencode-go/<model-name> (or configured alias)
Default optimized agent models
3
OpenRouter
openrouter/<vendor>/<model-name>
openrouter/meta-llama/llama-3.3-70b-instruct, openrouter/deepseek/deepseek-chat
4
Ollama Cloud
ollama/<model-name> (or custom base URL provider)
ollama/qwen2.5-coder:32b, ollama/deepseek-r1
5
Anthropic
anthropic/<model-name>
anthropic/claude-3-7-sonnet, anthropic/claude-3-5-haiku

Making Provider Selection Modular in Scripts
To make your .ps1 or .sh script generation flexible, you can expose this hierarchy via an environment variable or parameter switch with OpenAI as the default fallback:
PowerShell (.ps1) Template Variable:
param (
    [ValidateSet("openai", "opencode-go", "openrouter", "ollama", "anthropic")]
    [string]$Provider = "openai",
    [string]$Model = "gpt-4o"
)

$TARGET_MODEL = "$Provider/$Model"
Write-Host "Executing task with $TARGET_MODEL" -ForegroundColor Cyan


Bash (.sh) Template Variable:
PROVIDER="${PROVIDER:-openai}"
MODEL="${MODEL:-gpt-4o}"
TARGET_MODEL="${PROVIDER}/${MODEL}"

echo "Executing task with ${TARGET_MODEL}"


This ensures any new automation script we scaffold defaults to your primary OpenAI setup while remaining a one-variable change away from routing to OpenCode Go, OpenRouter, Ollama, or Anthropic.

User prompt: PS H:\projects\wisperlive> .\auto_fix.ps1 Processing issue: https://github.com/aazanabili/wisperlive/issues/1 > build · gpt-5.6-sol $ gh issue view 1 --repo aazanabili/wisperlive --json title,body,labels {"body":" When the active window is the terminal, the shortcut does not work; however, when I focus away from it, the shortcut works. What is the problem, and how do I fix it?\n Because I sometimes use OpenCode CLI or Codex CLI, the shortcut to record audio unfortunately doesn't work when the active window is the terminal. This is happening on Windows.","labels":[],"title":"The shortcut does not work when the active window is the terminal."} Class: BUG Fixing BUG... > build · gpt-5.6-sol I’ll inspect the issue and repository state first, then create an isolated branch and carry the fix through tests. ✗ WebFetch https://github.com/aazanabili/wisperlive/issues/1 failed Error: StatusCode: non 2xx status code (404 GET https://github.com/aazanabili/wisperlive/issues/1) $ git status --short --branch ## main...origin/main ?? auto_fix.ps1 $ gh issue view 1 --repo aazanabili/wisperlive --json number,title,body,labels,state,url {"body":" When the active window is the terminal, the shortcut does not work; however, when I focus away from it, the shortcut works. What is the problem, and how do I fix it?\n Because I sometimes use OpenCode CLI or Codex CLI, the shortcut to record audio unfortunately doesn't work when the active window is the terminal. This is happening on Windows.","labels":[],"number":1,"state":"OPEN","title":"The shortcut does not work when the active window is the terminal.","url":"https://github.com/aazanabili/wisperlive/issues/1"} ✱ Glob "*" in . · 100 matches ⚙ graphiti {"mode":"search","scope":"project","query":"wisperlive issue 1 architecture known problems"} Issue #1 is Windows-specific: the global recording shortcut is intercepted while a terminal has focus. The worktree is otherwise clean except for an existing untracked `auto_fix.ps1`, which I’ll leave untouched; I’m creating the fix branch now and tracing the shortcut implementation. → Skill "graphify" → Read requirements.txt → Read main.py ✱ Glob "graphify-out/graph.json" in . · 0 matches → Read README.md ✱ Grep "hotkey|shortcut|keyboard|Key\.|Listener|pynput|RegisterHotKey" in . · 64 matches $ git switch -c fix/issue-1-terminal-shortcut Switched to a new branch 'fix/issue-1-terminal-shortcut' → Read config_manager.py → Read main.spec → Read WhisperLive.spec ✱ Glob "**/test*.py" in . · 0 matches $ git log --oneline -10 5421f17 reaboute bb89f17 delete update button a42c249 prosses coloer 3d2120a change update method e434884 i hope laast fix 418b59c smoll icon and test update 0b173b1 bug 2 and update abca75b bug update and icon a6f4f80 update 3 3304b56 icon and update $ gh issue view 1 --repo aazanabili/wisperlive --comments (no output) The current implementation uses `keyboard`’s low-level hook. That hook is sensitive to Windows integrity boundaries and terminal handling, so a normal WhisperLive process can miss shortcuts while an elevated or specially handled terminal is active. I’ll replace recording shortcut registration with the native Windows `RegisterHotKey` API, retain both toggle and hold modes, and add focused parser/lifecycle tests. # Todos [•] Implement native Windows global hotkey registration [ ] Integrate native hotkey lifecycle with toggle and hold recording modes [ ] Add tests and document terminal shortcut behavior [ ] Run tests and inspect final branch diff I’m adding a small Windows-native hotkey adapter and changing only the recording shortcut path. Text pasting will continue using the existing `keyboard` dependency, while shortcut activation will no longer depend on its low-level hook. % Patch 4 files # Todos [✓] Implement native Windows global hotkey registration [•] Integrate native hotkey lifecycle with toggle and hold recording modes [ ] Add tests and document terminal shortcut behavior [ ] Run tests and inspect final branch diff $ git diff -- main.py windows_hotkey.py test_windows_hotkey.py README.md warning: in the working copy of 'README.md', LF will be replaced by CRLF the next time Git touches it warning: in the working copy of 'main.py', LF will be replaced by CRLF the next time Git touches it diff --git a/README.md b/README.md index ea02246..30a020f 100644 --- a/README.md +++ b/README.md @@ -11,6 +11,7 @@  - **تكامل مع شريط النظام:** يمكن تصغير التطبيق بجانب الساعة، مع خيارات البدء مصغراً والتشغيل التلقائي عند تسجيل الدخول إلى ويندوز.  - **تحديث مدمج:** زر **Update** يفحص GitHub ويثبت آخر إصدار تلقائياً.  - **اختصار قابل للتسجيل:** انقر حقل الاختصار أو زر **Record** ثم اضغط المفاتيح المطلوبة. +- **دعم الطرفية على ويندوز:** يعتمد اختصار التسجيل على واجهة Windows الأصلية ليعمل حتى عندما تكون نافذة Terminal أو أدوات CLI في المقدمة.  --- diff --git a/main.py b/main.py index aa6732f..df053c2 100644 --- a/main.py +++ b/main.py @@ -8,7 +8,6 @@ from tkinter import ttk  import webbrowser  import winreg -import keyboard  import pystray  import winsound  from PIL import Image, ImageTk @@ -19,6 +18,7 @@ from config_manager import load_config, save_config  from gemini_api import process_audio  from updater import RELEASES_PAGE  from version import APP_VERSION +from windows_hotkey import WindowsGlobalHotkey  THEMES = { @@ -70,7 +70,8 @@ class WhisperLiveApp:          self.recorder = AudioRecorder()          self.is_processing = False          self.is_exiting = False -        self.hotkey_handles = [] +        self.hotkey = None +        self.hold_poll_after_id = None          self.indicator_after_id = None          self.indicator_phase = 0          self.indicator_state = None @@ -406,32 +407,34 @@ class WhisperLiveApp:          shortcut = self.config.get("shortcut", "ctrl+space")          try:              if self.config.get("mode") == "toggle": -                handle = keyboard.add_hotkey(shortcut, lambda: self.root.after(0, self.toggle_recording), suppress=True) -                self.hotkey_handles.append(("hotkey", handle)) +                callback = lambda: self.root.after(0, self.toggle_recording)              else: -                main_key = shortcut.split("+")[-1].strip() -                press_handle = keyboard.on_press_key(main_key, self.on_key_press, suppress=False) -                release_handle = keyboard.on_release_key(main_key, self.on_key_release, suppress=False) -                self.hotkey_handles.extend([("hook", press_handle), ("hook", release_handle)]) +                callback = lambda: self.root.after(0, self.start_hold_recording) +            self.hotkey = WindowsGlobalHotkey(shortcut, callback) +            self.hotkey.start()          except Exception as error: +            self.hotkey = None              self.set_status(f"Shortcut error: {error}", "error")      def clear_hotkeys(self): -        for kind, handle in self.hotkey_handles: -            if kind == "hotkey": -                keyboard.remove_hotkey(handle) -            else: -                keyboard.unhook(handle) -        self.hotkey_handles.clear() - -    def on_key_press(self, _event): -        parts = [part.strip().lower() for part in self.config.get("shortcut", "").split("+")] -        modifiers = [part for part in parts if part in ["ctrl", "shift", "alt", "windows"]] -        if all(keyboard.is_pressed(modifier) for modifier in modifiers): -            self.root.after(0, self.start_recording) +        if self.hold_poll_after_id: +            self.root.after_cancel(self.hold_poll_after_id) +            self.hold_poll_after_id = None +        if self.hotkey: +            self.hotkey.stop() +            self.hotkey = None Is what he is doing right, or will it ruin the bread? Or are there mistakes?
Response: The direction the agent is taking is technically correct and the standard solution for this exact problem on Windows, but there are a few specific pitfalls you need to keep an eye on before merging.
Why the agent's diagnosis is correct
The original code used Python’s keyboard library, which relies on a low-level Windows hook (WH_KEYBOARD_LL). This hook fails in terminal windows for two main reasons:
UIPI (User Interface Privilege Isolation): If Windows Terminal, PowerShell, or your CLI runs with elevated permissions (Admin) while WhisperLive runs as a standard user, Windows silently drops WH_KEYBOARD_LL events to prevent keystroke injection attacks.
Console Raw Input: Modern terminal emulators (like Windows Terminal) grab raw console input, which often swallows or interferes with standard user-space hooks.
Switching to the native Windows Win32 RegisterHotKey API is the right move: it registers the shortcut directly with the Windows kernel (win32k.sys), which intercepts the key globally before any focused window (including terminals) can suppress it.
Potential risks to watch out for ("What could ruin the bread")
While the strategy is solid, check these three areas in the agent's generated code:
The "Hold to Record" implementation: RegisterHotKey only fires on key press (sending WM_HOTKEY); it does not fire an event when a key is released.
The agent added self.hold_poll_after_id, which suggests it is polling key release using GetAsyncKeyState inside a Tkinter after loop.
Verify in windows_hotkey.py and main.py that the poll loop actually stops the recording reliably when you release the key, and doesn't get stuck in an infinite loop.
Message Pump / Threading: RegisterHotKey requires an active Win32 message loop (GetMessage / PeekMessage) tied to an HWND or a dedicated background thread. Ensure WindowsGlobalHotkey doesn't block Tkinter's main event loop.
Simulated Typing / Pasting into the Terminal: Once the audio is transcribed, WhisperLive likely pastes the text into the terminal using keyboard.write() or pyautogui.
If your terminal is running as Administrator, Windows UIPI will block WhisperLive from typing into that terminal unless WhisperLive itself is also launched as Administrator. This is a Windows OS security boundary, not an OpenCode bug.
How to verify the fix
Once OpenCode finishes creating the PR:
Checkout the branch:
git checkout fix/issue-1-terminal-shortcut


Run the application:
python main.py


Test both Toggle and Hold recording modes while an elevated PowerShell or Windows Terminal window is active and focused.

User prompt: ---------------------------------------------------------------------- Ran 8 tests in 0.000s OK $ & ".\venv\Scripts\python.exe" -c "import ctypes, threading, time; from windows_hotkey import WindowsGlobalHotkey; fired=threading.Event(); hotkey=WindowsGlobalHotkey('ctrl+shift+f12', fired.set); hotkey.start(); u=ctypes.windll.user32; u.keybd_event(0x11,0,0,0); u.keybd_event(0x10,0,0,0); u.keybd_event(0x7B,0,0,0); u.keybd_event(0x7B,0,2,0); u.keybd_event(0x10,0,2,0); u.keybd_event(0x11,0,2,0); ok=fired.wait(2); hotkey.stop(); print('callback_received=' + str(ok)); raise SystemExit(0 if ok else 1)" callback_received=True Re-evaluation result: IΓÇÖll inspect the issue requirements and compare them against the current repository implementation and tests. The fix replaces the low-level `keyboard` hook with WindowsΓÇÖ native `RegisterHotKey`, which is the relevant mechanism for receiving the shortcut while Windows Terminal or CLI tools have focus. IΓÇÖm validating registration behavior and regression tests now. PASS Re-attempting fix... > build · gpt-5.6-sol I’ll verify issue #1 against the current implementation, identify why the existing hotkey path still fails under terminal focus, then patch and run the relevant tests. # Todos [•] Inspect issue #1 and current hotkey implementation/tests [ ] Implement Windows RegisterHotKey-based fix and regression coverage [ ] Run targeted and full verification ✱ Grep "keyboard|hotkey|RegisterHotKey|GlobalHotKey|pynput" in . · 28 matches ✱ Glob "**/*" in . · 100 matches ✗ WebFetch https://github.com/aazanabili/wisperlive/issues/1 failed Error: StatusCode: non 2xx status code (404 GET https://github.com/aazanabili/wisperlive/issues/1) → Skill "graphify" Please reply to me in Arabic regarding what was said previously; I didn't understand anything.
Response: ما حدث هنا باختصار هو حلقة تكرار خاطئة بسبب صياغة سكربت الباورشيل (auto_fix.ps1)، وليس بسبب فشل كود الإصلاح نفسه.
إليك تفصيل ما جرى وكيف تحل المشكلة:
1. ما الذي حدث فعلياً في الطرفية؟
الكود نجح واجتاز الفحص بالكامل:
النموذج قام بكتابة ملف windows_hotkey.py وشغّل 8 اختبارات وانتهت بنجاح تام (OK). بعدها أجرى اختبار محاكاة حي بالضغط على المفاتيح وتلقى الإشارة بنجاح (callback_received=True).
النموذج قال بالفعل إن المشكلة حُلّت (PASS):
في نهاية تقييمه كتب النموذج الجملة التالية:"... I’m validating registration behavior and regression tests now. PASS"
لماذا استمر السكربت وبدأ يحاول من جديد (Re-attempting fix...)؟
السبب يكمن في شرط حلقة التكرار في سكربت الباورشيل:
while ($result -notmatch "PASS")

عندما قام الباورشيل بفحص مخرجات رد الذكاء الاصطناعي ($result)، لم يطابق كلمة PASS بدقة (إما لوجود نصوص مشوهة مثل ΓÇÖ الناتجة عن ترميز UTF-8 في ويندوز، أو لأن الرد كان طويلاً جداً ويحتوي على أسطر متعددة لم يقرأها الشرط كسلسلة واحدة). ونتيجة لذلك، اعتقد السكربت أن الفحص فشل وأرسل أمراً جديداً للذكاء الاصطناعي: "الحل لم ينجح، حاول مجدداً"، مما جعله يعيد العمل من الصفر!
2. ما الذي يجب عليك فعله الآن؟
أولاً: أوقف السكربت حالاً
اضغط على مفاتيح Ctrl + C داخل نافذة الـ PowerShell لإيقاف حلقة التكرار التلقائية حتى لا يقوم بإعادة كتابة الكود وتخريبه.
ثانياً: افحص ما إذا كان الكود يعمل لديك
الكود الذي أنشأه الذكاء الاصطناعي ممتاز جداً وموجود على فرع جديد اسمه: fix/issue-1-terminal-shortcut
يمكنك تجربته بنفسك عبر الخطوات التالية في الطرفية:
تأكد أنك على الفرع الجديد:
git checkout fix/issue-1-terminal-shortcut


شغّل التطبيق:
python main.py


افتح الطرفية (Terminal أو PowerShell)، وضع المؤشر داخلها لتكون هي النافذة النشطة، وجرّب الضغط على اختصار التسجيل. ستلاحظ أنه يعمل الآن حتى والطرفية في المقدمة.
3. كيف نمنع تكرار هذه المشكلة في سكربت الباورشيل؟
المشكلة كانت أننا طلبنا من النموذج شرحاً طويلاً بجانب كلمة PASS. لضبط السكربت مستقبلاً، يجب تعديل سطر التحقق ليكون صارماً جداً ولا يسمح للنموذج إلا بطباعة كلمة واحدة، وضبط فحص الـ Regex ليتجاهل أي نصوص إضافية:
# في سكربت auto_fix.ps1:
$result = (opencode run "Verify if the solution addresses this issue: $issue. If addressed, output ONLY the single word PASS. Do not explain.").Trim()

# الفحص المرن للكلمة
while ($result -notmatch "(?i)\bPASS\b") {
    # ...
}



User prompt: Please fix the entire script I wrote so that I won't encounter these issues in the future.
Response: إليك النسخة المصححة والمحسّنة بالكامل من السكربت. تم حل المشاكل الجذرية التي تسببت في حلقة التكرار الخاطئة:
ضبط ترميز المخرجات (UTF-8): لمنع تشويه النصوص والرموز (مثل ΓÇÖ) التي تتسبب في فشل المقارنة داخل PowerShell.
دمج المصفوفات النصية: مخرجات الأوامر في PowerShell تعود أحياناً كـ Array من الأسطر، وتم دمجها بسلسلة نصية واحدة (-join "n"`).
فحص Regex دقيق ومرن ((?i)\bPASS\b): يكتشف كلمة PASS ككلمة مستقلة بغض النظر عن حالة الأحرف أو وجود نصوص تبريرية قبلها.
إضافة حد أقصى للمحاولات (Safety Breaker): لمنع السكربت من الدخول في حلقة لا نهائية (Infinite Loop) تستهلك رصيدك وتخرب الكود، حيث يتوقف بعد 3 محاولات تلقائياً إذا لم يُحل الإشكال.
# تفعيل ترميز UTF-8 لمنع تشويه الحروف والرموز في مخرجات الطرفية
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'

$repo = "aazanabili/wisperlive"
$rawIssues = gh issue list --repo $repo --json url | ConvertFrom-Json
$issues = $rawIssues.url

if (-not $issues) {
    Write-Host "No open issues found in $repo." -ForegroundColor Yellow
    exit 0
}

foreach ($issue in $issues) {
    Write-Host "`n========================================" -ForegroundColor Gray
    Write-Host "Processing issue: $issue" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Gray

    # 1. تصنيف المشكلة عبر OpenCode
    $classRaw = opencode run "Classify $issue as a BUG, FEAT, or POLISH. One word only!"
    $class = ($classRaw -join "`n").Trim()
    Write-Host "Class: $class" -ForegroundColor Yellow

    # 2. التحقق إذا كانت المشكلة خطأ برمجي (BUG)
    if ($class -match "(?i)\bBUG\b") {
        Write-Host "Fixing BUG..." -ForegroundColor Green
        opencode run "Fix this issue: $issue. Create a new git branch."

        # 3. فحص الحل الأول
        $resultRaw = opencode run "Verify if the solution addresses this issue: $issue. If addressed, reply with the single word PASS. Otherwise explain the blocker."
        $result = ($resultRaw -join "`n").Trim()
        Write-Host "Result is:`n$result" -ForegroundColor Yellow

        # 4. حلقة التكرار مع صمام أمان (3 محاولات كحد أقصى)
        $maxAttempts = 3
        $attempt = 1

        while (($result -notmatch "(?i)\bPASS\b") -and ($attempt -le $maxAttempts)) {
            Write-Host "`n[Attempt $attempt/$maxAttempts] Re-attempting fix..." -ForegroundColor Magenta
            
            opencode run "Your implementation does not address this issue: $issue. The blockers: $result. Fix it now."
            
            $resultRaw = opencode run "Verify if the solution addresses this issue: $issue. If addressed, reply with the single word PASS."
            $result = ($resultRaw -join "`n").Trim()
            
            Write-Host "Re-evaluation result:`n$result" -ForegroundColor Yellow
            $attempt++
        }

        # 5. إذا اجتاز الفحص، يتم رفع التعديلات وفتح PR
        if ($result -match "(?i)\bPASS\b") {
            Write-Host "`nFix verified successfully! Opening PR..." -ForegroundColor Green
            opencode run "Open a PR from the current branch. Checkout to main."
            Write-Host "Pull Request opened successfully!" -ForegroundColor Green
        } else {
            Write-Host "`nFailed to verify fix after $maxAttempts attempts. Skipping PR creation to preserve repo integrity." -ForegroundColor Red
        }
    } else {
        Write-Host "Issue is not classified as a BUG. Skipping automated fix." -ForegroundColor Gray
    }
}



User prompt: Please rewrite a proper recommendation for a skill that performs this task: the skill of writing .sh or .ps1 files according to the roadmap/instructions I provide or need.
Response: Skill Specification: Script & Agent Loop Architect (script-orchestrator)
Skill Name: script-orchestrator
Target Environments: Windows (PowerShell 7+ / .ps1) and POSIX systems (Linux/macOS Bash / .sh)
Core Purpose: Generates production-ready, fault-tolerant .ps1 and .sh scripts to automate multi-step agentic workflows, loops, and CLI pipelines (such as opencode, gh, Git, Docker) based on natural language instructions.
1. Skill Description & Intent
When activated, this skill analyzes user-supplied project requirements, loop logic, or tool combinations, and synthesizes an executable, robust script. It eliminates common agent-loop pitfalls such as infinite retry loops, multi-line string truncation, silent parsing failures, and console encoding corruption.
2. Mandatory Architectural Guardrails
Every generated script must adhere to these defensive patterns:
Console Encoding Protection:
PowerShell: Force UTF-8 explicitly ([Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8) to stop corrupted characters (e.g., curly quotes, non-ASCII symbols) from breaking string comparisons.
Bash: Ensure clean parsing without subshell word-splitting issues.
Array-Safe CLI Output Handling:
In PowerShell, external CLI commands return arrays of strings if output has multiple lines. Scripts must join them (($raw -join "n").Trim()`) before evaluating conditionals.
Robust Regex Matching:
Never use strict equality (== or -eq) on LLM output.
Use case-insensitive word boundary checks: (?i)\bPASS\b in PowerShell, or =~ "(?i)\bPASS\b" in Bash.
Bounded Retries (Circuit Breakers):
while loops evaluating LLM or agent output must always include an explicit attempt counter ($maxAttempts = 3) to prevent runaway loops and API credit exhaustion.
Modular Provider / Model Flags:
OpenCode calls must cleanly isolate the model identifier (<provider>/<model>), permissions (--auto), and agent definitions without breaking shell quotation rules.
3. Skill System Prompt (Drop-in Definition)
Use this definition directly in your agent's custom instructions or skill configuration:
You are an expert systems automation engineer specialized in authoring production-grade `.sh` and `.ps1` automation scripts.

### Role & Responsibilities:
- Translate high-level user roadmaps into deterministic, executable scripts (.ps1 for Windows, .sh for Linux/macOS).
- Integrate non-interactive CLI calls (such as `opencode run`, `gh`, `git`) safely into multi-step pipelines and validation loops.

### Rules for Script Generation:
1. Encoding & Error Traps:
   - For PowerShell: Always set UTF-8 encoding for both [Console]::OutputEncoding and $OutputEncoding. Default to `$ErrorActionPreference = 'Stop'`.
   - For Bash: Always begin with `#!/usr/bin/env bash` and `set -euo pipefail`.

2. Dynamic Output Parsing:
   - Always flatten multi-line command output before evaluating conditions:
     * PowerShell: `$val = ($rawOutput -join "`n").Trim()`
     * Bash: `val=$(echo "$rawOutput" | tr -d '\r')`
   - Use boundary-safe regex matching rather than literal string equality when evaluating model responses (e.g., `(?i)\bPASS\b`).

3. Infinite Loop Prevention:
   - Never generate an unbounded `while` loop around an AI agent. Always enforce a `$maxAttempts` or `MAX_RETRIES` counter (default to 3) with an explicit failure branch.

4. OpenCode Invocation Standard:
   - Parameterize the model string using the `<provider>/<model>` convention (defaulting to the user's primary stack, such as OpenAI, OpenCode Go, or OpenRouter).
   - Use `--auto` to allow unattended executions while maintaining security boundaries.

5. Delivery:
   - Provide the complete, working code in a single code block without placeholders.
   - Conclude with exact instructions for executing the script in the target shell.


4. Standard Operational Template
[User Input]
  │
  ▼
1. Target Platform Detection (.ps1 vs .sh)
2. Tool & Flag Resolution (gh / opencode / git parameters)
3. Safety Scaffolding Injection (UTF-8, ErrorAction, Circuit Breaker)
4. Loop Construction (Join multi-line arrays -> Regex evaluation)
5. Success / Failure Terminal Branches
  │
  ▼
[Runnable File Output]



User prompt: Why is it that when it automatically created a new branch and resolved the issue... On the GitHub website, it notified me of a new pull request. I reviewed it, and a new branch had been created. Normally, I have a GitHub Actions workflow on the `main` branch that generates the program's `.exe` file. However, when I went to the newly created branch and made a new release, the Action didn't run and didn't create the `.exe` file for me. I'm not sure why this happened. What should I do? Answer me in Arabic.
Response: هذا السلوك طبيعي جداً ومتوقع في GitHub Actions، والسبب يعود إلى طريقة كتابة شروط تشغيل الـ Workflow (الـ Triggers) داخل ملف الإعدادات الخاص بالأكشن.
لماذا لم يعمل الـ Action على الفرع الجديد؟
حصر الـ Workflow بالفرع الرئيسي (main): في أغلب ملفات GitHub Actions، يتم تحديد التشغيل ليكون مقصوراً على الفرع الرئيسي فقط، كالتالي:
on:
  push:
    branches: [ "main" ]

عندما تقوم بإنشاء فرع جديد (مثل fix/issue-1-...) أو محاولة بناء شيء عليه، يتجاهل GitHub تشغيل الأكشن لأن اسم الفرع ليس main.
أمان الأحداث الصادرة عن Pull Requests: إذا كان السكربت أو الـ PR تم إنشاؤه عبر أدوات أتمتة خارجية، فإن أحداث الـ Release عادةً ما يتم ربطها إما بـ Git Tags معينة (مثل v*.*.*) أو بدمج الكود رسمياً في فرع الإنتاج main.
صلاحيات الـ GitHub Token: إذا تم إنشاء الـ PR أو الـ Release عبر مفتاح افتراضي مثل GITHUB_TOKEN لأداة أتمتة، فإن GitHub يمنع تشغيل Workflows أخرى بشكل متسلسل تلقائياً كإجراء أمني لمنع الحلقات اللانهائية (Infinite recursive runs).
ما الذي يجب عليك فعله الآن؟
الحل الأفضل والأسرع (المسار الطبيعي للعمل):
ادخل إلى الـ Pull Request على موقع GitHub وافحص التعديلات.
اضغط على Merge pull request لدمج التعديلات من الفرع الجديد إلى فرع main.
احذف الفرع المؤقت.
أنشئ الـ Release الجديد انطلاقاً من فرع main المحدّث؛ وسيعمل الأكشن مباشرة ويقوم ببناء وتوليد ملف الـ .exe.
كيف تجعل الـ Workflow يعمل يدوياً أو على أي فرع مستقبلاً؟
إذا كنت تريد إمكانية تشغيل بناء ملف الـ .exe وتجربته على أي فرع جديد قبل دمجه في main، افتح ملف الـ Workflow في مشروعك (الموجود عادة في .github/workflows/build.yml أو اسم مشابه) وأضف workflow_dispatch:
on:
  push:
    branches: [ "main" ]
  release:
    types: [ published ]
  workflow_dispatch: # يتيح لك تشغيل الأكشن يدوياً بزر Run workflow واختيار أي فرع تريده


بعد إضافة هذا السطر ورفعه:
اذهب إلى تبويب Actions في صفحة المستودع على GitHub.
اختر الـ Workflow الخاص ببناء البرنامج من القائمة الجانبية.
ستجد زراً باسم Run workflow، يمكنك من خلاله تحديد اسم الفرع الجديد وتشغيل بناء ملف الـ .exe عليه مباشرة بنقرة واحدة.

User prompt: name: Build and Release EXE on:   push:     tags:       - 'v*' # Push events to matching v*, i.e. v1.0, v20.15.10   workflow_dispatch: # Allows manual trigger from GitHub UI permissions:   contents: write jobs:   build-windows:     runs-on: windows-latest     steps:     - name: Checkout repository       uses: actions/checkout@v4     - name: Set up Python       uses: actions/setup-python@v5       with:         python-version: '3.11' # Good stable version for pyinstaller     - name: Install dependencies       run: |         python -m pip install --upgrade pip         pip install google-generativeai keyboard sounddevice soundfile pyperclip pystray Pillow pyinstaller     - name: Stamp release version       if: startsWith(github.ref, 'refs/tags/v')       run: |         "APP_VERSION = '${{ github.ref_name }}'" | Set-Content version.py     - name: Build EXE with PyInstaller       run: |         pyinstaller -y WhisperLive.spec       	   - name: Rename Executable       run: |         if (Test-Path "dist\WhisperLive.exe") {           Write-Host "WhisperLive.exe already named correctly"         } elseif (Test-Path "dist\main.exe") {           Rename-Item -Path "dist\main.exe" -NewName "WhisperLive.exe"         }     - name: Upload Artifact (For Manual Triggers)       if: github.event_name == 'workflow_dispatch'       uses: actions/upload-artifact@v4       with:         name: WhisperLive-Windows         path: dist/WhisperLive.exe     - name: Create Release and Upload Asset       if: startsWith(github.ref, 'refs/tags/v')       uses: softprops/action-gh-release@v2       with:         files: dist/WhisperLive.exe       env:         GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} This is the YAML file I have. Where should I add the new branch? Do I need to write the exact name of the new branch, or does it automatically pick up any new branch in general?
Response: السبب في أن الملف لم يعمل لديك هو أن المشغل المبرمج حالياً لا يعمل إلا عند دفع وسم إصدار جديد (مثل git tag v1.0.0) يبدأ بحرف v*:
on:
  push:
    tags:
      - 'v*'


أين وكيف تضيف الفروع؟
أضف قسم branches تحت قسم push مباشرة في أعلى الملف. يمكنك جعله يعمل على أي فرع يتم إنشاؤه أو الدفع إليه تلقائياً باستخدام النجمة ** دون الحاجة لكتابة اسم فرع محدد:
name: Build and Release EXE

on:
  push:
    tags:
      - 'v*' # يعمل تلقائياً عند إنشاء Release أو Tag مثل v1.0
    branches:
      - '**' # يلتقط تلقائياً أي فرع جديد يتم إنشاؤه أو الدفع إليه (مثل main أو fix/...)
  pull_request: # (اختياري ومفيد) لفحص وبناء الـ EXE تلقائياً بمجرد فتح PR
    branches:
      - '**'
  workflow_dispatch: # يتيح التشغيل اليدوي من الموقع


تعديل خطوة رفع الملف التجريبي (Artifact)
خطوة حفظ وتنزيل الـ .exe في ملفك الحالي مشروطة بأن يكون التشغيل يدوياً فقط (github.event_name == 'workflow_dispatch'). لكي تتمكن من تنزيل ملف الـ .exe الناتج عن الفروع التجريبية دون إنشاء Release رسمي يختلط بالإصدارات النهائية، غيّر شرط الخطوة ليصبح كالتالي:
    - name: Upload Artifact (For Branches and Manual Triggers)
      if: "!startsWith(github.ref, 'refs/tags/v')"
      uses: actions/upload-artifact@v4
      with:
        name: WhisperLive-Windows-${{ github.ref_name }}
        path: dist/WhisperLive.exe


بهذا التعديل:
إذا دفعت إصداراً يحمل v* (مثل v1.2.0)، سينشئ GitHub صفحة Release رسمية ويرفق بداخلها ملف الـ WhisperLive.exe.
إذا تم إنشاء أي فرع تجريبي أو إصلاح مشكلة (مثل الفرع الآلي)، سيبدأ الأكشن في البناء فوراً، وستجد ملف الـ WhisperLive.exe جاهزاً للتنزيل داخل صفحة الأكشن تحت قسم Artifacts للتجربة قبل دمج الكود.

User prompt: Write a skill for me so that any model, such as Codex for example, can manage OpenCode through it, using the capabilities I previously mentioned to you.Make the text copyable so that I can copy and paste it immediately.First, before you start writing, please provide an explanation in Arabic of this skill's function and how to use it.
Response: شرح المهارة ووظيفتها وطريقة استخدامها
ما هي هذه المهارة؟ هذه المهارة تُعرّف نموذج الذكاء الاصطناعي (سواء كان Codex، أو Claude، أو GPT، أو غيرها) بدور "مهندس أتمتة سكربتات وأنظمة". وظيفتها الأساسية هي إدارة واستدعاء أداة OpenCode CLI من خلال بناء سكربتات تنفيذية احترافية (.ps1 لويندوز أو .sh للينكس) دون الوقوع في الأخطاء الشائعة مثل الحلقات اللانهائية، أو مشاكل ترميز الحروف، أو أخطاء قراءة المخرجات متعددة الأسطر.
الميزات الأساسية للمهارة:
إدارة المزودات والنماذج: تتيح تحديد المزودات بحسب أولوياتك (openai بالمرتبة الأولى، ثم opencode-go، ثم openrouter، ثم ollama، ثم anthropic).
إدارة الصلاحيات والأمان: تفعيل وضع التشغيل الآلي غير التفاعلي (--auto)، مع إمكانية حقن قيود وصلاحيات JSON محددة لحماية الملفات ومنع الأوامر التخريبية (مثل rm * أو الدفع الإجباري).
صمامات أمان للحلقات البرمجية: منع التكرار اللانهائي عبر إضافة عداد أقصى للمحاولات (Circuit Breaker)، والاعتماد على تعابير المطابقة القياسية (Regex مثل (?i)\bPASS\b) لفحص النتائج بمرونة وموثوقية.
دعم البيئة المزدوجة: توليد سكربتات مخصصة لبيئة Windows PowerShell 7+ مع معالجة مشاكل الترميز (UTF-8)، أو سكربتات POSIX Bash المتوافقة مع Linux/macOS.
طريقة الاستخدام:
انسخ نص المهارة المكتوب باللغة الإنجليزية في المربع البرمجي أدناه بالكامل.
الصقه في إعدادات التعليمات المخصصة للنموذج (System Instructions / Custom Instructions / Rules) في الأداة التي تستخدمها (مثل Codex أو ChatGPT أو غيرهما).
عندما تطلب منه كتابة أي سكربت للتعامل مع مستودع أو معالجة مشاكل عبر OpenCode، سيقوم النموذج تلقائياً بإنشاء السكربت وفقاً لهذه المعايير الصارمة والصحيحة مع تضمين خيارات النموذج والمزود.
# Skill: OpenCode CLI Workflow & Script Architect (`opencode-orchestrator`)

## Description
Expert system automation capability designed to author production-grade, fault-tolerant Windows PowerShell (`.ps1`) and POSIX Bash (`.sh`) automation scripts that control the OpenCode CLI (`opencode`). It safely integrates model selection, provider routing, headless execution, permission boundaries, and bounded loop verification.

---

## Capabilities & Guardrails

### 1. Provider & Model Routing Hierarchy
When parameterizing or configuring OpenCode executions, map target models using the `<provider>/<model>` syntax following this default priority list:
1. **OpenAI** (Primary default): `openai/gpt-4o`, `openai/o1-mini`
2. **OpenCode Go**: `opencode-go/<model-id>`
3. **OpenRouter**: `openrouter/<vendor>/<model-name>`
4. **Ollama Cloud / Local**: `ollama/<model-name>`
5. **Anthropic**: `anthropic/<model-name>`

Always allow the script consumer to override Provider and Model via parameters or environment variables, defaulting to `openai` and `gpt-4o`.

### 2. Execution Flags & Granular Permissions
- **Non-Interactive Mode**: Always use `--auto` for automated or headless CLI runs to allow permitted operations without manual prompts.
- **Agent Selection**: Support passing the `--agent` parameter (e.g., `--agent build` or `--agent plan`).
- **Inline Security Constraints**: When strict guardrails are needed, inject the `OPENCODE_CONFIG_CONTENT` environment variable to deny dangerous commands (e.g., destructive bash commands or direct main pushes) while permitting necessary edit/read tools.

### 3. Defensive Scripting Standards

#### Windows PowerShell (`.ps1`):
- **Console Encoding**: Always explicitly force UTF-8 to prevent string mangling:
  ```powershell
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
  $OutputEncoding = [System.Text.Encoding]::UTF8
  $ErrorActionPreference = 'Stop'


CLI Output Flattening: External CLI commands return arrays of strings if multi-line. Always join and trim before condition checking:
$result = ($rawOutput -join "`n").Trim()


Fuzzy Condition Evaluation: Never check LLM output using strict equality (-eq). Always use word-boundary, case-insensitive regex:
if ($result -match "(?i)\bPASS\b") { ... }


Infinite Loop Circuit Breaker: Any loop evaluating LLM fixes MUST define a maximum attempt limit (default: 3 retries).
POSIX Bash (.sh):
Begin with #!/usr/bin/env bash and set -euo pipefail.
Sanitize line endings and multi-line responses:
result=$(echo "$raw_output" | tr -d '\r')


Use regex matching for model tokens:
if [[ "$result" =~ (?i)\bPASS\b ]]; then ... fi


Impose explicit MAX_ATTEMPTS=3 counters inside verification loops.
Output Template Structure
When tasked with creating an OpenCode management script, provide:
The target script file (.ps1 or .sh) formatted completely with all parameters, error handling, encoding setup, OpenCode calls, and circuit breakers.
The exact commands required to execute the script in the target shell.


User prompt: 1. Provider Base URLs / Endpoints The base URLs and API endpoints configured across supported providers and gateways in OpenCode include: Anthropic: https://api.anthropic.com/v1 OpenCode Zen Service:OpenAI / Grok / Muse Spark Models: https://opencode.ai/zen/v1/responses Claude / Qwen Models: https://opencode.ai/zen/v1/messages Gemini Models: https://opencode.ai/zen/v1/models/{model_id} OpenAI-Compatible Models (DeepSeek, MiniMax, GLM, Kimi, etc.): https://opencode.ai/zen/v1/chat/completions OpenCode Go Subscription Service:OpenAI / Grok / Muse Spark Models: https://opencode.ai/zen/go/v1/responses Claude / MiniMax / Qwen Models: https://opencode.ai/zen/go/v1/messages OpenAI-Compatible Models (GLM, Kimi, LongCat, DeepSeek, MiMo, Hy): https://opencode.ai/zen/go/v1/chat/completions Local Providers:Ollama: http://localhost:11434/v1 LM Studio: http://127.0.0.1:1234/v1 llama.cpp: http://127.0.0.1:8080/v1 Atomic Chat: http://127.0.0.1:1337/v1 Cloud & Custom Gateways:Helicone: https://ai-gateway.helicone.ai Azure Cognitive Services: https://{resource_name}.cognitiveservices.azure.com/ Custom Provider Example: https://api.myprovider.com/v1 2. Supported Model Identifiers for Invocation In OpenCode configurations, models are invoked using the provider_id/model_id string format. Below are the model identifiers organized by provider: A. OpenCode Zen (opencode/) Invoke models under OpenCode Zen using the opencode/<model-id> format: OpenAI Series: opencode/gpt-6-astra, opencode/gpt-5.6-sol, opencode/gpt-5.6-terra, opencode/gpt-5.6-luna, opencode/gpt-5.5, opencode/gpt-5.5-pro, opencode/gpt-5.4, opencode/gpt-5.4-pro, opencode/gpt-5.4-mini, opencode/gpt-5.4-nano, opencode/gpt-5.3-codex, opencode/gpt-5.3-codex-spark, opencode/gpt-5.2, opencode/gpt-5.2-codex, opencode/gpt-5.1, opencode/gpt-5.1-codex, opencode/gpt-5.1-codex-max, opencode/gpt-5.1-codex-mini, opencode/gpt-5, opencode/gpt-5-codex, opencode/gpt-5-nano. Anthropic Series: opencode/claude-fable-5-1, opencode/claude-fable-5, opencode/claude-opus-5, opencode/claude-opus-4-8, opencode/claude-opus-4-7, opencode/claude-opus-4-6, opencode/claude-opus-4-5, opencode/claude-sonnet-5, opencode/claude-sonnet-4-6, opencode/claude-sonnet-4-5, opencode/claude-haiku-4-5. Google Gemini Series: opencode/gemini-3.8-flash, opencode/gemini-3.7-flash, opencode/gemini-3.6-flash, opencode/gemini-3.5-flash, opencode/gemini-3.5-flash-lite, opencode/gemini-3.1-pro, opencode/gemini-3-flash. xAI Grok Series: opencode/grok-4.6, opencode/grok-4.5, opencode/grok-build-0.1. DeepSeek Series: opencode/deepseek-v4-pro, opencode/deepseek-v4-flash, opencode/deepseek-v4-flash-vision-exp. MiniMax Series: opencode/minimax-m3, opencode/minimax-m2.7, opencode/minimax-m2.5. GLM Series: opencode/glm-5.3-flash, opencode/glm-5.3, opencode/glm-5.2, opencode/glm-5.1, opencode/glm-5. Moonshot Kimi Series: opencode/kimi-k3, opencode/kimi-k2.7-code, opencode/kimi-k2.6, opencode/kimi-k2.5. Qwen Series: opencode/qwen3.7-max, opencode/qwen3.7-plus, opencode/qwen3.6-plus, opencode/qwen3.5-plus. Free Tier Models: opencode/big-pickle, opencode/mimo-v2.5-free, opencode/ling-3.0-flash-fin-free, opencode/nemotron-3-ultra-free, opencode/nemotron-3.5-lightning-free, opencode/muse-spark-1.3-contributor-free. B. OpenCode Go (opencode-go/) Invoke models under OpenCode Go using the opencode-go/<model-id> format: Supported IDs: opencode-go/grok-4.6, opencode-go/gpt-5.6-luna, opencode-go/glm-5.3-flash, opencode-go/glm-5.3, opencode-go/glm-5.2, opencode-go/glm-5.1, opencode-go/kimi-k3, opencode-go/kimi-k2.7-code, opencode-go/kimi-k2.6, opencode-go/longcat-2.0, opencode-go/deepseek-v4.1-flash, opencode-go/deepseek-v4-pro, opencode-go/deepseek-v4-flash, opencode-go/deepseek-v4-flash-vision-exp, opencode-go/mimo-v2.5, opencode-go/mimo-v2.5-pro, opencode-go/minimax-m3, opencode-go/minimax-m2.7, opencode-go/minimax-m2.5, opencode-go/muse-spark-1.3-contributor, opencode-go/qwen3.8-max, opencode-go/qwen3.8-flash, opencode-go/qwen3.7-max, opencode-go/qwen3.7-plus, opencode-go/qwen3.6-plus, opencode-go/hy4-preview, opencode-go/hy3. C. Local & Integrations GitLab Duo: gitlab/duo-chat-haiku-4-5, gitlab/duo-chat-sonnet-4-5, gitlab/duo-chat-opus-4-5. Ollama (Local): ollama/llama2. LM Studio (Local): lmstudio/google/gemma-3n-e4b. llama.cpp (Local): llama.cpp/qwen3-coder:a3b. Atomic Chat (Local): atomic-chat/<your-model-id>. Custom Provider: myprovider/my-model-name.
Response: Here is the updated, production-ready skill specification incorporating the exact OpenCode endpoints, gateway services (Zen and Go), and structured model identifiers.
Skill Specification: OpenCode CLI Workflow & Script Architect (opencode-orchestrator)
Description
Expert system automation skill designed to author fault-tolerant Windows PowerShell (.ps1) and POSIX Bash (.sh) automation scripts controlling the OpenCode CLI (opencode). It coordinates gateway/provider base URLs, precise model identifier resolution (provider_id/model_id), headless execution flags, runtime security configurations, and defensive evaluation loops.
1. Provider Endpoints & Model Resolution Standards
Scripts requiring environment configuration, reverse proxy routing, or explicit provider setup must use these exact targets:
Anthropic Direct: [https://api.anthropic.com/v1](https://api.anthropic.com/v1)
OpenCode Zen Service (opencode/):
Responses (OpenAI, Grok, Muse Spark): [https://opencode.ai/zen/v1/responses](https://opencode.ai/zen/v1/responses)
Messages (Claude, Qwen): [https://opencode.ai/zen/v1/messages](https://opencode.ai/zen/v1/messages)
Gemini: [https://opencode.ai/zen/v1/models/](https://opencode.ai/zen/v1/models/){model_id}
OpenAI-Compatible (DeepSeek, MiniMax, GLM, Kimi): [https://opencode.ai/zen/v1/chat/completions](https://opencode.ai/zen/v1/chat/completions)
OpenCode Go Subscription Service (opencode-go/):
Responses (OpenAI, Grok, Muse Spark): [https://opencode.ai/zen/go/v1/responses](https://opencode.ai/zen/go/v1/responses)
Messages (Claude, MiniMax, Qwen): [https://opencode.ai/zen/go/v1/messages](https://opencode.ai/zen/go/v1/messages)
OpenAI-Compatible (GLM, Kimi, LongCat, DeepSeek, MiMo, Hy): [https://opencode.ai/zen/go/v1/chat/completions](https://opencode.ai/zen/go/v1/chat/completions)
Local Runtimes:
Ollama: http://localhost:11434/v1
LM Studio: [http://127.0.0.1:1234/v1](http://127.0.0.1:1234/v1)
llama.cpp: [http://127.0.0.1:8080/v1](http://127.0.0.1:8080/v1)
Atomic Chat: [http://127.0.0.1:1337/v1](http://127.0.0.1:1337/v1)
Model String Reference Catalog
Scripts must pass valid <provider_id>/<model_id> flags to --model:

Category / Service
Example Model Identifiers
OpenCode Zen (opencode/)
opencode/gpt-5.6-sol, opencode/gpt-5.4, opencode/claude-sonnet-4-5, opencode/gemini-3.7-flash, opencode/deepseek-v4-pro, opencode/grok-4.6, opencode/qwen3.7-max
OpenCode Go (opencode-go/)
opencode-go/gpt-5.6-luna, opencode-go/deepseek-v4.1-flash, opencode-go/kimi-k3, opencode-go/qwen3.8-max, opencode-go/minimax-m3, opencode-go/grok-4.6
Local Runtimes
ollama/llama2, lmstudio/google/gemma-3n-e4b, llama.cpp/qwen3-coder:a3b, atomic-chat/<model-id>
GitLab Duo
gitlab/duo-chat-sonnet-4-5, gitlab/duo-chat-haiku-4-5

2. Mandatory Defensive Guardrails
UTF-8 Output Stream: Always enforce UTF-8 in PowerShell scripts via [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 and $OutputEncoding = [System.Text.Encoding]::UTF8 to prevent multi-byte and curly quote mangling (ΓÇÖ).
Multi-Line String Sanitization: Flatten CLI responses before evaluation:
PowerShell: $result = ($rawOutput -join "n").Trim()`
Bash: result=$(echo "$raw_output" | tr -d '\r')
Regex Token Matching: Never use exact equality (-eq or ==) on LLM verification outputs. Use boundary matching:
PowerShell: if ($result -match "(?i)\bPASS\b")
Bash: if [[ "$result" =~ (?i)\bPASS\b ]]
Circuit Breaker Counter: All agentic correction loops (while) must enforce an upper execution limit (default: 3 iterations) to eliminate runaway execution loops.
Non-Interactive Execution: Always pass --auto to allow automated edits and execution while honoring declared security restrictions.
3. System Prompt (Copy-Paste Ready)
You are an expert systems automation engineer specialized in authoring production-grade `.sh` and `.ps1` automation scripts that drive the OpenCode CLI (`opencode`).

### Core Responsibilities:
1. Translate procedural roadmaps into deterministic, executable scripts (.ps1 for Windows PowerShell 7+, .sh for POSIX Bash).
2. Integrate headless OpenCode invocations (`opencode run`) with precise model identifiers, agent flags, and tool permissions.
3. Prevent infinite loops and parsing failures through defensive programming.

### Provider & Model Resolution:
- Model syntax must follow `<provider_id>/<model_id>`.
- Supported gateways include:
  * OpenCode Zen: `opencode/<model-id>` (e.g., `opencode/gpt-5.6-sol`, `opencode/claude-sonnet-4-5`, `opencode/deepseek-v4-pro`)
  * OpenCode Go: `opencode-go/<model-id>` (e.g., `opencode-go/gpt-5.6-luna`, `opencode-go/deepseek-v4.1-flash`, `opencode-go/qwen3.8-max`)
  * Local: `ollama/<model>`, `lmstudio/<model>`, `llama.cpp/<model>`, `atomic-chat/<model>`
- Default model resolution: Parameterize `$Model` / `$TARGET_MODEL` with fallback to `opencode/gpt-5.6-sol` or `openai/gpt-4o`.

### Scripting Standards:
- Windows PowerShell (.ps1):
  * Set UTF-8 encoding immediately:
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
    $ErrorActionPreference = 'Stop'
  * Merge external multi-line output arrays: `$val = ($raw -join "`n").Trim()`
  * Evaluate test/fix results using regex boundary: `(?i)\bPASS\b`
  * Guard all `while` loops with an explicit `$attempt` counter and maximum retry ceiling (default 3).

- POSIX Bash (.sh):
  * Start with `#!/usr/bin/env bash` and `set -euo pipefail`.
  * Strip carriage returns: `val=$(echo "$raw" | tr -d '\r')`
  * Evaluate loop results with regex: `[[ "$val" =~ (?i)\bPASS\b ]]`
  * Impose explicit loop counter ceiling (`MAX_ATTEMPTS=3`).

### Delivery:
Output the complete, self-contained script in a single code block followed by execution commands.



User prompt: Look at this skill called "delegate"—"open code delegate." I am learning how to use OpenCode. Break it down, analyze it, and try to generate a similar, yet more effective skill for me based on what you have learned.
Response: 1. تحليل تفكيكي لمهارة opencode-delegate الحالية
تعتمد مهارة opencode-delegate على نمط هندسي يُدعى "المُوجّه والمنفّذ" (Orchestrator-Implementer Pattern):
جوهر الفكرة: بدلاً من أن يقوم النموذج الرئيسي (مثل Claude Code أو Codex) بكتابة التعديلات البرمجية مباشرة، يتولى هو دور "المُوجّه والمراجع"، بينما يفوّض مهمة التعديل الفعلي والكتابة كلياً إلى OpenCode CLI ليعمل في جلسة مستقلة كـ "منفّذ في الخلفية".
الأداة المساعدة (relay.mjs): محرك وظيفي مبني بـ Node.js يلتف حول أمر opencode run --format json، يلتقط تدفق الأحداث (Events)، يجمع المخرجات في ملف result.json، ويضمن عدم محاولة الحفظ أو الالتزام (git commit).
حدود الاستقلالية (Autonomy): تفصل المهارة بين وضعين:
build: مخصص للتنفيذ والكتابة مع تمرير علم --auto لتجاوز طلب الموافقات في الخلفية.
plan (أو --read-only): للفحص والتشخيص وقراءة الشجرة البرمجية فقط، ويُحظر عنه --auto تماماً لضمان عدم إمكانية تعديل الملفات بالخطأ.
ميثاق التحقق الصارم: عدم الوثوق في تقرير النموذج الذاتي، حيث يقوم المُوجّه بإعادة تشغيل الاختبارات بنفسه وفحص git diff للتأكد من عدم وجود تلاعب بالاختبارات أو التفافات برمجية خبيثة.
2. نقاط الضعف ومجالات التحسين (ما الذي يجعل النسخة الجديدة أكثر قوة؟)
على الرغم من قوة التصميم الحالي، إلا أنه يحتوي على فجوات تشغيلية حقيقية تم استخلاصها ومعالجتها:

الميزة / الجانب
مهارة opencode-delegate الأصلية
النسخة المطورة (opencode-super-delegate)
دعم البيئات والنظم
تعتمد أساساً على سكريبتات Bash/Node فقط (relay.mjs) وتواجه مشاكل ترميز مع ويندوز.
تدعم native PowerShell 7+ و POSIX Bash مع ضبط ترميز UTF-8 القسري تلقائياً.
إدارة المزودات والنماذج
لا تملك آلية تلقائية لحل المزودات؛ تتطلب تمرير النموذج يدوياً بدون إدراك لأولويات المستخدم.
مدمجة بسلسلة أولويات محددة مسبقاً (OpenAI، ثم OpenCode Go، ثم OpenRouter، ثم Ollama، ثم Anthropic).
أمان العمليات الطرفية
تعتمد على --auto كلياً بدون فرض قيود تفصيلية على سطر الأوامر.
تحقن تكوين أمان بيئي (OPENCODE_CONFIG_CONTENT) يمنع تلقائياً أوامر الحذف التخريبية والدفع الإجباري للـ Git.
صمام أمان التكرار (Circuit Breaker)
في حال حدوث خطأ أو تشوه في التقييم، قد تظل الجلسات معلقة أو تتكرر يدوياً.
تفرض صمام أمان محكم (بحد أقصى 3 محاولات) مع فحص مرن عبر Regex ((?i)\bPASS\b).

3. المهارة المطورة الجاهزة للاستخدام (opencode-super-delegate)
يمكنك نسخ هذا الملف مباشرة وحفظه كـ SKILL.md داخل مجلد المهارات الخاص بك:
---
name: opencode-super-delegate
description: >-
  Advanced autonomous delegation skill that commands the OpenCode CLI as an unattended
  background implementer. Translates high-level tasks into strictly bounded briefs,
  enforces environment safety, dynamically resolves model routing across preferred
  gateways, validates diff integrity, and preserves human/orchestrator commit authority.
license: MIT
compatibility: Requires Node 18+, OpenCode CLI (`opencode`), git, and PowerShell 7+ (Windows) or Bash (Linux/macOS).
metadata:
  version: 1.0.0
---

# OpenCode Super Delegate

You are the **Orchestrator**. You formulate bounded engineering briefs, dispatch them to the **OpenCode CLI** (the Implementer) via background sessions, inspect the real working-tree diff against quality gates, and maintain absolute authority over the Git commit boundary.

---

## 1. Provider & Model Routing Hierarchy

OpenCode has no implicit fallback model. When parameterizing a dispatch, resolve the target model using the `<provider_id>/<model_id>` contract following this prioritized hierarchy:

1. **OpenAI (Default Priority)**: `openai/gpt-4o`, `openai/o1-mini`, or OpenCode Zen proxies (`opencode/gpt-5.6-sol`).
2. **OpenCode Go**: `opencode-go/gpt-5.6-luna`, `opencode-go/deepseek-v4.1-flash`, `opencode-go/kimi-k3`.
3. **OpenRouter**: `openrouter/<vendor>/<model-name>`
4. **Ollama (Local / Cloud)**: `ollama/<model-name>`
5. **Anthropic**: `anthropic/claude-3-7-sonnet`, `anthropic/claude-3-5-haiku`

*Note: For delta briefs resuming a session (`--resume-last` or `--session <id>`), omit the model parameter to inherit the active session context.*

---

## 2. Granular Runtime Safety Architecture

When dispatching write-capable tasks, enforce inline permission boundaries using `OPENCODE_CONFIG_CONTENT` to allow unattended execution without risking accidental environment destruction:

```json
{
  "permission": {
    "bash": {
      "rm -rf *": "deny",
      "rmdir /s *": "deny",
      "git push*": "deny",
      "git commit*": "deny",
      "*": "allow"
    },
    "edit": "allow",
    "read": "allow"
  }
}


Autonomy Rule: Pass --auto for the build agent to avoid unattended hangs. Never pass --auto to the plan (--read-only) agent.
3. The 5-Stage Orchestration Loop
Stage 1: Formulate the XML Brief
A brief must be fully self-contained. Always include project gate commands explicitly:
<task>
Specific bug, feature, or refactor objective. Specify files to modify and explicitly list paths to leave untouched.
</task>

<verification_loop>
Run and pass these gates before finishing:
  - <exact test command, e.g., pytest tests/ -q | npm test>
  - <exact lint/typecheck command, e.g., ruff check . | npm run build>
Confirm git status shows only intended changes.
</verification_loop>

<action_safety>
Do NOT commit changes. Do NOT push. Leave all modifications uncommitted in the working tree for orchestrator review.
</action_safety>

<structured_output_contract>
Output a final report:
  1. Root cause or architecture implementation details.
  2. Exact list of modified files.
  3. Gate execution counts and outcomes.
  4. Explicit keyword: Output 'PASS' if gates pass; otherwise detail the blocker.
</structured_output_contract>


Stage 2: Headless Dispatch
Dispatch via the background wrapper or directly through the shell:
Windows PowerShell (.ps1):
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$env:OPENCODE_CONFIG_CONTENT = '{"permission":{"bash":{"git commit*":"deny","*":"allow"},"edit":"allow","read":"allow"}}'

$raw = opencode run --model "$TargetModel" --agent build --auto (Get-Content -Raw ./brief.txt)
$result = ($raw -join "`n").Trim()


POSIX Bash (.sh):
export OPENCODE_CONFIG_CONTENT='{"permission":{"bash":{"git commit*":"deny","*":"allow"},"edit":"allow","read":"allow"}}'

result=$(opencode run --model "$TARGET_MODEL" --agent build --auto < brief.txt | tr -d '\r')


Stage 3: Circuit-Breaker Validation Loop
Never evaluate raw agent responses with strict equality. Enforce a hard retry ceiling:
Maximum retry limit: 3 attempts.
Evaluation pattern: Regex boundary matching (?i)\bPASS\b.
If validation fails within the limit, stop execution and alert the user rather than running indefinite loops.
Stage 4: Orchestrator Diff Sweep
Do not trust the implementer's self-reported success. Re-run gates independently and inspect git diff:
Assertion Weakening: Ensure existing test assertions were not deleted, relaxed, or skipped.
Hardcoded Stubs: Verify mock data was not returned to artificially bypass real logic paths.
Scope Creep: Check git status --porcelain to confirm only requested files were touched.
Stage 5: Land the Work
Once verified, the Orchestrator performs the commit:
git add <touched_files>
git commit -m "fix(domain): describe validated changes"


If corrections are needed, dispatch a delta brief with --resume-last rather than restarting the entire task.


