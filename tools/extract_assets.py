#!/usr/bin/env python3
"""
Convert assets from Nv2.swf (via FFDec) into WebGL-ready atlases + JSON.

We do NOT use Ruffle or any Flash runtime here: FFDec is only used as a
build-time decompiler to read the SWF's embedded art/audio, exactly like a
texture pipeline.  The game itself is translated to JavaScript (see js/).

Run with:  python3 -I tools/extract_assets.py
"""
import base64
import json
import math
import os
import re
import shutil
import struct
import zlib
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SWF = ROOT / "Nv2.swf"
EXTRACT = ROOT / "extract"
XML = EXTRACT / "swf.xml"
OUT = ROOT / "assets"
STAGE = EXTRACT / "stage"
ATLAS = OUT / "atlas"

PAD = 2
PAGE = 2048

# name -> character id
SPRITES = {
    # gameplay art
    "asset_gfx_tiles": 523,
    "asset_gfx_ninja": 738,
    "asset_gfx_ragdoll_body": 717,
    "asset_gfx_ragdoll_arm": 722,
    "asset_gfx_ragdoll_leg": 726,
    "asset_gfx_oneway": 893,
    "asset_gfx_launchpad": 900,
    "asset_gfx_thwomp": 902,
    "asset_gfx_drone_chaingun_eye": 904,
    "asset_gfx_drone_chaingun": 910,
    "asset_gfx_gold": 913,
    "asset_gfx_door_trap": 918,
    "asset_gfx_door_trap_switch": 921,
    "asset_gfx_turret": 926,
    "asset_gfx_turret_crosshair": 931,
    "asset_gfx_bounceblock": 933,
    "asset_gfx_drone_eye": 935,
    "asset_gfx_drone_zap": 937,
    "asset_gfx_drone_chaser": 940,
    "asset_gfx_rocket": 946,
    "asset_gfx_rocket_base": 951,
    "asset_gfx_floorguard": 954,
    "asset_gfx_drone_laser": 960,
    "asset_gfx_laser_blast": 966,
    "asset_gfx_exitswitch": 969,
    "asset_gfx_exitdoor": 974,
    "asset_gfx_mine": 977,
    "asset_gfx_door_regular": 981,
    "asset_gfx_door_locked": 985,
    "asset_gfx_door_locked_switch": 986,
    # particles
    "asset_gfx_fx_zap0": 599,
    "asset_gfx_fx_fireball2": 602,
    "asset_gfx_fx_fireball1": 605,
    "asset_gfx_fx_laser_spark1": 608,
    "asset_gfx_fx_fireball0": 611,
    "asset_gfx_fx_laser_spark2": 613,
    "asset_gfx_fx_fireburst0": 621,
    "asset_gfx_fx_fireburst1": 628,
    "asset_gfx_fx_dust0": 633,
    "asset_gfx_fx_chain_debris0": 636,
    "asset_gfx_fx_dust1": 641,
    "asset_gfx_fx_laser_charge0": 645,
    "asset_gfx_fx_laser_charge1": 648,
    "asset_gfx_fx_laser_charge2": 651,
    "asset_gfx_fx_rocket_smoke2": 655,
    "asset_gfx_fx_chain_flash0": 658,
    "asset_gfx_fx_rocket_smoke0": 662,
    "asset_gfx_fx_chain_flash1": 665,
    "asset_gfx_fx_rocket_smoke1": 669,
    "asset_gfx_fx_turret_bullet": 672,
    "asset_gfx_fx_blood1": 675,
    "asset_gfx_fx_blood0": 677,
    "asset_gfx_fx_zapv1": 681,
    "asset_gfx_fx_zapv2": 685,
    "asset_gfx_fx_zapv0": 689,
    "asset_gfx_fx_chain_bullet": 691,
    "asset_gfx_fx_chain_debris1": 694,
    "asset_gfx_fx_chain_debris2": 696,
    "asset_gfx_fx_laser_spark0": 698,
    "asset_gfx_fx_zap2": 702,
    "asset_gfx_fx_zap1": 706,
    "asset_gfx_fx_turret_debris0": 709,
    # UI
    "asset_ui_preloader": 16,
    "asset_ui_episodes": 32,
    "asset_ui_help": 372,
    "asset_ui_credits": 83,
    "asset_ui_story": 376,
    "asset_ui_menu_settings": 391,
    "asset_ui_menu_help": 401,
    "asset_ui_menu_story": 412,
    "asset_ui_menu_credits": 425,
    "asset_ui_menu_episodes": 439,
    "asset_ui_menu_userlevels": 451,
    "asset_ui_menu_resume": 471,
    "asset_ui_menu_logo": 474,
    "asset_ui_menu_metanet": 477,
    "asset_ui_menu_kong": 478,
    "asset_ui_menu_news": 455,
    "asset_ui_return": 31,
    "asset_ui_episodebutton": 496,
    "asset_ui_episodebutton_beaten": 495,
    "asset_ui_episodebutton_bg": 490,
    "asset_ui_episodebutton_bg_over": 494,
    "asset_ui_prompt": 113,
    "asset_ui_gameover": 98,
    "asset_ui_timebar": 8,
    "asset_ui_goldcounter": 101,
    # hidden (kept for completeness)
    "asset_ui_menu_login": 308,
    # sound-event movieclips (no visible art)
    "asset_sfx_playerMC": 735,
    "asset_sfx_playerLoopMC": 712,
    "asset_sfx_ragdollMC": 534,
    # settings (account) screen widgets
    "asset_ui_account": 332,
    "asset_ui_volumeknob": 253,
    "asset_ui_swatch": 546,
    "asset_ui_clear": 322,
    "asset_ui_key_menu_left": 309,
    "asset_ui_key_menu_up": 310,
    "asset_ui_key_menu_right": 311,
    "asset_ui_key_menu_down": 314,
    "asset_ui_key_menu_select": 317,
    "asset_ui_key_menu_back": 318,
    "asset_ui_key_pause": 270,
    "asset_ui_key_solo_left": 325,
    "asset_ui_key_solo_jump": 326,
    "asset_ui_key_solo_right": 327,
    "asset_ui_key_solo_suicide": 328,
    "asset_ui_key_p1_left": 261,
    "asset_ui_key_p1_jump": 262,
    "asset_ui_key_p1_right": 263,
    "asset_ui_key_p1_suicide": 271,
    "asset_ui_key_p2_left": 272,
    "asset_ui_key_p2_jump": 273,
    "asset_ui_key_p2_right": 274,
    "asset_ui_key_p2_suicide": 275,
}

