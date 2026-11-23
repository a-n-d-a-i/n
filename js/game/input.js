/* Literal port of simpleFramework/SimpleInput.as, ui/PlayerKeys, ui/GlobalKeys
 * and simulation/inputsource/*.as */
import { ByteArray, Keyboard } from "../flash.js";

export class PlayerKeys {
  static JUMP = 0; static LEFT = 1; static RIGHT = 2; static SUICIDE = 3;
  static NUMBER_OF_PLAYER_KEYS = 4; static MAX_NUMBER_OF_PLAYERS = 4;
  constructor() { this._playerBindings = new Array(16).fill(0); }
  bindActionKeyForPlayer(action, key, player) { this._playerBindings[player * 4 + action] = key; }
  getActionKeyForPlayer(action, player) { return this._playerBindings[player * 4 + action]; }
  getActions(actions) {
    const out = [];
    for (let p = 0; p < 4; p++) for (const a of actions) out.push(this.getActionKeyForPlayer(a, p));
    return out;
  }
  get keyConfigString() { return this._playerBindings.join(","); }
  set keyConfigString(v) {
    const a = String(v).split(",");
    for (let i = 0; i < a.length; i++) this._playerBindings[i] = Number(a[i]);
  }
}

export class GlobalKeys {
  constructor() {
    this.up = 38; this.down = 40; this.left = 37; this.right = 39;
    this.select = 90; this.back = 27; this.pause = 80; this.quit = 81;
  }
}

export class SimpleInput {
  constructor(root) {
    this.root = root;
    this.xmouse = 0; this.ymouse = 0;
    this.mouseWasDown = false; this.mouseIsDown = false;
    this.stateDown = false; this.statePressed = false; this.stateReleased = false;
    this.posx = 0; this.posy = 0; this.oldx = 0; this.oldy = 0;
    this.downposx = 0; this.downposy = 0; this.upposx = 0; this.upposy = 0;
    this.keys = new Array(256).fill(false);
    this.oldkeys = new Array(256).fill(false);
    this.keytriggers = new Array(256).fill(0);
    root.addEventListener("mouseMove", e => { this.xmouse = e.stageX; this.ymouse = e.stageY; });
    root.addEventListener("mouseDown", e => { this.mouseIsDown = true; });
    root.addEventListener("mouseUp", e => { this.mouseIsDown = false; });
    root.addEventListener("keyDown", e => {
      this.keys[e.keyCode] = true;
      this.keys[Keyboard.CONTROL] = e.ctrlKey;
      if (e.keyCode === Keyboard.CAPS_LOCK) Keyboard.capsLock = !Keyboard.capsLock;
    });
    root.addEventListener("keyUp", e => { this.keys[e.keyCode] = false; });
    this.Tick(); this.Tick();
  }
  Tick() {
    for (let i = 0; i < this.keytriggers.length; i++) this.keytriggers[i] = 0;
    this.oldx = this.posx; this.oldy = this.posy;
    this.stateDown = false; this.statePressed = false; this.stateReleased = false;
    if (this.mouseIsDown) {
      this.stateDown = true;
      if (!this.mouseWasDown) {
        this.statePressed = true;
        this.downposx = this.xmouse; this.downposy = this.ymouse;
      }
    } else if (this.mouseWasDown) {
      this.stateReleased = true;
      this.upposx = this.xmouse; this.upposy = this.ymouse;
    }
    this.mouseWasDown = this.mouseIsDown;
    this.posx = this.xmouse; this.posy = this.ymouse;
    for (let i = 0; i < this.keys.length; i++) {
      if (this.IsKeyDown(i)) {
        if (!this.oldkeys[i]) this.keytriggers[i] = 1;
      } else if (this.oldkeys[i]) this.keytriggers[i] = -1;
    }
    for (let i = 0; i < this.oldkeys.length; i++) this.oldkeys[i] = this.keys[i];
  }
  GetMousePos() { return { x: this.xmouse, y: this.ymouse }; }
  GetMousePos_Down() { return { x: this.downposx, y: this.downposy }; }
  GetMousePos_Up() { return { x: this.upposx, y: this.upposy }; }
  GetMouseVel() { return { x: this.posx - this.oldx, y: this.posy - this.oldy }; }
  IsMouseDown() { return this.stateDown; }
  IsMousePressed() { return this.statePressed; }
  IsMouseReleased() { return this.stateReleased; }
  IsKeyDown(k) { return this.keys[k]; }
  IsOnePressed(list) { for (const k of list) if (this.keytriggers[k] > 0) return true; return false; }
  IsKeyPressed(k) { return this.keytriggers[k] > 0; }
  IsKeyReleased(k) { return this.keytriggers[k] < 0; }
  IsAnyKeyPressed() { return this.keytriggers.indexOf(1) !== -1; }
  CapsLock() { return Keyboard.capsLock; }
}

export class InputSource_Base {
  static bit_J = 1; static bit_L = 2; static bit_R = 4;
  constructor(frames) {
    this.frames = frames;
    this.current_J = false; this.current_L = false; this.current_R = false;
  }
  DumpFrames() {
    this.frames.position = this.frames.length - 1;
    while (this.frames.position >= 0) {
      if (this.frames.readByte() !== 0) break;
      this.frames.position -= 2;
    }
    const last = this.frames.position;
    const out = new ByteArray();
    out.position = 0;
    this.frames.position = 0;
    for (let i = 0; i <= last; i++) out.writeByte(this.frames.readByte());
    return out;
  }
  DumpString() {
    const bytes = this.frames;
    let s = "";
    const hex = "0123456789abcdef";
    bytes.position = 0;
    while (bytes.bytesAvailable) {
      let b = bytes.readUnsignedByte();
      s += hex[b % 16]; b >>= 4; s += hex[b % 16];
    }
    bytes.position = 0;
    let end = s.length - 1;
    while (s.charAt(end) === "0" && end > 0) end--;
    return s.substring(0, end);
  }
  IsReplayFinished() { return false; }
  Tick() {}
  IsButtonDown_Jump() { return this.current_J; }
  IsButtonDown_Left() { return this.current_L; }
  IsButtonDown_Right() { return this.current_R; }
}

export class InputSource_Recorder extends InputSource_Base {
  constructor(input, kj, kl, kr) {
    const ba = new ByteArray();
    ba.length = 4096;
    super(ba);
    this.input = input; this.keycode_J = kj; this.keycode_L = kl; this.keycode_R = kr;
  }
  Tick(frame) {
    this.current_J = this.input.IsKeyDown(this.keycode_J);
    this.current_L = this.input.IsKeyDown(this.keycode_L);
    this.current_R = this.input.IsKeyDown(this.keycode_R);
    if (frame >= this.frames.length) this.frames.length = frame * 2;
    let bits = 0;
    if (this.current_J) bits |= 1;
    if (this.current_L) bits |= 2;
    if (this.current_R) bits |= 4;
    this.frames.position = frame;
    this.frames.writeByte(bits);
  }
}

export class InputSource_Playback extends InputSource_Base {
  constructor(ba) { super(ba); this.is_finished = false; }
  IsReplayFinished() { return this.is_finished; }
  Tick(frame) {
    if (frame >= this.frames.length) {
      this.current_J = false; this.current_L = false; this.current_R = false;
      this.is_finished = true;
    } else {
      this.frames.position = frame;
      const bits = this.frames.readByte();
      this.current_J = (bits & 1) > 0;
      this.current_L = (bits & 2) > 0;
      this.current_R = (bits & 4) > 0;
    }
  }
}
