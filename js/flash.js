/*
 * flash.js -- a small, purpose-built reimplementation of the parts of the
 * Flash Player API that Nv2 uses.  This is NOT a general Flash emulator:
 * it implements the display list, MovieClip timelines, events, text fields,
 * ByteArray and sound objects on top of the browser, and renders through the
 * custom WebGL batch renderer in renderer.js.
 *
 * The AS3 game code has been translated into JavaScript and talks to these
 * classes exactly as it talked to the Flash builtins.
 */

export const STAGE_W = 792;
export const STAGE_H = 600;

export const Keyboard = {
  BACKSPACE: 8, TAB: 9, ENTER: 13, SHIFT: 16, CONTROL: 17, CAPS_LOCK: 20,
  ESCAPE: 27, SPACE: 32, PAGE_UP: 33, PAGE_DOWN: 34, END: 35, HOME: 36,
  LEFT: 37, UP: 38, RIGHT: 39, DOWN: 40, INSERT: 45, DELETE: 46,
  0: 48, 1: 49, 2: 50, 3: 51, 4: 52, 5: 53, 6: 54, 7: 55, 8: 56, 9: 57,
  A: 65, B: 66, C: 67, D: 68, E: 69, F: 70, G: 71, H: 72, I: 73, J: 74,
  K: 75, L: 76, M: 77, N: 78, O: 79, P: 80, Q: 81, R: 82, S: 83, T: 84,
  U: 85, V: 86, W: 87, X: 88, Y: 89, Z: 90,
  NUMPAD_0: 96, NUMPAD_1: 97, NUMPAD_2: 98, NUMPAD_3: 99, NUMPAD_4: 100,
  NUMPAD_5: 101, NUMPAD_6: 102, NUMPAD_7: 103, NUMPAD_8: 104, NUMPAD_9: 105,
  SEMICOLON: 186, EQUAL: 187, COMMA: 188, MINUS: 189, PERIOD: 190,
  SLASH: 191, BACKQUOTE: 192, LEFTBRACKET: 219, BACKSLASH: 220,
  RIGHTBRACKET: 221, QUOTE: 222,
  capsLock: false,
};

const startTime = (typeof performance !== "undefined" ? performance.now() : Date.now());
export function getTimer() {
  return (typeof performance !== "undefined" ? performance.now() : Date.now()) - startTime;
}

// ------------------------------------------------------------------ events
export class Event {
  constructor(type, bubbles = false, cancelable = false) {
    this.type = type;
    this.bubbles = bubbles;
    this.cancelable = cancelable;
    this.target = null;
    this.currentTarget = null;
    this._stop = false;
  }
  stopPropagation() { this._stop = true; }
  stopImmediatePropagation() { this._stop = true; }
  preventDefault() {}
}
Event.ENTER_FRAME = "enterFrame";
Event.ADDED_TO_STAGE = "addedToStage";
Event.REMOVED_FROM_STAGE = "removedFromStage";

export class MouseEvent extends Event {
  constructor(type, bubbles = true, stageX = 0, stageY = 0, buttonDown = false) {
    super(type, bubbles);
    this.stageX = stageX;
    this.stageY = stageY;
    this.localX = stageX;
    this.localY = stageY;
    this.buttonDown = buttonDown;
    this.ctrlKey = false;
  }
}
MouseEvent.CLICK = "click";
MouseEvent.MOUSE_DOWN = "mouseDown";
MouseEvent.MOUSE_UP = "mouseUp";
MouseEvent.MOUSE_MOVE = "mouseMove";
MouseEvent.MOUSE_OVER = "mouseOver";
MouseEvent.MOUSE_OUT = "mouseOut";

export class KeyboardEvent extends Event {
  constructor(type, bubbles = true, keyCode = 0) {
    super(type, bubbles);
    this.keyCode = keyCode;
    this.ctrlKey = false;
    this.shiftKey = false;
  }
}
KeyboardEvent.KEY_DOWN = "keyDown";
KeyboardEvent.KEY_UP = "keyUp";

export class KeyboardFocusEvent extends Event {
  constructor(type, bubbles = true) { super(type, bubbles); }
}
KeyboardFocusEvent.FOCUS_IN = "focusIn";
KeyboardFocusEvent.FOCUS_OUT = "focusOut";