# Sprites exported from a patched copy of the SWF.  The original stores the
# online login panel and the volume knob baked into the AccountScreen, but the
# offline game hides the login panel and positions the knob at runtime, so the
# baked assets must not contain them.
SETTINGS_SPRITE_IDS = {332, 253, 546, 322, 309, 310, 311, 314, 317, 318, 270,
                       325, 326, 327, 328, 261, 262, 263, 271, 272, 273, 274, 275}
# <PlaceObject2Tag> children to drop: loginPanel inside AccountScreen and the
# slider knob inside VolumeSlider.
PATCH_PLACEMENTS = {(332, 308), (254, 253)}
# DefineEditText whose initial "100" caption belongs to the volume knob.
PATCH_EMPTY_TEXT = {250}

# gameover: one representative frame per label section (start frame)
GAMEOVER_TAKE = {61, 122, 183, 244, 305, 366, 427, 488, 549}

# only these frames of huge timelines are used by the ported code
TAKE_FRAMES = {
    8: {1, 2, 1004},       # TimeBar (we also draw it procedurally)
    98: GAMEOVER_TAKE,     # GameOverPopup
}

# sprites that are pure audio containers (no visible art needed)
AUDIO_ONLY = {712, 735, 534, 324, 524}

SHAPES = {
    "asset_ui_goldicon": 100,
    "asset_ui_dot": 103,
    "asset_ui_beaten_check": 491,
}

FONTS_KEEP = ["uni 05_53", "ProggySquareTTSZ"]


def run(cmd, **kw):
    print("+", " ".join(str(c) for c in cmd))
    r = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, **kw)
    if r.returncode != 0:
        raise SystemExit(f"command failed ({r.returncode}): {r.stdout[-4000:]}")
    return r.stdout


def ffdec(*args, timeout=1800):
    env = dict(os.environ)
    env["DISPLAY"] = ""
    env["JAVA_TOOL_OPTIONS"] = "-Djava.awt.headless=true"
    return run(["ffdec", *map(str, args)], env=env, timeout=timeout)


