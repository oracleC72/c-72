# 把 C-72自助馆 单文件版压到 GitHub Pages 吃得下的体积。
# 用法：python 压缩上线.py C-72自助馆_v3.16.html index.html
#
# 做法：页面里所有 base64 图片按「实际显示尺寸的 2 倍」重采样，
# 转成 WebP q86；原图另有备份在 原图_20261110/，源版本文件不覆盖。

import re, base64, io, os, sys
from PIL import Image

if len(sys.argv) < 3:
    print("用法：python 压缩上线.py <源文件.html> <输出 index.html>")
    sys.exit(1)
SRC, OUT = sys.argv[1], sys.argv[2]

raw = open(SRC, "rb").read().decode("utf-8")
pat = re.compile(r"data:image/([a-zA-Z0-9.+-]+);base64,([A-Za-z0-9+/=]+)")


def target_width(w, h):
    # 方形图＝图标，页面最大显示 86px
    if abs(w - h) <= 2 and w <= 400:
        return 200
    # 竖版海报：弹窗侧栏最大 380px 宽
    if h > w:
        return 700
    # 横版海报 / banner
    return 880


stats = {"conv": 0, "kept": 0, "before": 0, "after": 0}


def process(mime, b64):
    data = base64.b64decode(b64)
    stats["before"] += len(data)
    try:
        im = Image.open(io.BytesIO(data))
        im.load()
    except Exception:
        stats["kept"] += 1
        stats["after"] += len(data)
        return None
    if (im.format or "").upper() not in ("JPEG", "MPO"):
        stats["kept"] += 1
        stats["after"] += len(data)
        return None
    w, h = im.size
    tw = target_width(w, h)
    if w > tw:
        im = im.resize((tw, int(round(h * tw / w))), Image.LANCZOS)
    if im.mode != "RGB":
        im = im.convert("RGB")
    buf = io.BytesIO()
    im.save(buf, "WEBP", quality=86, method=6)
    out = buf.getvalue()
    if len(out) >= len(data):
        stats["kept"] += 1
        stats["after"] += len(data)
        return None
    stats["conv"] += 1
    stats["after"] += len(out)
    return "data:image/webp;base64," + base64.b64encode(out).decode()


def repl(m):
    return process(m.group(1), m.group(2)) or m.group(0)


open(OUT, "wb").write(pat.sub(repl, raw).encode("utf-8"))
mb_before = os.path.getsize(SRC) / 1048576
mb_after = os.path.getsize(OUT) / 1048576
print(f"转换 {stats['conv']} 张，保留 {stats['kept']} 张")
print(f"{mb_before:.1f} MB -> {mb_after:.1f} MB")