export class EventDispatcher {
  constructor() { this._listeners = null; }
  addEventListener(type, fn, useCapture = false, priority = 0, useWeak = false) {
    if (!this._listeners) this._listeners = {};
    (this._listeners[type] ||= []).push(fn);
  }
  removeEventListener(type, fn) {
    const a = this._listeners && this._listeners[type];
    if (!a) return;
    const i = a.indexOf(fn);
    if (i >= 0) a.splice(i, 1);
  }
  hasEventListener(type) { return !!(this._listeners && this._listeners[type] && this._listeners[type].length); }
  dispatchEvent(ev) {
    if (!ev.target) ev.target = this;
    const chain = [];
    let o = this;
    while (o) {
      chain.push(o);
      if (!ev.bubbles) break;
      o = o.parent;
    }
    if (!chain.includes(ev.target)) ev.target = this;
    for (const obj of chain) {
      ev.currentTarget = obj;
      const arr = obj._listeners && obj._listeners[ev.type];
      if (arr) {
        for (const fn of arr.slice()) {
          fn.call(obj, ev);
          if (ev._stop) break;
        }
      }
      if (ev._stop) break;
    }
    ev.currentTarget = null;
    return !ev._stop;
  }
}

// ------------------------------------------------------------------ geometry
export class ColorTransform {
  constructor(rMul = 1, gMul = 1, bMul = 1, aMul = 1, rOff = 0, gOff = 0, bOff = 0, aOff = 0) {
    this.redMultiplier = rMul; this.greenMultiplier = gMul;
    this.blueMultiplier = bMul; this.alphaMultiplier = aMul;
    this.redOffset = rOff; this.greenOffset = gOff;
    this.blueOffset = bOff; this.alphaOffset = aOff;
  }
  set color(v) {
    this.redOffset = (v >> 16) & 255;
    this.greenOffset = (v >> 8) & 255;
    this.blueOffset = v & 255;
  }
  get color() {
    return (this.redOffset << 16) | (this.greenOffset << 8) | this.blueOffset;
  }
}
export class Matrix {
  constructor(a = 1, b = 0, c = 0, d = 1, tx = 0, ty = 0) {
    this.a = a; this.b = b; this.c = c; this.d = d; this.tx = tx; this.ty = ty;
  }
}
export class Transform {
  constructor(obj) { this._obj = obj; this.colorTransform = new ColorTransform(); this.matrix = new Matrix(); }
}

// ------------------------------------------------------------------ display list
let _uid = 1;
export class DisplayObject extends EventDispatcher {
  constructor() {
    super();
    this._id = _uid++;
    this.name = null;
    this.parent = null;
    this.x = 0; this.y = 0;
    this.scaleX = 1; this.scaleY = 1;
    this.rotation = 0;
    this.alpha = 1;
    this.visible = true;
    this.mouseEnabled = true;
    this.mouseChildren = true;
    this.buttonMode = false;
    this.useHandCursor = false;
    this.tabEnabled = true;
    this.tabChildren = true;
    this.cacheAsBitmap = false;
    this.opaqueBackground = null;
    this._transform = new Transform(this);
    this._addedToStage = false;
  }
  get transform() { return this._transform; }
  set transform(t) { this._transform = t; }
  get stage() {
    let o = this;
    while (o.parent) o = o.parent;
    return o instanceof Stage ? o : (o.stageRoot || null);
  }
  get root() { return this.stage; }
  get width() { return this._bounds ? this._bounds[2] * Math.abs(this.scaleX) : 0; }
  set width(v) { if (this._bounds && this._bounds[2]) this.scaleX = v / this._bounds[2]; }
  get height() { return this._bounds ? this._bounds[3] * Math.abs(this.scaleY) : 0; }
  set height(v) { if (this._bounds && this._bounds[3]) this.scaleY = v / this._bounds[3]; }
  get _localBounds() {
    if (this._bounds) return this._bounds;
    return [0, 0, 0, 0];
  }
  localToGlobal(p) {
    const m = this._globalMatrix();
    return { x: m.a * p.x + m.c * p.y + m.tx, y: m.b * p.x + m.d * p.y + m.ty };
  }
  globalToLocal(p) {
    const m = this._globalMatrix();
    const det = m.a * m.d - m.b * m.c || 1;
    const dx = p.x - m.tx, dy = p.y - m.ty;
    return { x: (m.d * dx - m.c * dy) / det, y: (-m.b * dx + m.a * dy) / det };
  }
  _localMatrix() {
    const r = (this.rotation || 0) * Math.PI / 180;
    const cos = Math.cos(r), sin = Math.sin(r);
    const sx = this.scaleX, sy = this.scaleY;
    return { a: cos * sx, b: sin * sx, c: -sin * sy, d: cos * sy, tx: this.x, ty: this.y };
  }
  _globalMatrix() {
    let m = this._localMatrix();
    let o = this.parent;
    while (o) {
      const p = o._localMatrix();
      m = {
        a: m.a * p.a + m.b * p.c, b: m.a * p.b + m.b * p.d,
        c: m.c * p.a + m.d * p.c, d: m.c * p.b + m.d * p.d,
        tx: m.tx * p.a + m.ty * p.c + p.tx,
        ty: m.tx * p.b + m.ty * p.d + p.ty,
      };
      o = o.parent;
    }
    return m;
  }
  _onAddedToStage(stage) {
    if (this._addedToStage) return;
    this._addedToStage = true;
    this.dispatchEvent(new Event(Event.ADDED_TO_STAGE, false));
  }
  _onRemovedFromStage() {
    if (!this._addedToStage) return;
    this._addedToStage = false;
    this.dispatchEvent(new Event(Event.REMOVED_FROM_STAGE, false));
  }
  hitTestPoint(x, y) {
    const p = this.globalToLocal({ x, y });
    const b = this._localBounds;
    return p.x >= b[0] && p.x <= b[0] + b[2] && p.y >= b[1] && p.y <= b[1] + b[3];
  }
  getBounds() { return this._localBounds; }
}