# ---------------------------------------------------------------- SWF binary sound flags
def parse_binary_sound_flags(swf_path):
    """StartSoundTag flags (loops / syncStop / syncNoMultiple) are not exposed
    by FFDec's XML, so read them from the raw SWF tag stream."""
    raw = zlib.decompress(open(swf_path, "rb").read()[8:])
    nbits = raw[0] >> 3
    bitpos = 5 + 4 * nbits
    start = (bitpos + 7) // 8 + 4
    out = {}

    def tag_at(pos):
        h = struct.unpack_from("<H", raw, pos)[0]
        code = h >> 6
        ln = h & 0x3f
        p = pos + 2
        if ln == 0x3f:
            ln = struct.unpack_from("<I", raw, p)[0]
            p += 4
        return code, ln, p

    def sound_info(p):
        sid = struct.unpack_from("<H", raw, p)[0]
        b = raw[p + 2]
        sync_stop = (b >> 5) & 1
        no_multiple = (b >> 4) & 1
        has_env = (b >> 3) & 1
        has_loops = (b >> 2) & 1
        has_out = (b >> 1) & 1
        has_in = b & 1
        q = p + 3
        in_point = out_point = None
        if has_in: in_point = struct.unpack_from("<I", raw, q)[0]; q += 4
        if has_out: out_point = struct.unpack_from("<I", raw, q)[0]; q += 4
        loops = 1
        if has_loops: loops = struct.unpack_from("<H", raw, q)[0]; q += 2
        return {"id": sid, "loops": loops, "syncStop": bool(sync_stop),
                "noMultiple": bool(no_multiple), "inPoint": in_point, "outPoint": out_point}

    def parse(pos, end, ctx):
        while pos < end:
            code, ln, p = tag_at(pos)
            if code == 0:
                return
            if code == 39:
                sid = struct.unpack_from("<H", raw, p)[0]
                parse(p + 4, p + ln, sid)
            elif code == 15:
                out.setdefault(ctx, []).append(sound_info(p))
            pos = p + ln

    parse(start, len(raw), None)
    return out


# ---------------------------------------------------------------- SWF XML data
class SwfData:
    def __init__(self, xml_path, binary_sounds=None):
        self.binary_sounds = binary_sounds or {}
        root = ET.parse(xml_path).getroot()
        self.sprites = {}
        self.sounds = set()
        self.frames_of = {}
        self._walk(root)
        self.symbol_class = {}
        for line in (EXTRACT / "assets" / "symbolClass" / "symbols.csv").read_text().splitlines():
            if ";" in line:
                cid, name = line.split(";", 1)
                self.symbol_class.setdefault(int(cid), name)

    def _walk(self, el):
        for ch in el:
            if ch.tag == "item":
                ty = ch.get("type")
                if ty == "DefineSpriteTag" and ch.get("spriteId"):
                    sid = int(ch.get("spriteId"))
                    self.sprites[sid] = ch
                    self._read_frames(ch, sid)
                elif ty == "DefineSoundTag":
                    self.sounds.add(int(ch.get("soundId")))
            self._walk(ch)

    def _read_frames(self, sprite, sid):
        fr = 0
        labels = []
        sounds = {}
        sound_idx = 0
        bin_sounds = self.binary_sounds.get(sid, [])
        for it in sprite.find("subTags"):
            ty = it.get("type")
            if ty == "ShowFrameTag":
                fr += 1
            elif ty == "FrameLabelTag":
                labels.append((fr + 1, it.get("name")))
            elif ty == "StartSoundTag":
                sid_sound = int(it.get("soundId"))
                info = bin_sounds[sound_idx] if sound_idx < len(bin_sounds) else {}
                sound_idx += 1
                if info.get("id") != sid_sound:
                    info = {"id": sid_sound, "loops": 1, "syncStop": False, "noMultiple": False,
                            "inPoint": None, "outPoint": None}
                sounds[fr + 1] = info
        self.frames_of[sid] = {"frameCount": int(sprite.get("frameCount")), "labels": labels,
                               "sounds": sounds}

    def anchors_for(self, sid, names):
        """Per-frame local positions of named children (used by the ninja ragdoll)."""
        s = self.sprites.get(sid)
        if s is None:
            return None
        active = {}   # depth -> [name, x, y]
        out = []
        frame = 0
        for it in s.find("subTags"):
            ty = it.get("type")
            if ty == "PlaceObject2Tag":
                depth = int(it.get("depth") or 0)
                name = it.get("name")
                mat = it.find("matrix")
                if depth in active:
                    if name:
                        active[depth][0] = name
                else:
                    active[depth] = [name, 0.0, 0.0]
                if mat is not None:
                    active[depth][1] = int(mat.get("translateX") or 0) / 20.0
                    active[depth][2] = int(mat.get("translateY") or 0) / 20.0
            elif ty == "RemoveObjectTag":
                active.pop(int(it.get("depth") or 0), None)
            elif ty == "ShowFrameTag":
                base = 0 if not out else out[-1]
                rec = {}
                for nm, ax, ay in active.values():
                    if nm in names:
                        rec[nm] = [ax, ay]
                if not rec and out:
                    rec = dict(out[-1])
                out.append(rec)
                frame += 1
        return out

    def class_scripts(self, sid):
        """Parse addFrameScript(...) from the decompiled asset class, if any."""
        name = self.symbol_class.get(sid)
        if not name:
            return [], {}
        base = name.split(".")[-1]
        cands = list((EXTRACT / "scripts" / "scripts").rglob(base + ".as"))
        path = cands[0] if cands else None
        scripts = {}
        if path is not None and path.exists():
            txt = path.read_text(errors="replace")
            m = re.search(r"addFrameScript\((.*?)\);", txt, re.S)
            if m:
                pairs = re.findall(r"(\d+)\s*,\s*this\.(\w+)", m.group(1))
                fns = {fn: body for fn, body in re.findall(
                    r"function\s+(\w+)\s*\([^)]*\)\s*:\s*\*\s*\{(.*?)\n\s*\}", txt, re.S)}
                for fidx_s, fn in pairs:
                    body = fns.get(fn, "")
                    fidx = int(fidx_s) + 1
                    if "gotoAndPlay" in body:
                        g = re.search(r"gotoAndPlay\((\d+)\)", body)
                        scripts[fidx] = "gotoAndPlay:%s" % (g.group(1) if g else "1")
                    elif "gotoAndStop" in body:
                        g = re.search(r"gotoAndStop\((\d+)\)", body)
                        scripts[fidx] = "gotoAndStop:%s" % (g.group(1) if g else "1")
                    elif "stop" in body:
                        scripts[fidx] = "stop"
                    elif "play" in body:
                        scripts[fidx] = "play"
        return [], scripts


