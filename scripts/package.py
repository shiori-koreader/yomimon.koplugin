#!/usr/bin/env python3
"""Builds dist/yomimon.koplugin-v<version>.zip with yomimon.koplugin/ at the zip root.

Usage: package.py [tag]   (when a tag is given, it must match the version in yomimon_version.lua)
"""
import re
import sys
import zipfile
from pathlib import Path

root = Path(__file__).resolve().parent.parent
plugin = root / "yomimon.koplugin"
version = re.search(r'numero = "([^"]+)"', (plugin / "yomimon_version.lua").read_text(encoding="utf-8")).group(1)
meta = re.search(r'version = "([^"]+)"', (plugin / "_meta.lua").read_text(encoding="utf-8")).group(1)

if meta != version:
    sys.exit("_meta.lua version %s does not match yomimon_version.lua %s" % (meta, version))
if len(sys.argv) > 1 and sys.argv[1].lstrip("v") != version:
    sys.exit("tag %s does not match version %s" % (sys.argv[1], version))

# The licences travel with the plugin folder, which is all that Storefront and a manual install keep.
extras = ["LICENSE", "LICENSE-ART.md", "CREDITS.md"]
files = [(f, f.relative_to(plugin).as_posix()) for f in sorted(plugin.rglob("*"))
         if f.is_file() and "sprites" not in f.relative_to(plugin).parts]
files += [(root / name, name) for name in extras]

out = root / "dist" / ("yomimon.koplugin-v%s.zip" % version)
out.parent.mkdir(exist_ok=True)
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for path, rel in files:
        info = zipfile.ZipInfo("yomimon.koplugin/" + rel, (1980, 1, 1, 0, 0, 0))
        info.external_attr = 0o644 << 16
        info.compress_type = zipfile.ZIP_DEFLATED
        z.writestr(info, path.read_bytes())
print(out)