export class DisplayObjectContainer extends DisplayObject {
  constructor() {
    super();
    this.children = [];
  }
  get numChildren() { return this.children.length; }
  addChild(c) {
    if (c.parent) c.parent.removeChild(c);
    c.parent = this;
    this.children.push(c);
    if (this.stage) c._onAddedToStage(this.stage);
    return c;
  }
  addChildAt(c, i) {
    if (c.parent) c.parent.removeChild(c);
    c.parent = this;
    this.children.splice(i, 0, c);
    if (this.stage) c._onAddedToStage(this.stage);
    return c;
  }
  removeChild(c) {
    const i = this.children.indexOf(c);
    if (i >= 0) {
      this.children.splice(i, 1);
      c.parent = null;
      c._onRemovedFromStage();
    }
    return c;
  }
  removeChildAt(i) { const c = this.children[i]; if (c) this.removeChild(c); return c; }
  removeChildren(begin = 0, end = 0x7fffffff) {
    const n = Math.min(end, this.children.length);
    for (let i = n - 1; i >= begin; i--) this.removeChildAt(i);
  }
  getChildAt(i) { return this.children[i] || null; }
  getChildByName(name) { return this.children.find(c => c.name === name) || null; }
  getChildIndex(c) { return this.children.indexOf(c); }
  contains(c) {
    let o = c;
    while (o) { if (o === this) return true; o = o.parent; }
    return false;
  }
  _onAddedToStage(stage) {
    if (this._addedToStage) return;
    this._addedToStage = true;
    this.dispatchEvent(new Event(Event.ADDED_TO_STAGE, false));
    if (this instanceof DisplayObjectContainer)
      for (const c of this.children.slice()) c._onAddedToStage(stage);
  }
  _onRemovedFromStage() {
    if (!this._addedToStage) return;
    this._addedToStage = false;
    this.dispatchEvent(new Event(Event.REMOVED_FROM_STAGE, false));
    if (this instanceof DisplayObjectContainer)
      for (const c of this.children.slice()) c._onRemovedFromStage();
  }
}

export class Stage extends DisplayObjectContainer {
  constructor(w = STAGE_W, h = STAGE_H) {
    super();
    this.stageWidth = w;
    this.stageHeight = h;
    this.frameRate = 60;
    this.focus = null;
  }
  _globalMatrix() { return { a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0 }; }
}

// ------------------------------------------------------------------ MovieClip
/* AssetMovieClips are backed by baked frame textures produced by
 * tools/extract_assets.py.  Timelines (labels, stop scripts, frame sounds and
 * ninja ragdoll anchors) are preserved from the SWF. */