# ---------------------------------------------------------------- ffdec export
def build_patched_swf(dst):
    """Copy the SWF with the offline-only settings patches applied.

    The online login panel and the volume knob are baked into the AccountScreen
    symbol; this port runs the offline path (account.useDatabase == false), so
    the screen must be exported without them.
    """
    xml_src = EXTRACT / "swf.xml"
    if not xml_src.exists():
        ffdec("-swf2xml", SWF, xml_src)
    tree = ET.parse(xml_src)
    root = tree.getroot()
    for item in root.iter("item"):
        if item.get("type") != "DefineSpriteTag":
            continue
        sid = int(item.get("spriteId"))
        subs = item.find("subTags")
        if subs is None:
            continue
        for child in list(subs):
            if child.get("type") != "PlaceObject2Tag":
                continue
            cid = int(child.get("characterId"))
            if (sid, cid) in PATCH_PLACEMENTS:
                subs.remove(child)
    for item in root.iter("item"):
        if item.get("type") == "DefineEditTextTag" and int(item.get("characterID")) in PATCH_EMPTY_TEXT:
            item.set("initialText", "")
            item.set("hasText", "false")
    xml_patched = STAGE / "swf_patched.xml"
    tree.write(xml_patched, encoding="utf-8", xml_declaration=True)
    ffdec("-xml2swf", xml_patched, dst)
    xml_patched.unlink()


def export_all():
    if STAGE.exists():
        shutil.rmtree(STAGE)
    (STAGE / "png").mkdir(parents=True)
    (STAGE / "svg").mkdir(parents=True)
    (STAGE / "shape_png").mkdir(parents=True)
    (STAGE / "shape_svg").mkdir(parents=True)

    ids = sorted(set(SPRITES.values()) - SETTINGS_SPRITE_IDS)
    sel = ",".join(str(i) for i in ids)
    ffdec("-format", "sprite:png", "-selectid", sel, "-export", "sprite", STAGE / "png", SWF)
    ffdec("-format", "sprite:svg", "-selectid", sel, "-export", "sprite", STAGE / "svg", SWF)

    shape_ids = ",".join(str(i) for i in sorted(set(SHAPES.values())))
    ffdec("-format", "shape:png", "-selectid", shape_ids, "-export", "shape", STAGE / "shape_png", SWF)
    ffdec("-format", "shape:svg", "-selectid", shape_ids, "-export", "shape", STAGE / "shape_svg", SWF)

    patched = STAGE / "patched.swf"
    build_patched_swf(patched)
    sel = ",".join(str(i) for i in sorted(SETTINGS_SPRITE_IDS))
    ffdec("-format", "sprite:png", "-selectid", sel, "-export", "sprite", STAGE / "png", patched)
    ffdec("-format", "sprite:svg", "-selectid", sel, "-export", "sprite", STAGE / "svg", patched)


