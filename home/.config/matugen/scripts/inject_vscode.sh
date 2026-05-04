#!/bin/bash
# Inject matugen colors into VSCode settings.json
# Merges workbench.colorCustomizations and editor.tokenColorCustomizations

INJECT_FILE="$HOME/.cache/matugen_vscode_inject.json"
VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"

if [ ! -f "$INJECT_FILE" ]; then
    echo "inject_vscode.sh: $INJECT_FILE not found"
    exit 1
fi

# Create settings dir if missing
mkdir -p "$(dirname "$VSCODE_SETTINGS")"

# Create empty settings if missing
[ ! -f "$VSCODE_SETTINGS" ] && echo '{}' > "$VSCODE_SETTINGS"

python3 - "$INJECT_FILE" "$VSCODE_SETTINGS" << 'PYEOF'
import json
import re
import sys

def strip_jsonc(text):
    """去除 JSONC 中的 // 注释和尾部逗号，转为标准 JSON"""
    lines = []
    for line in text.split('\n'):
        stripped = line.strip()
        if stripped.startswith('//'):
            lines.append('')
            continue
        if '//' in line:
            in_string = False
            escaped = False
            result = []
            i = 0
            while i < len(line):
                ch = line[i]
                if not in_string:
                    if ch == '"' and not escaped:
                        in_string = True
                    elif ch == '/' and i + 1 < len(line) and line[i + 1] == '/':
                        break
                    result.append(ch)
                else:
                    if ch == '\\' and not escaped:
                        escaped = True
                    elif ch == '"' and not escaped:
                        in_string = False
                    else:
                        escaped = False
                    result.append(ch)
                i += 1
            line = ''.join(result)
        lines.append(line)
    text = '\n'.join(lines)
    text = re.sub(r',\s*(\}|\])', r'\1', text)
    return text

inject_file = sys.argv[1]
settings_file = sys.argv[2]

with open(inject_file, 'r') as f:
    inject_data = json.loads(strip_jsonc(f.read()))

with open(settings_file, 'r') as f:
    settings = json.loads(strip_jsonc(f.read()))

# Merge colorCustomizations
if 'workbench.colorCustomizations' in inject_data:
    if 'workbench.colorCustomizations' not in settings:
        settings['workbench.colorCustomizations'] = {}
    settings['workbench.colorCustomizations'].update(inject_data['workbench.colorCustomizations'])

# Merge tokenColorCustomizations
if 'editor.tokenColorCustomizations' in inject_data:
    if 'editor.tokenColorCustomizations' not in settings:
        settings['editor.tokenColorCustomizations'] = {}
    settings['editor.tokenColorCustomizations'].update(inject_data['editor.tokenColorCustomizations'])

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)

print("VSCode colors injected successfully")
PYEOF