export function disposeDisplayTree(obj) {
  if (!obj) return;
  if (obj instanceof MovieClip) { obj.dispose(); return; }
  if (obj.children) {
    for (const c of obj.children.slice()) disposeDisplayTree(c);
  }
  if (obj.parent) obj.parent.removeChild(obj);
}
globalThis.disposeDisplayTree = disposeDisplayTree;

export class MovieClip extends DisplayObjectContainer {
  constructor(assetName = null) {
    super();
    this.assetName = assetName;
    this.asset = null;
    this.currentFrame = 1;
    this.currentLabel = null;
    this.playing = true;
    this.totalFrames = 1;
    this.framesLoaded = 1;
    this._frameScripts = null;
    this._sounds = null;
    this._labels = null;
    this._frameNumbers = null;
    this.soundTransform = new SoundTransform();
    this._anchors = null;
    this._anchorObjs = null;
    this._soundChannels = new Map();
    this._lastSoundAt = {};
    if (assetName) this._initAsset(assetName);
    MovieClip._all.push(this);
  }
  _initAsset(name) {
    const lib = globalThis.AssetLibrary;
    if (!lib || !lib.sprites[name]) {
      console.warn("missing asset", name);
      return;
    }
    this.asset = lib.sprites[name];
    this.totalFrames = this.asset.frameCount || this.asset.frames.length || 1;
    this.framesLoaded = this.totalFrames;
    this._labels = this.asset.labels || {};
    this._frameScripts = this.asset.scripts || {};
    this._sounds = this.asset.sounds || {};
    this._frameNumbers = this.asset.frameNumbers || null;
    if (this.asset.anchors) {
      this._anchors = this.asset.anchors;
      this._anchorObjs = {};
      for (const nm of ["shoulder", "pelvis", "handR", "handL", "footR", "footL"]) {
        const o = new DisplayObject();
        o.name = nm;
        this._anchorObjs[nm] = o;
        this[nm] = o;
      }
      this._syncAnchors();
      this._updateBounds();
    } else {
      this._updateBounds();
    }
    // run frame-1 scripts (the SWF's asset classes use these to stop)
    this._enterFrame(1);
  }
  _updateBounds() {
    if (!this.asset) { this._bounds = [0, 0, 0, 0]; return; }
    let minx = 1e9, miny = 1e9, maxx = -1e9, maxy = -1e9;
    for (const fr of this.asset.frames) {
      if (!fr) continue;
      minx = Math.min(minx, fr.qx); miny = Math.min(miny, fr.qy);
      maxx = Math.max(maxx, fr.qx + fr.w); maxy = Math.max(maxy, fr.qy + fr.h);
    }
    if (minx > maxx) { minx = miny = maxx = maxy = 0; }
    this._bounds = [minx, miny, maxx - minx, maxy - miny];
  }
  _frameIndex(frame) {
    if (!this.asset || !this.asset.frames) return -1;
    if (this._frameNumbers) {
      const i = this._frameNumbers.indexOf(frame);
      return i;
    }
    return frame - 1;
  }
  get graphicFrame() {
    if (!this.asset) return null;
    const i = this._frameIndex(this.currentFrame);
    return i >= 0 ? (this.asset.frames[i] || null) : null;
  }
  _syncAnchors() {
    if (!this._anchors) return;
    const rec = this._anchors[this.currentFrame - 1] || this._anchors[0] || {};
    for (const nm in this._anchorObjs) {
      const v = rec[nm];
      if (v) { this._anchorObjs[nm].x = v[0]; this._anchorObjs[nm].y = v[1]; }
    }
  }
  _enterFrame(frame) {
    this.currentFrame = frame;
    this.currentLabel = null;
    if (this._labels) {
      for (const [label, f] of Object.entries(this._labels)) {
        if (f === frame) { this.currentLabel = label; break; }
      }
    }
    this._syncAnchors();
    if (this._sounds) {
      const snd = this._sounds[String(frame)];
      if (snd) {
        if (snd.syncStop) {
          const ch = this._soundChannels.get(snd.id);
          if (ch) { ch.stop(); this._soundChannels.delete(snd.id); }
        } else {
          const now = performance.now();
          // A timeline sent to the same frame repeatedly should not stack
          // dozens of copies of the same sound in one instant.
          if (!this._lastSoundAt[snd.id] || now - this._lastSoundAt[snd.id] > 80) {
            this._lastSoundAt[snd.id] = now;
            const ch = AudioSystem.play(snd.id, this.soundTransform.volume,
              snd.loops || 1, !!snd.noMultiple);
            if (ch) this._soundChannels.set(snd.id, ch);
          }
        }
      }
    }
    const script = this._frameScripts && this._frameScripts[String(frame)];
    if (script) {
      if (script === "stop") this.playing = false;
      else if (script.startsWith("gotoAndPlay:")) this.gotoAndPlay(parseInt(script.split(":")[1], 10));
      else if (script.startsWith("gotoAndStop:")) this.gotoAndStop(parseInt(script.split(":")[1], 10));
      else if (script === "play") this.playing = true;
    }
  }
  _resolveFrame(v) {
    if (typeof v === "number") return Math.max(1, Math.min(this.totalFrames, Math.floor(v)));
    if (this._labels && this._labels[v] !== undefined) return this._labels[v];
    // Flash labels can be referenced with strings; fall back to 1
    return 1;
  }
  gotoAndStop(v) {
    const f = this._resolveFrame(v);
    this.playing = false;
    this.currentFrame = f;
    this._enterFrame(f);
  }
  gotoAndPlay(v) {
    const f = this._resolveFrame(v);
    this.playing = true;
    this._enterFrame(f);
  }
  stop() { this.playing = false; }
  play() { this.playing = true; }
  nextFrame() {
    let f = this.currentFrame + 1;
    if (f > this.totalFrames) f = 1;
    this.gotoAndStop(f);
  }
  prevFrame() {
    let f = this.currentFrame - 1;
    if (f < 1) f = this.totalFrames;
    this.gotoAndStop(f);
  }
  advance() {
    for (const ch of this._soundChannels.values()) ch.setVolume(this.soundTransform.volume);
    if (!this.playing || this.totalFrames <= 0) return;
    let f = this.currentFrame + 1;
    if (f > this.totalFrames) f = 1;
    this._enterFrame(f);
  }
  addFrameScript() {}
  dispose() {
    this._alive = false;
    const i = MovieClip._all.indexOf(this);
    if (i >= 0) MovieClip._all.splice(i, 1);
    if (this.parent) this.parent.removeChild(this);
    for (const c of this.children.slice()) c.dispose && c.dispose();
  }
  get framesLoaded_() { return this.framesLoaded; }
}
MovieClip._all = [];
function isAttached(obj) {
  let o = obj;
  while (o.parent) o = o.parent;
  return o instanceof Stage;
}
MovieClip.tickAll = function () {
  for (const mc of MovieClip._all.slice()) {
    if (mc._alive === false) continue;
    if (mc._alwaysTick || isAttached(mc)) mc.advance();
  }
};