def index_exported(dirpath, suffix):
    """Return {characterId: [files sorted by frame number]}"""
    out = {}
    for d in dirpath.iterdir():
        if d.is_dir():
            m = re.search(r"Define(?:Sprite|Shape)_(\d+)", d.name)
            if not m:
                continue
            cid = int(m.group(1))
            files = [f for f in d.iterdir() if f.suffix == "." + suffix]
            files.sort(key=lambda p: int(p.stem) if p.stem.isdigit() else 0)
            out.setdefault(cid, []).extend(files)
        elif d.suffix == "." + suffix:
            m = re.match(r"(\d+)", d.stem)
            if m:
                out.setdefault(int(m.group(1)), []).append(d)
    return out


def svg_origin(path):
    txt = path.read_text(errors="replace")[:4000]
    m = re.search(r'<svg[^>]*height="([0-9.]+)px" width="([0-9.]+)px"', txt)
    g = re.search(r'<g transform="matrix\(([^)]*)\)"', txt)
    if not m or not g:
        raise ValueError("no size/origin in " + str(path))
    h, w = float(m.group(1)), float(m.group(2))
    parts = [float(x) for x in g.group(1).split(",")]
    return w, h, parts[4], parts[5]


def load_frame(path):
    im = Image.open(path).convert("RGBA")
    bbox = im.getchannel("A").getbbox()
    return im, bbox


# ---------------------------------------------------------------- atlas packing
class Packer:
    def __init__(self, page=PAGE, pad=PAD):
        self.page = page
        self.pad = pad
        self.pages = []
        self.shelves = []
        self.cur = None
        self.x = self.y = 0
        self.new_page()

    def new_page(self):
        self.cur = len(self.pages)
        self.pages.append(Image.new("RGBA", (self.page, self.page), (0, 0, 0, 0)))
        self.shelves = []
        self.x = self.y = 0

    def add(self, im, bbox):
        x0, y0, x1, y1 = bbox
        w, h = x1 - x0, y1 - y0
        pw, ph = w + 2 * self.pad, h + 2 * self.pad
        if pw > self.page or ph > self.page:
            raise ValueError(f"frame too big {w}x{h}")
        placed = None
        for sh in self.shelves:
            if sh["h"] >= ph and sh["x"] + pw <= self.page:
                placed = (sh["x"], sh["y"])
                sh["x"] += pw
                break
        if placed is None:
            if self.x + pw > self.page or self.y + ph > self.page:
                self.new_page()
            shelf = {"y": self.y, "h": ph, "x": pw}
            self.shelves.append(shelf)
            placed = (0, self.y)
            self.y += ph
        ax, ay = placed
        # copy content, then extrude 1px at the content edges into the pad ring
        crop = im.crop(bbox)
        padded = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
        padded.paste(crop, (self.pad, self.pad))
        px = padded.load()
        # left/right extrusion
        for yy in range(self.pad, self.pad + h):
            px[self.pad - 1, yy] = px[self.pad, yy]
            px[self.pad + w, yy] = px[self.pad + w - 1, yy]
        for xx in range(self.pad, self.pad + w):
            px[xx, self.pad - 1] = px[xx, self.pad]
            px[xx, self.pad + h] = px[xx, self.pad + h - 1]
        self.pages[self.cur].paste(padded, (ax, ay))
        return self.cur, ax, ay, pw, ph, w, h


