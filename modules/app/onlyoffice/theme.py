import base64
import json
import os
import sys

def main():
    if len(sys.argv) < 3:
        print("Usage: theme.py <conf_path> <theme>")
        sys.exit(1)
        
    conf_path = sys.argv[1]
    theme = sys.argv[2]
    
    os.makedirs(os.path.dirname(conf_path), exist_ok=True)
    
    lines = []
    if os.path.exists(conf_path):
        with open(conf_path, 'r') as f:
            lines = f.readlines()
            
    general_found = False
    ui_theme_found = False
    appdata_found = False
    
    new_lines = []
    appdata_val = None
    
    for line in lines:
        stripped = line.strip()
        if stripped == '[General]':
            general_found = True
            new_lines.append(line)
        elif stripped.startswith('UITheme='):
            ui_theme_found = True
            new_lines.append(f"UITheme={theme}\n")
        elif stripped.startswith('appdata='):
            appdata_found = True
            content = stripped.split('appdata=', 1)[1]
            if content.startswith('"') and content.endswith('"'):
                content = content[1:-1]
            if content.startswith('@ByteArray(') and content.endswith(')'):
                b64 = content[len('@ByteArray('):-1]
                try:
                    decoded = base64.b64decode(b64).decode('utf-8')
                    appdata_val = json.loads(decoded)
                except Exception:
                    pass
        else:
            new_lines.append(line)
            
    if appdata_val is None:
        appdata_val = {}
        
    appdata_val['uitheme'] = theme
    appdata_val['usegpu'] = True
    
    new_json_str = json.dumps(appdata_val, separators=(',', ':'))
    new_b64 = base64.b64encode(new_json_str.encode('utf-8')).decode('utf-8')
    appdata_line = f"appdata=@ByteArray({new_b64})\n"
    
    final_lines = []
    if not general_found:
        final_lines.append("[General]\n")
        final_lines.append(f"UITheme={theme}\n")
        final_lines.append(appdata_line)
        final_lines.extend(new_lines)
    else:
        for line in new_lines:
            final_lines.append(line)
            if line.strip() == '[General]':
                if not ui_theme_found:
                    final_lines.append(f"UITheme={theme}\n")
                final_lines.append(appdata_line)
                
    with open(conf_path, 'w') as f:
        f.writelines(final_lines)

if __name__ == '__main__':
    main()