// ------------------------------------------------------------------ Sprite / Shape / Graphics
export class Graphics {
  constructor() {
    this.commands = [];
    this.lineWidth = 0;
    this.lineColor = 0;
    this.lineAlpha = 0;
    this.fillColor = null;
    this.fillAlpha = 1;
  }
  clear() { this.commands.length = 0; }
  lineStyle(w, color, alpha = 1) {
    this.lineWidth = w; this.lineColor = color; this.lineAlpha = alpha;
    this.commands.push({ op: "style" });
  }
  lineGradientStyle(...args) { this.commands.push({ op: "style" }); }
  beginFill(color, alpha = 1) { this.fillColor = color; this.fillAlpha = alpha; }
  endFill() { this.fillColor = null; }
  moveTo(x, y) { this.commands.push({ op: "m", x, y }); }
  lineTo(x, y) { this.commands.push({ op: "l", x, y, w: this.lineWidth, c: this.lineColor, a: this.lineAlpha }); }
  curveTo(cx, cy, x, y) { this.commands.push({ op: "q", cx, cy, x, y }); }
  drawRect(x, y, w, h) {
    if (this.fillColor !== null) this.commands.push({ op: "rect", x, y, w, h, c: this.fillColor, a: this.fillAlpha });
    this.commands.push({ op: "rline", x, y, w, h, lw: this.lineWidth, c: this.lineColor, a: this.lineAlpha });
  }
  drawRoundRect(x, y, w, h) { this.drawRect(x, y, w, h); }
  drawCircle(x, y, r) {
    if (this.fillColor !== null) this.commands.push({ op: "circle", x, y, r, c: this.fillColor, a: this.fillAlpha });
    this.commands.push({ op: "cline", x, y, r, lw: this.lineWidth, c: this.lineColor, a: this.lineAlpha });
  }
}
export class Sprite extends DisplayObjectContainer {
  constructor() {
    super();
    this.graphics = new Graphics();
    this.mouseChildren = true;
  }
}
export class Shape extends DisplayObject {
  constructor() { super(); this.graphics = new Graphics(); }
}