# ---------------------------------------------------------------- main process
def main():
    if not XML.exists():
        ffdec("-swf2xml", SWF, XML)
    sd = SwfData(XML, parse_binary_sound_flags(SWF))
    export_all()

    pngs = index_exported(STAGE / "png", "png")
    svgs = index_exported(STAGE / "svg", "svg")
    shape_pngs = index_exported(STAGE / "shape_png", "png")
    shape_svgs = index_exported(STAGE / "shape_svg", "svg")

    for sub in ("atlas", "audio", "fonts", "data"):
        (OUT / sub).mkdir(parents=True, exist_ok=True)
    for f in ATLAS.glob("atlas-*.png"):
        f.unlink()

    packer = Packer()
    sprite_meta = {}

    for name, cid in SPRITES.items():
        files = pngs.get(cid)
        svg_files = svgs.get(cid)
        if not files or not svg_files:
            print("WARN: no export for", name, cid)
            continue
        # origin of the sprite's frame canvas (constant for all frames)
        sw, sh, ox, oy = svg_origin(svg_files[0])
        frames = []
        frame_numbers = []
        take = TAKE_FRAMES.get(cid)
        export_set = [(i + 1, f) for i, f in enumerate(files) if (take is None or (i + 1) in take)]
        if cid in AUDIO_ONLY:
            export_set = []
        for frame_no, f in export_set:
            frame_numbers.append(frame_no)
            im, bbox = load_frame(f)
            if bbox is None:
                frames.append(None)
                continue
            scale_x = im.width / sw if sw else 1.0
            scale_y = im.height / sh if sh else 1.0
            origin_x = ox * scale_x
            origin_y = oy * scale_y
            page, ax, ay, pw, ph, w, h = packer.add(im, bbox)
            cx, cy = bbox[0], bbox[1]
            frames.append({
                "p": page,
                "sx": ax, "sy": ay, "sw": pw, "sh": ph,
                "qx": cx - origin_x, "qy": cy - origin_y,
                "w": w, "h": h,
            })
        meta = sd.frames_of.get(cid, {"frameCount": len(files), "labels": [], "sounds": {}})
        anchors = None
        if cid == 738:
            anchors = sd.anchors_for(738, {"shoulder", "pelvis", "handR", "handL", "footR", "footL"})
        _, scripts = sd.class_scripts(cid)
        # frame number of labels is 1-based; convert labels list
        labels = {}
        for fr, label in meta["labels"]:
            labels[label] = fr
        sprite_meta[name] = {
            "id": cid,
            "frames": frames,
            "frameCount": meta["frameCount"],
            "frameNumbers": frame_numbers,
            "labels": labels,
            "scripts": scripts,
            "sounds": {str(k): v for k, v in meta["sounds"].items()},
        }
        if anchors is not None:
            sprite_meta[name]["anchors"] = anchors
        if cid == 98:
            # map gameover representative frame -> section label
            labels_map = {v: k for k, v in labels.items()}
            sprite_meta[name]["takeLabels"] = {str(fr): labels_map.get(fr, "") for fr in GAMEOVER_TAKE}

    shape_meta = {}
    for name, cid in SHAPES.items():
        files = shape_pngs.get(cid)
        svg_files = shape_svgs.get(cid)
        if not files or not svg_files:
            print("WARN: no shape export", name, cid)
            continue
        im, bbox = load_frame(files[0])
        sw, sh, ox, oy = svg_origin(svg_files[0])
        scale_x = im.width / sw if sw else 1.0
        scale_y = im.height / sh if sh else 1.0
        page, ax, ay, pw, ph, w, h = packer.add(im, bbox)
        shape_meta[name] = {
            "id": cid, "p": page, "sx": ax, "sy": ay, "sw": pw, "sh": ph,
            "qx": bbox[0] - ox * scale_x, "qy": bbox[1] - oy * scale_y,
            "w": w, "h": h,
        }

    # write atlas pages
    pages = []
    for i, page in enumerate(packer.pages):
        # trim fully empty pages
        page.save(ATLAS / f"atlas-{i}.png")
        pages.append(f"atlas/atlas-{i}.png")
    print("atlas pages:", len(pages), "size:", sum(p.size[0]*p.size[1] for p in packer.pages) / 1e6, "MP")

    # sounds
    sound_files = {}
    for f in sorted((EXTRACT / "sounds").glob("*.mp3")):
        sid = int(f.name.split("_")[0].split(".")[0])
        dst = OUT / "audio" / f.name
        shutil.copyfile(f, dst)
        sound_files[sid] = "audio/" + f.name

    # fonts
    font_map = {}
    for f in (EXTRACT / "assets" / "fonts").glob("*.ttf"):
        m = re.match(r"(\d+)_(.*)\.ttf", f.name)
        if not m:
            continue
        fid = int(m.group(1))
        dst = OUT / "fonts" / f.name
        shutil.copyfile(f, dst)
        font_map[fid] = {"file": "fonts/" + f.name, "name": m.group(2)}

    # flavours bitmap
    fl_dir = STAGE / "flavours"
    fl_dir.mkdir(exist_ok=True)
    env = dict(os.environ); env["DISPLAY"] = ""
    run(["ffdec", "-format", "image:png", "-selectid", "1216", "-export", "image", fl_dir, SWF],
        env=env)
    fl_img = None
    for f in fl_dir.rglob("*.png"):
        fl_img = Image.open(f).convert("RGBA")
        break
    flavours = None
    if fl_img is not None:
        w = fl_img.width
        def px(x, y):
            r, g, b, a = fl_img.getpixel((x, y))
            return (r << 16) | (g << 8) | b
        flavours = [[px(x, 0) for x in range(w)], [px(x, 1) for x in range(w)]]
        fl_img.save(OUT / "flavours.png")
        print("flavours:", flavours[0][:10])

    # attract-mode replays (same container format as the level data)
    attract_bin = (EXTRACT / "assets" / "binaryData" /
                   "1218_com.metanet.commands.StoreAttractModeReplays_Replays.bin").read_bytes()
    attract = []
    p2 = 0
    while p2 < len(attract_bin):
        level_id, ln = struct.unpack_from(">ii", attract_bin, p2); p2 += 8
        replay = attract_bin[p2:p2 + ln]; p2 += ln
        attract.append({"level": level_id, "data": base64.b64encode(replay).decode("ascii")})
    (OUT / "data" / "attract.json").write_text(json.dumps(attract, separators=(",", ":")))
    print("attract replays:", len(attract))

    # levels
    level_bin = (EXTRACT / "assets" / "binaryData" /
                 "1217_com.metanet.commands.StoreMetanetLevelData_Levels.bin").read_bytes()
    levels = []
    p = 0
    while p < len(level_bin):
        ep, idx, ln = struct.unpack_from(">iii", level_bin, p); p += 12
        chunk = level_bin[p:p + ln]; p += ln
        ulen = struct.unpack_from(">H", chunk, 0)[0]
        lname = chunk[2:2 + ulen].decode("utf-8", "replace")
        levels.append({"e": ep, "i": idx, "name": lname,
                       "data": base64.b64encode(chunk).decode("ascii")})
    (OUT / "data" / "levels.json").write_text(json.dumps(levels, separators=(",", ":")))
    print("levels:", len(levels))

    # text formats used by the ported code (read from the SWF's edit-text tags)
    text_meta = {}
    for cid in (99, 102, 104, 105, 106, 492):
        for el in XML.read_text(errors="replace").split("<item "):
            if f'characterID="{cid}"' in el and 'DefineEditTextTag' in el:
                attrs = dict(re.findall(r'(\w+)="([^"]*)"', el[:el.find(">")]))
                bounds = re.search(r'<bounds[^>]*Xmin="(-?\d+)"[^>]*Xmax="(-?\d+)"[^>]*Ymin="(-?\d+)"[^>]*Ymax="(-?\d+)"', el)
                text_meta[str(cid)] = {
                    "fontId": int(attrs.get("fontId", "14")),
                    "height": int(attrs.get("fontHeight", "160")) / 20.0,
                    "align": int(attrs.get("align", "0")),
                    "bounds": [int(x) / 20.0 for x in bounds.groups()] if bounds else None,
                }
                break

    # VolumeSlider geometry: the bar is an invisible hit area (shape 248).
    vol_bar = re.search(
        r'<item type="DefineShape4?Tag"[^>]*shapeId="248".*?<shapeBounds[^>]*Xmax="(-?\d+)"',
        XML.read_text(errors="replace"), re.S)
    volume_bar_width = (int(vol_bar.group(1)) - 0) / 20.0 if vol_bar else 96.0
    data = {
        "pages": pages,
        "sprites": sprite_meta,
        "shapes": shape_meta,
        "sounds": {str(k): v for k, v in sound_files.items()},
        "fonts": {str(k): v for k, v in font_map.items()},
        "flavours": flavours,
        "textFields": text_meta,
        "settings": {"volumeBarWidth": volume_bar_width},
    }
    (OUT / "assets.json").write_text(json.dumps(data, separators=(",", ":")))
    print("wrote", OUT / "assets.json", (OUT / "assets.json").stat().st_size)


if __name__ == "__main__":
    main()
