"""Run stock Lua tests with the Lua 5.5 runtime used by Usagi. Install: python -m pip install lupa"""
from pathlib import Path
import sys
from lupa.lua55 import LuaRuntime

root = Path(__file__).resolve().parent.parent
files = [root / name for name in sys.argv[1:]] or sorted((root / "tests").glob("*.lua"))
for path in files:
    lua = LuaRuntime()
    lua.execute("package.path = ... .. '/?.lua;' .. package.path", root.as_posix())
    lua.execute(path.read_text(encoding="utf-8"))
    print(f"PASS {path.relative_to(root)}")