// ------------------------------------------------------------------ TextField
export class TextField extends DisplayObject {
  constructor() {
    super();
    this._text = "";
    this._htmlText = "";
    this._textDirty = true;
    this.defaultTextFormat = null;
    this.textColor = 0x000000;
    this.selectable = false;
    this.mouseEnabled = false;
    this.multiline = false;
    this.wordWrap = false;
    this._font = "uni 05_53_8pt_st";
    this._fontSize = 8;
    this._align = "left";
    this._textW = 20;
    this._textH = 10;
    this._texture = null;
    this._canvas = null;
    this._uploaded = false;
    this._bounds = [0, 0, 20, 10];
  }
  get text() { return this._text; }
  set text(t) {
    t = t == null ? "" : String(t);
    if (this._text === t) return;
    this._text = t;
    this._textDirty = true;
  }
  get htmlText() { return this._htmlText; }
  set htmlText(t) { this.text = t == null ? "" : String(t).replace(/<[^>]*>/g, ""); }
  setText(t) { this.text = t; }
  get width() { return this._textW; }
  set width(v) { this._textW = v; this._bounds = [0, 0, v, this._textH]; this._textDirty = true; }
  get height() { return this._textH; }
  set height(v) { this._textH = v; this._bounds = [0, 0, this._textW, v]; this._textDirty = true; }
  _rasterize() {
    const c = this._canvas || (this._canvas = document.createElement("canvas"));
    const w = Math.max(1, Math.ceil(this._textW));
    const h = Math.max(Math.ceil(this._textH), Math.ceil(this._fontSize * 2) + 4);
    c.width = w; c.height = h;
    const g = c.getContext("2d", { willReadFrequently: true });
    g.clearRect(0, 0, w, h);
    g.font = `${this._fontSize}px "${this._font}"`;
    g.textBaseline = "top";
    g.fillStyle = "#" + this.textColor.toString(16).padStart(6, "0");
    const metrics = g.measureText(this.text);
    let tx = 0;
    if (this._align === "center") tx = (w - metrics.width) / 2;
    else if (this._align === "right") tx = w - metrics.width;
    const oy = this._vOffset != null ? this._vOffset : Math.round(this._fontSize * 0.38);
    g.fillText(this.text, Math.round(tx), oy);
    // The embedded UI fonts are pixel fonts.  Canvas antialiasing makes them
    // look blurry when scaled, so threshold the alpha to keep hard pixels.
    const img = g.getImageData(0, 0, w, h);
    const d = img.data;
    for (let i = 3; i < d.length; i += 4) d[i] = d[i] < 128 ? 0 : 255;
    g.putImageData(img, 0, 0);
    this._textDirty = false;
    this._uploaded = false;
  }
  setTextFormat(o) {
    if (!o) return;
    if (o.font) this._font = o.font;
    if (o.size) this._fontSize = o.size;
    if (o.color != null) this.textColor = o.color;
    if (o.align) this._align = o.align;
    this._textDirty = true;
  }
}

// ------------------------------------------------------------------ ByteArray
class ByteArray {
  constructor() {
    this._buf = new Uint8Array(0);
    this.position = 0;
  }
  get length() { return this._buf.length; }
  set length(v) {
    if (v === this._buf.length) return;
    const nb = new Uint8Array(v);
    nb.set(this._buf.subarray(0, Math.min(v, this._buf.length)));
    this._buf = nb;
  }
  get bytesAvailable() { return Math.max(0, this._buf.length - this.position); }
  _ensure(n) {
    if (this.position + n > this._buf.length) {
      const nb = new Uint8Array(this.position + n);
      nb.set(this._buf); this._buf = nb;
    }
  }
  writeByte(v) { this._ensure(1); this._buf[this.position++] = v & 255; }
  writeInt(v) {
    this._ensure(4);
    const u = v >>> 0;
    this._buf[this.position++] = (u >>> 24) & 255;
    this._buf[this.position++] = (u >>> 16) & 255;
    this._buf[this.position++] = (u >>> 8) & 255;
    this._buf[this.position++] = u & 255;
  }
  writeShort(v) {
    this._ensure(2);
    this._buf[this.position++] = (v >> 8) & 255;
    this._buf[this.position++] = v & 255;
  }
  readByte() { return (this._buf[this.position++] << 24) >> 24; }
  readUnsignedByte() { return this._buf[this.position++]; }
  readUnsignedShort() {
    const v = (this._buf[this.position] << 8) | this._buf[this.position + 1];
    this.position += 2; return v;
  }
  readShort() {
    let v = (this._buf[this.position] << 8) | this._buf[this.position + 1];
    this.position += 2;
    return v & 0x8000 ? v - 0x10000 : v;
  }
  readInt() {
    const b = this._buf, p = this.position; this.position += 4;
    return (b[p] << 24) | (b[p + 1] << 16) | (b[p + 2] << 8) | b[p + 3];
  }
  readUnsignedInt() { return this.readInt() >>> 0; }
  readFloat() {
    const b = this._buf, p = this.position; this.position += 4;
    const u = new Uint8Array([b[p], b[p + 1], b[p + 2], b[p + 3]]);
    return new DataView(u.buffer).getFloat32(0, false);
  }
  readUTF() {
    const n = this.readUnsignedShort();
    const bytes = this._buf.slice(this.position, this.position + n);
    this.position += n;
    return new TextDecoder("utf-8").decode(bytes);
  }
  readUTFBytes(n) {
    const bytes = this._buf.slice(this.position, this.position + n);
    this.position += n;
    return new TextDecoder("utf-8").decode(bytes);
  }
  writeUTF(s) {
    const b = new TextEncoder().encode(s);
    this.writeShort(b.length);
    this._ensure(b.length); this._buf.set(b, this.position); this.position += b.length;
  }
  readBytes(dest, offset = 0, len = 0) {
    const n = len > 0 ? Math.min(len, this.bytesAvailable) : this.bytesAvailable;
    if (!dest) { this.position += n; return; }
    if (dest instanceof ByteArray) {
      dest._ensure(dest.position + n);
      dest._buf.set(this._buf.subarray(this.position, this.position + n), dest.position);
      dest.position += n;
    }
    this.position += n;
  }
  writeBytes(src, offset = 0, len = 0) {
    const n = len > 0 ? len : src.length;
    this._ensure(n);
    const data = src instanceof ByteArray ? src._buf : src;
    this._buf.set(data.subarray(offset, offset + n), this.position);
    this.position += n;
  }
  toString() { return new TextDecoder("latin1").decode(this._buf); }
  static fromBase64(b64) {
    const bin = atob(b64);
    const ba = new ByteArray();
    ba._buf = new Uint8Array(bin.length);
    for (let i = 0; i < bin.length; i++) ba._buf[i] = bin.charCodeAt(i);
    return ba;
  }
}
export { ByteArray };

// ------------------------------------------------------------------ SharedObject
export class SharedObject {
  constructor(key) {
    this._key = key;
    let data = {};
    try { data = JSON.parse(localStorage.getItem(key) || "{}"); } catch (e) { data = {}; }
    this.data = data;
  }
  setProperty(k, v) { this.data[k] = v; }
  flush() { try { localStorage.setItem(this._key, JSON.stringify(this.data)); } catch (e) {} }
  static getLocal(name) { return new SharedObject(name); }
}
globalThis.SharedObject = SharedObject;

// ------------------------------------------------------------------ sounds
export class SoundTransform {
  constructor(volume = 1, pan = 0) { this.volume = volume; this.pan = pan; }
}
export class SoundChannel {
  constructor(source, gain = null) { this._source = source; this._gain = gain; }
  setVolume(v) { if (this._gain) this._gain.gain.value = v * SoundMixer.soundTransform.volume; }
  stop() {
    if (this._source) { try { this._source.stop(); } catch (e) {} this._source = null; }
  }
}
export class Sound {
  constructor(buffer) { this._buffer = buffer; }
  play(startTime = 0, loops = 0, transform = null) {
    return AudioSystem.playBuffer(this._buffer, transform ? transform.volume : 1);
  }
}
export class SoundMixer {
  static soundTransform = new SoundTransform(1);
}
export const AudioSystem = {
  ctx: null,
  master: null,
  buffers: {},
  async init() {
    if (this.ctx) return;
    const AC = window.AudioContext || window.webkitAudioContext;
    this.ctx = new AC();
    this.master = this.ctx.createGain();
    this.master.connect(this.ctx.destination);
    this.master.gain.value = 1;
  },
  async load(id, url) {
    if (!this.ctx) await this.init();
    const res = await fetch(url);
    const data = await res.arrayBuffer();
    this.buffers[id] = await this.ctx.decodeAudioData(data);
  },
  play(id, volume = 1, loops = 1, noMultiple = false) {
    if (!this.ctx) return null;
    const buf = this.buffers[id];
    if (!buf) return null;
    this._noMultipleActive = this._noMultipleActive || new Set();
    if (noMultiple && this._noMultipleActive.has(id)) return null;
    const src = this.ctx.createBufferSource();
    src.buffer = buf;
    if (loops > 1) {
      src.loop = true;
      if (loops < 32000) src.stop(this.ctx.currentTime + buf.duration * loops);
    }
    const g = this.ctx.createGain();
    g.gain.value = volume * (SoundMixer.soundTransform.volume);
    src.connect(g); g.connect(this.master);
    this._active = this._active || [];
    this._active.push(src);
    if (noMultiple) this._noMultipleActive.add(id);
    src.onended = () => {
      const i = this._active.indexOf(src); if (i >= 0) this._active.splice(i, 1);
      if (noMultiple) this._noMultipleActive.delete(id);
    };
    src.start();
    return new SoundChannel(src, g);
  },
  playLoop(id, volume = 1) {
    if (!this.ctx) return null;
    const buf = this.buffers[id];
    if (!buf) return null;
    const src = this.ctx.createBufferSource();
    src.buffer = buf; src.loop = true;
    const g = this.ctx.createGain();
    g.gain.value = volume * SoundMixer.soundTransform.volume;
    src.connect(g); g.connect(this.master);
    this._active = this._active || [];
    this._active.push(src);
    src.start();
    return new SoundChannel(src, g);
  },
  playBuffer(buf, volume) {
    if (!this.ctx || !buf) return null;
    const src = this.ctx.createBufferSource();
    src.buffer = buf;
    const g = this.ctx.createGain();
    g.gain.value = volume * (SoundMixer.soundTransform.volume);
    src.connect(g); g.connect(this.master);
    this._active = this._active || [];
    this._active.push(src);
    src.onended = () => { const i = this._active.indexOf(src); if (i >= 0) this._active.splice(i, 1); };
    src.start();
    return new SoundChannel(src, g);
  },
  resume() { if (this.ctx && this.ctx.state === "suspended") this.ctx.resume(); },
  stopAll() {
    if (!this.ctx) return;
    for (const src of this._active || []) { try { src.stop(); } catch (e) {} }
    this._active = [];
    this._noMultipleActive = new Set();
  },
};

// keep a global for the ported AS3 code
globalThis.ByteArray = ByteArray;
globalThis.MovieClip = MovieClip;
globalThis.Sprite = Sprite;
globalThis.Shape = Shape;
globalThis.TextField = TextField;
globalThis.ColorTransform = ColorTransform;
globalThis.SoundTransform = SoundTransform;
globalThis.Sound = Sound;
globalThis.SoundChannel = SoundChannel;
globalThis.SoundMixer = SoundMixer;
globalThis.AudioSystem = AudioSystem;
globalThis.Keyboard = Keyboard;
globalThis.getTimer = getTimer;
globalThis.Event = Event;
globalThis.MouseEvent = MouseEvent;
globalThis.KeyboardEvent = KeyboardEvent;
globalThis.KeyboardFocusEvent = KeyboardFocusEvent;
globalThis.EventDispatcher = EventDispatcher;
globalThis.DisplayObject = DisplayObject;
globalThis.DisplayObjectContainer = DisplayObjectContainer;
globalThis.Graphics = Graphics;
