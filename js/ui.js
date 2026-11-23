/* Ported UI classes.  These mirror the SWF's screen classes and mediators,
 * using the baked screen artwork exported by tools/extract_assets.py. */
import {
  Sprite, MovieClip, TextField, Shape, DisplayObject, Keyboard, ByteArray,
  MouseEvent, KeyboardFocusEvent, Event, ColorTransform,
} from "./flash.js";
import { clip } from "./assets.js";
import { TimeFormatter, SavedProperties } from "./game/data.js";
import { Editor_State } from "./game/editorstate.js";
import { PlayerKeys } from "./game/input.js";

const timeFormatter = new TimeFormatter();

/* A one-frame bitmap display object backed by an atlas shape. */
export class StaticImage extends DisplayObject {
  constructor(meta) {
    super();
    this._imageMeta = meta;
    if (meta) this._bounds = [meta.qx, meta.qy, meta.w, meta.h];
    this.mouseEnabled = false;
  }
}

/* Key display names, ported from com.metanet.ui.KeyNames. */
export class KeyNames {
  constructor() {
    this._keyNames = [];
    this._mapRange(48, 90);
    this._mapRange(96, 111, -48, "Num ");
    this._mapRange(219, 222);
    this._keyNames[188] = "<";
    this._keyNames[190] = ">";
    const K = Keyboard;
    this._keyNames[K.SPACE] = "space";
    this._keyNames[K.LEFT] = "left";
    this._keyNames[K.RIGHT] = "right";
    this._keyNames[K.UP] = "up";
    this._keyNames[K.DOWN] = "down";
    this._keyNames[K.SHIFT] = "shift";
    this._keyNames[K.ESCAPE] = "escape";
    this._keyNames[K.CONTROL] = "control";
    this._keyNames[K.BACKSPACE] = "backspace";
    this._keyNames[K.DELETE] = "delete";
    this._keyNames[K.BACKQUOTE] = "`";
    this._keyNames[K.BACKSLASH] = "\\";
    this._keyNames[K.COMMA] = ",";
    this._keyNames[K.PERIOD] = ".";
    this._keyNames[K.SLASH] = "/";
    this._keyNames[K.SEMICOLON] = ";";
    this._keyNames[K.QUOTE] = "'";
    this._keyNames[K.ENTER] = "enter";
    this._keyNames[K.MINUS] = "-";
    this._keyNames[K.EQUAL] = "=";
    this._keyNames[K.HOME] = "home";
    this._keyNames[K.END] = "end";
    this._keyNames[K.PAGE_DOWN] = "pgdn";
    this._keyNames[K.PAGE_UP] = "pgup";
    this._keyNames[K.LEFTBRACKET] = "[";
    this._keyNames[K.RIGHTBRACKET] = "]";
  }
  _mapRange(from, to, offset = 0, prefix = "") {
    for (let i = from; i <= to; i++)
      this._keyNames[i] = prefix + String.fromCharCode(i + offset).toLowerCase();
  }
  getName(code) {
    const n = this._keyNames[code];
    return n == null ? "?" : n;
  }
}

/* ------------------------------------------------------------------ buttons */
export class BasicButton extends MovieClip {
  constructor(assetName) {
    super(assetName);
    this.mouseChildren = false;
    this.buttonMode = true;
    this.useHandCursor = true;
    this._selected = false;
    this._mouseOver = false;
    this._mouseDown = false;
    this.addEventListener(MouseEvent.MOUSE_OVER, () => { this._mouseOver = true; this.updateVisualState(); });
    this.addEventListener(MouseEvent.MOUSE_OUT, () => { this._mouseOver = false; this.updateVisualState(); });
    this.addEventListener(MouseEvent.MOUSE_DOWN, () => { this._mouseDown = true; this.updateVisualState(); });
    this.addEventListener(MouseEvent.MOUSE_UP, () => { this._mouseDown = false; this.updateVisualState(); });
    this.addEventListener(KeyboardFocusEvent.FOCUS_IN, () => { this._selected = true; this.updateVisualState(); });
    this.addEventListener(KeyboardFocusEvent.FOCUS_OUT, () => { this._selected = false; this.updateVisualState(); });
    this.updateVisualState();
  }
  updateVisualState() {
    if (this._mouseDown) this.gotoAndStop(1);
    if (this._mouseOver || this._selected) this.gotoAndStop(2);
    else this.gotoAndStop(1);
  }
  get selected() { return this._selected; }
  set selected(v) { this._selected = v; this.updateVisualState(); }
  destroy() { if (this.parent) this.parent.removeChild(this); }
}

/* BasicButton with a dynamic caption (com.metanet.ui.DynamicButton).  The SWF
 * places the label (txtLabel) at (259,40) twips inside every key-binding
 * symbol, with a centred 8pt field 36x20.5 px. */
export class DynamicButton extends BasicButton {
  constructor(assetName) {
    super(assetName);
    this.label = new TextField();
    this.label._font = "uni 05_53_8pt_st";
    this.label._fontSize = 8;
    this.label.textColor = 0x000000;
    this.label._align = "center";
    this.label._textW = 36;
    this.label._textH = 21;
    this.label._bounds = [0, 0, 36, 21];
    this.label.x = 12.95; this.label.y = 2;
    this.addChild(this.label);
  }
  get text() { return this.label.text; }
  set text(t) { this.label.text = t == null ? "" : t; }
}

/* Episode button: background art comes from the two background-only symbols
 * (the original button's label is dynamic text, so we draw it ourselves). */
export class EpisodeButton extends Sprite {
  constructor(label, beaten) {
    super();
    this._bounds = [-10, -10, 20, 20];
    this.mouseChildren = false;
    this.buttonMode = true;
    this.useHandCursor = true;
    this._selected = false;
    this._mouseOver = false;
    this._mouseDown = false;
    this.bgUp = new MovieClip("asset_ui_episodebutton_bg");
    this.bgUp.scaleX = this.bgUp.scaleY = 0.8333435;
    this.bgUp.gotoAndStop(1);
    this.bgOver = new MovieClip("asset_ui_episodebutton_bg_over");
    this.bgOver.scaleX = this.bgOver.scaleY = 0.8333435;
    this.bgOver.gotoAndStop(1);
    this.bgOver.visible = false;
    this.addChild(this.bgUp);
    this.addChild(this.bgOver);
    this.beatenMark = null;
    if (beaten && globalThis.AssetLibrary) {
      this.beatenMark = new StaticImage(globalThis.AssetLibrary.shapes["asset_ui_beaten_check"]);
      this.addChild(this.beatenMark);
    }
    this.label = new TextField();
    this.label._font = "uni 05_53_8pt_st";
    this.label._fontSize = 8;
    this.label.textColor = 0x000000;
    this.label._align = "center";
    this.label._textW = 20;
    this.label._textH = 12;
    this.label._bounds = [-10, 0, 20, 12];
    this.label.x = -10; this.label.y = -7;
    this.label.text = label || "";
    this.addChild(this.label);
    this.addEventListener(MouseEvent.MOUSE_OVER, () => { this._mouseOver = true; this.updateVisualState(); });
    this.addEventListener(MouseEvent.MOUSE_OUT, () => { this._mouseOver = false; this.updateVisualState(); });
    this.addEventListener(MouseEvent.MOUSE_DOWN, () => { this._mouseDown = true; this.updateVisualState(); });
    this.addEventListener(MouseEvent.MOUSE_UP, () => { this._mouseDown = false; this.updateVisualState(); });
    this.addEventListener(KeyboardFocusEvent.FOCUS_IN, () => { this._selected = true; this.updateVisualState(); });
    this.addEventListener(KeyboardFocusEvent.FOCUS_OUT, () => { this._selected = false; this.updateVisualState(); });
  }
  updateVisualState() {
    const lit = this._mouseOver || this._selected;
    this.bgOver.visible = lit;
    this.bgUp.visible = !lit;
  }
  get selected() { return this._selected; }
  set selected(v) { this._selected = v; this.updateVisualState(); }
  set text(t) { this.label.text = t == null ? "" : t; }
  get text() { return this.label.text; }
}

/* ------------------------------------------------------------------ keyboard nav */
export class KeyboardNavigator {
  static UP = 0; static LEFT = 1; static RIGHT = 2; static DOWN = 4;
  constructor() {
    this._mapping = null;
    this._map = new Map();
    this._focus = null;
    this._directions = [];
    this._return = null;
  }
  useMapping(k) {
    this._mapping = k;
    this._directions[0] = k.up; this._directions[1] = k.left;
    this._directions[2] = k.right; this._directions[4] = k.down;
  }
  clearNavigation() { this._map.clear(); }
  addEntryPoint(dir, obj) { this.addNavigationOption(dir, null, obj); }
  addHorizontalLoop(arr) {
    for (let i = 0; i < arr.length - 1; i++) this.connectHorizontally(arr[i], arr[i + 1]);
    this.connectHorizontally(arr[arr.length - 1], arr[0]);
  }
  addVerticalLoop(arr) {
    for (let i = 0; i < arr.length - 1; i++) this.connectVertically(arr[i], arr[i + 1]);
    this.connectVertically(arr[arr.length - 1], arr[0]);
  }
  connectHorizontally(a, b) { this.addNavigationOption(1, b, a); this.addNavigationOption(2, a, b); }
  connectVertically(a, b) { this.addNavigationOption(4, a, b); this.addNavigationOption(0, b, a); }
  addNavigationOption(dir, from, to) {
    let m = this._map.get(from);
    if (!m) { m = []; this._map.set(from, m); }
    m[dir] = to;
  }
  setReturnButton(b) { this._return = b; }
  setFocus(o) {
    if (this._focus === o) return;
    if (this._focus) this._focus.dispatchEvent(new KeyboardFocusEvent(KeyboardFocusEvent.FOCUS_OUT, false));
    this._focus = o;
    if (o) o.dispatchEvent(new KeyboardFocusEvent(KeyboardFocusEvent.FOCUS_IN, false));
  }
  navigate(code) {
    if (this._mapping && code === this._mapping.select && this._focus) {
      this._focus.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
      this._focus.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
      this._focus.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
      return;
    }
    if (this._mapping && code === this._mapping.back && this._return) {
      this._return.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
      this._return.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
      this._return.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
      return;
    }
    const dir = this._directions.indexOf(code);
    if (dir === -1) return;
    const m = this._map.get(this._focus);
    if (m && m[dir]) this.setFocus(m[dir]);
  }
}

/* ------------------------------------------------------------------ menu */
export class MenuScreen extends Sprite {
  constructor(app) {
    super();
    this.app = app;
    const A = globalThis.AssetLibrary;
    this._buttons = [];
    const addButton = (asset, x, y, action, visible = true) => {
      const b = new BasicButton(asset);
      b.x = x; b.y = y;
      b.visible = visible;
      if (action) b.addEventListener(MouseEvent.CLICK, action);
      this.addChild(b);
      this._buttons.push(b);
      return b;
    };
    this.settings = addButton("asset_ui_menu_settings", 659, 364, () => this.app.showSettings());
    this.help = addButton("asset_ui_menu_help", 663, 265, () => this.app.showHelp());
    this.story = addButton("asset_ui_menu_story", 658, 444, () => this.app.showStory());
    this.credits = addButton("asset_ui_menu_credits", 664, 404, () => this.app.showCredits());
    this.episodes = addButton("asset_ui_menu_episodes", 569, 201, () => this.app.showEpisodes());
    this.userLevels = addButton("asset_ui_menu_userlevels", 656, 225, null, false);
    this.resume = addButton("asset_ui_menu_resume", 504, 148, () => this.app.resumeSaved());
    const hasSave = app.sharedObject.data.hasOwnProperty(SavedProperties.SAVED_EPISODE) ||
                    app.sharedObject.data.hasOwnProperty(SavedProperties.SAVED_CHALLENGE);
    this.resume.visible = hasSave;

    // Online-only widgets from the original menu are intentionally disabled.
    // NOT IMPLEMENTED: account login / user levels (network backed).
    this.loginPrompt = new MovieClip("asset_ui_menu_login");
    this.loginPrompt.x = 27; this.loginPrompt.y = 441;
    this.loginPrompt.visible = false;
    this.addChild(this.loginPrompt);
    this.kong_logo = new MovieClip("asset_ui_menu_kong");
    this.kong_logo.x = 30; this.kong_logo.y = 544;
    this.kong_logo.visible = false;
    this.addChild(this.kong_logo);
    // NOT IMPLEMENTED: NewsTicker fetched news.xml from the Metanet bucket.
    // This is the static ticker backdrop only.
    this.news = new MovieClip("asset_ui_menu_news");
    this.news.x = 0; this.news.y = 574.6;
    this.addChild(this.news);
    this.logo = new MovieClip("asset_ui_menu_logo");
    this.logo.x = 661; this.logo.y = -73;
    this.addChild(this.logo);
    this.metanet = new BasicButton("asset_ui_menu_metanet");
    this.metanet.x = 707; this.metanet.y = 529;
    // NOT IMPLEMENTED: external website links are disabled in this offline build.
    this.metanet.mouseEnabled = false;
    this.metanet.buttonMode = false;
    this.addChild(this.metanet);

    this.navList = [this.resume, this.episodes, this.help, this.settings, this.credits, this.story]
      .filter(b => b.visible);
    this.navIndex = this.navList.indexOf(this.episodes);
    this.updateFocus();
  }
  updateFocus() {
    for (let i = 0; i < this.navList.length; i++) this.navList[i].selected = i === this.navIndex;
  }
  handleKey(code) {
    const g = this.app.globalKeys;
    if (code === g.down || code === g.right) {
      this.navIndex = (this.navIndex + 1) % this.navList.length; this.updateFocus();
    } else if (code === g.up || code === g.left) {
      this.navIndex = (this.navIndex - 1 + this.navList.length) % this.navList.length; this.updateFocus();
    } else if (code === g.select) {
      const b = this.navList[this.navIndex];
      b.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
    }
  }
  destroy() { this.app.removeScreen(this); }
}

/* ------------------------------------------------------------------ episodes */
export class EpisodesScreen extends Sprite {
  constructor(app) {
    super();
    this.app = app;
    this.baked = new MovieClip("asset_ui_episodes");
    this.addChild(this.baked);
    this.returnButton = new BasicButton("asset_ui_return");
    this.returnButton.x = 666; this.returnButton.y = 549;
    this.returnButton.addEventListener(MouseEvent.CLICK, () => this.app.showMainMenu());
    this.addChild(this.returnButton);
    this.grid = new Sprite();
    this.grid.x = 32; this.grid.y = 93;
    this.addChild(this.grid);
    this.thumbnails = new Sprite();
    this.thumbnails.x = 496; this.thumbnails.y = 79;
    this.thumbnails._bounds = [0, 0, 264, 450];
    this.addChild(this.thumbnails);
    // DropInIndicator (SWF symbol 21): toggles local 2-player mode with N.
    this.dropIn = new TextField();
    this.dropIn._font = "uni 05_53_16pt_st";
    this.dropIn._fontSize = 16;
    this.dropIn.textColor = 0x000000;
    this.dropIn._textW = 505;
    this.dropIn._textH = 24;
    this.dropIn._bounds = [0, 0, 505, 24];
    this.dropIn.x = 32; this.dropIn.y = 547;
    this.addChild(this.dropIn);
    this.updateDropIn();
    this._cells = new Map(); // "col,row" -> EpisodeButton
    this._arcade = [];
    this.createButtons();
    // focus the last unlocked episode
    let last = 0;
    for (let i = 0; i < 120; i++) if (app.episodes.isUnlocked(i)) last = i;
    this.focusCol = Math.floor(last / 10);
    this.focusRow = last % 10;
    if (!this._cells.has(this.focusCol + "," + this.focusRow)) {
      this.focusCol = 0; this.focusRow = 0;
    }
    this.updateFocus();
    if (this.getFocusButton()) this.showThumbnails(this.focusCol * 10 + this.focusRow);
  }
  createButtons() {
    const MARGIN = 30, SIZE = 20, ROWGAP = 20, COLGAP = 20;
    for (let i = 0; i < this.app.episodes.numberOfSets; i++) {
      const col = Math.floor(i / 10);
      const row = i % 10;
      const unlocked = this.app.episodes.isUnlocked(i);
      const beaten = this.app.episodes.isBeaten(i);
      const b = new EpisodeButton(unlocked ? this.app.episodes.getEpisodeLabelFor(i) : "", beaten);
      b.x = MARGIN + col * (SIZE + COLGAP);
      b.y = MARGIN + row * (SIZE + ROWGAP);
      b.mouseEnabled = unlocked;
      b.addEventListener(MouseEvent.CLICK, () => {
        if (this.app.episodes.isUnlocked(i)) this.app.startEpisode(i);
      });
      b.addEventListener(MouseEvent.MOUSE_OVER, () => { if (unlocked) this.showThumbnails(i); });
      this.grid.addChild(b);
      this._cells.set(col + "," + row, b);
    }
    for (let col = 0; col < 12; col++) {
      if (!this.app.episodes.isRangeBeaten(col * 10, col * 10 + 9)) continue;
      let label = "a-" + col;
      if (col === 10) label = "a-a";
      if (col === 11) label = "a-b";
      const b = new EpisodeButton(label, false);
      b.x = MARGIN + col * (SIZE + COLGAP);
      b.y = MARGIN + 10 * (SIZE + ROWGAP);
      b.addEventListener(MouseEvent.CLICK, () => this.app.startChallenge(col));
      b.addEventListener(MouseEvent.MOUSE_OVER, () => this.thumbnails.removeChildren(0));
      this.grid.addChild(b);
      this._cells.set(col + ",10", b);
      this._arcade[col] = b;
    }
  }
  getFocusButton() { return this._cells.get(this.focusCol + "," + this.focusRow); }
  updateDropIn() {
    const key = new KeyNames().getName(
      this.app.coopKeys.getActionKeyForPlayer(PlayerKeys.JUMP, 1));
    this.dropIn.text = this.app.options.coopMode
      ? "2 Player Mode. High scores will not be recorded. Press '" + key + "' to return to 1 Player Mode"
      : "1 Player Mode. Press '" + key + "' to switch to 2 Player Mode";
  }
  toggleCoop() {
    this.app.options.coopMode = !this.app.options.coopMode;
    this.updateDropIn();
  }
  updateFocus() {
    for (const b of this._cells.values()) b.selected = false;
    const b = this.getFocusButton();
    if (b) b.selected = true;
  }
  showThumbnails(episode) {
    this.thumbnails.removeChildren(0);
    if (episode < 0) return;
    for (let lvl = 0; lvl < 5; lvl++) {
      const ba = this.app.episodes.getLevel(episode, lvl);
      ba.readUTF();
      const body = new ByteArray();
      ba.readBytes(body);
      const st = Editor_State.Load_From_Bytes(body);
      const tv = new ThumbnailView(st);
      tv.x = (this.thumbnails.width - 132) / 2;
      tv.y = lvl * (this.thumbnails.height / 5);
      this.thumbnails.addChild(tv);
    }
  }
  moveFocus(dx, dy) {
    const cols = 12, rows = 11;
    let c = this.focusCol, r = this.focusRow;
    for (let step = 0; step < 24; step++) {
      c = (c + dx + cols) % cols;
      r = (r + dy + rows) % rows;
      if (this._cells.has(c + "," + r)) {
        const b = this._cells.get(c + "," + r);
        if (b.mouseEnabled || r === 10) { this.focusCol = c; this.focusRow = r; break; }
      }
      if (dx === 0 && dy === 0) break;
    }
    this.updateFocus();
    if (this.focusRow !== 10) this.showThumbnails(this.focusCol * 10 + this.focusRow);
  }
  handleKey(code) {
    const g = this.app.globalKeys;
    // DropInMediator listens for the co-op player 2 jump key.
    if (code === this.app.coopKeys.getActionKeyForPlayer(PlayerKeys.JUMP, 1)) this.toggleCoop();
    else if (code === g.left) this.moveFocus(-1, 0);
    else if (code === g.right) this.moveFocus(1, 0);
    else if (code === g.up) this.moveFocus(0, -1);
    else if (code === g.down) this.moveFocus(0, 1);
    else if (code === g.select) {
      const b = this.getFocusButton();
      if (b) b.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
    } else if (code === g.back) this.app.showMainMenu();
  }
  destroy() { this.app.removeScreen(this); }
}

/* ------------------------------------------------------------------ static screens */
class SimpleScreen extends Sprite {
  constructor(app, asset, returnAction) {
    super();
    this.app = app;
    this.baked = new MovieClip(asset);
    this.addChild(this.baked);
    this.returnButton = new BasicButton("asset_ui_return");
    this.returnButton.x = 666; this.returnButton.y = 549;
    this.returnButton.addEventListener(MouseEvent.CLICK, returnAction);
    this.addChild(this.returnButton);
  }
  handleKey(code) {
    const g = this.app.globalKeys;
    if (code === g.back || code === g.select) {
      this.returnButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
    }
  }
  destroy() { this.app.removeScreen(this); }
}
export class HelpScreen extends SimpleScreen {
  constructor(app) { super(app, "asset_ui_help", () => app.showMainMenu()); }
}
export class CreditsScreen extends SimpleScreen {
  constructor(app) { super(app, "asset_ui_credits", () => app.showMainMenu()); }
}
export class StoryScreen extends SimpleScreen {
  constructor(app) { super(app, "asset_ui_story", () => app.showMainMenu()); }
}

/* ---------------------------------------------------------------- settings
 * Port of AccountScreen + AccountMediator/VolumeSliderMediator/
 * FlavourSelectionMediator/ClearLocalDataMediator and the binding mediators.
 * The account (login) panel is hidden exactly as the original does when
 * AccountDetails.useDatabase is false, so this screen is settings-only.
 *
 * Widget placement comes from the AccountScreen symbol (character 332); the
 * screen art is exported with the login panel and the volume knob removed. */
const SETTINGS_VOLUME_BAR = 96;          // invisible VolumeSlider track (shape 248)
const SETTINGS_VOLUME_X = 159, SETTINGS_VOLUME_Y = 302;
const SETTINGS_FLAVOUR_X = 66, SETTINGS_FLAVOUR_Y = 383;
const SETTINGS_FLAVOUR_W = 344.95, SETTINGS_FLAVOUR_H = 146; // FlavourSelection (330)
const SETTINGS_SWATCH = 20;              // SwatchButton (546)
const SWATCH_BORDER = 2;

class VolumeKnob extends MovieClip {
  constructor() {
    super("asset_ui_volumeknob");
    this.mouseChildren = false;
    this.buttonMode = true;
    this.useHandCursor = true;
    this._mouseOver = false;
    this._mouseDown = false;
    this.label = new TextField();
    this.label._font = "uni 05_53_8pt_st";
    this.label._fontSize = 8;
    this.label.textColor = 0x000000;
    this.label._align = "left";
    this.label._textW = 20;
    this.label._textH = 16;
    this.label._bounds = [0, 0, 20, 16];
    this.label.x = -7; this.label.y = -5;
    this.addChild(this.label);
    this.addEventListener(MouseEvent.MOUSE_OVER, () => { this._mouseOver = true; this.updateVisualState(); });
    this.addEventListener(MouseEvent.MOUSE_OUT, () => { this._mouseOver = false; this.updateVisualState(); });
    this.addEventListener(MouseEvent.MOUSE_DOWN, () => { this._mouseDown = true; this.updateVisualState(); });
    this.addEventListener(MouseEvent.MOUSE_UP, () => { this._mouseDown = false; this.updateVisualState(); });
  }
  updateVisualState() { this.gotoAndStop(this._mouseOver ? 2 : 1); }
  get text() { return this.label.text; }
  set text(t) { this.label.text = t == null ? "" : String(t); }
}

class FlavourSwatch extends Sprite {
  constructor(screen, index) {
    super();
    this.screen = screen;
    this.index = index;
    this._bounds = [-SETTINGS_SWATCH / 2, -SETTINGS_SWATCH / 2, SETTINGS_SWATCH, SETTINGS_SWATCH];
    this.buttonMode = true;
    this.useHandCursor = true;
    this._customDraw = (r, m, mult) => this.draw(r, m, mult);
    this.addEventListener(MouseEvent.CLICK, () => this.screen.pickFlavour(this.index));
  }
  draw(r, m, mult) {
    const A = globalThis.AssetLibrary;
    const selected = this.screen.app.options.ninjaFlavour === this.index;
    const border = selected ? 0xffffff : 0x000000;
    const colour = A.flavours[0][this.index] || 0;
    const s = SETTINGS_SWATCH, h = s / 2, b = SWATCH_BORDER;
    const rgb = (c) => [((c >> 16) & 255) / 255, ((c >> 8) & 255) / 255, (c & 255) / 255];
    const [br, bg, bb] = rgb(border);
    const [cr, cg, cb] = rgb(colour);
    r.drawSolidQuad(m, -h, -h, s, s, br, bg, bb, 1);
    r.drawSolidQuad(m, -h + b, -h + b, s - 2 * b, s - 2 * b, cr, cg, cb, 1);
  }
}

export class SettingsScreen extends MovieClip {
  constructor(app) {
    super(null);
    this.app = app;
    this.keyNames = new KeyNames();
    this._capture = null;
    this._dragging = false;

    this.baked = new MovieClip("asset_ui_account");
    this.addChild(this.baked);

    this.returnButton = new BasicButton("asset_ui_return");
    this.returnButton.x = 666; this.returnButton.y = 549;
    this.returnButton.addEventListener(MouseEvent.CLICK, () => this.app.showMainMenu());
    this.addChild(this.returnButton);

    this.clearButton = new BasicButton("asset_ui_clear");
    this.clearButton.x = 558; this.clearButton.y = 549;
    this.clearButton.addEventListener(MouseEvent.CLICK, () => {
      this.app.resetLocalData();
      this.app.showMainMenu();
    });
    this.addChild(this.clearButton);

    // key bindings (placements from AccountScreen; a "solo" set for the
    // single-player game and a "coop" set shared by both players).
    const soloBinding = (action) => ({
      get: () => app.soloKeys.getActionKeyForPlayer(action, 0),
      set: (code) => {
        app.soloKeys.bindActionKeyForPlayer(action, code, 0);
        this._save(SavedProperties.KEY_CONFIG_SOLO, app.soloKeys.keyConfigString);
      },
    });
    const coopBinding = (action, player) => ({
      get: () => app.coopKeys.getActionKeyForPlayer(action, player),
      set: (code) => {
        app.coopKeys.bindActionKeyForPlayer(action, code, player);
        this._save(SavedProperties.KEY_CONFIG_COOP, app.coopKeys.keyConfigString);
      },
    });
    const menuBinding = (prop, saved) => ({
      get: () => app.globalKeys[prop],
      set: (code) => {
        app.globalKeys[prop] = code;
        this._save(saved, code);
      },
    });
    this._addKeyButton(442, 101, "asset_ui_key_solo_left", soloBinding(PlayerKeys.LEFT));
    this._addKeyButton(507, 101, "asset_ui_key_solo_jump", soloBinding(PlayerKeys.JUMP));
    this._addKeyButton(574, 101, "asset_ui_key_solo_right", soloBinding(PlayerKeys.RIGHT));
    this._addKeyButton(639, 101, "asset_ui_key_solo_suicide", soloBinding(PlayerKeys.SUICIDE));
    this._addKeyButton(442, 221, "asset_ui_key_p1_left", coopBinding(PlayerKeys.LEFT, 0));
    this._addKeyButton(507, 221, "asset_ui_key_p1_jump", coopBinding(PlayerKeys.JUMP, 0));
    this._addKeyButton(574, 221, "asset_ui_key_p1_right", coopBinding(PlayerKeys.RIGHT, 0));
    this._addKeyButton(639, 221, "asset_ui_key_p1_suicide", coopBinding(PlayerKeys.SUICIDE, 0));
    this._addKeyButton(442, 301, "asset_ui_key_p2_left", coopBinding(PlayerKeys.LEFT, 1));
    this._addKeyButton(507, 301, "asset_ui_key_p2_jump", coopBinding(PlayerKeys.JUMP, 1));
    this._addKeyButton(574, 301, "asset_ui_key_p2_right", coopBinding(PlayerKeys.RIGHT, 1));
    this._addKeyButton(639, 301, "asset_ui_key_p2_suicide", coopBinding(PlayerKeys.SUICIDE, 1));
    this._addKeyButton(442, 382, "asset_ui_key_pause", menuBinding("pause", SavedProperties.MENU_CONFIG_PAUSE));
    this._addKeyButton(442, 458, "asset_ui_key_menu_left", menuBinding("left", SavedProperties.MENU_CONFIG_LEFT));
    this._addKeyButton(507, 458, "asset_ui_key_menu_up", menuBinding("up", SavedProperties.MENU_CONFIG_UP));
    this._addKeyButton(574, 458, "asset_ui_key_menu_right", menuBinding("right", SavedProperties.MENU_CONFIG_RIGHT));
    this._addKeyButton(639, 458, "asset_ui_key_menu_down", menuBinding("down", SavedProperties.MENU_CONFIG_DOWN));
    this._addKeyButton(442, 506, "asset_ui_key_menu_select", menuBinding("select", SavedProperties.MENU_CONFIG_SELECT));
    this._addKeyButton(507, 506, "asset_ui_key_menu_back", menuBinding("back", SavedProperties.MENU_CONFIG_BACK));

    // volume slider: 96px invisible track, knob reports 0..100
    this.volumeBar = new Sprite();
    this.volumeBar.x = SETTINGS_VOLUME_X; this.volumeBar.y = SETTINGS_VOLUME_Y;
    this.volumeBar._bounds = [0, 0, SETTINGS_VOLUME_BAR, 24];
    this.addChild(this.volumeBar);
    this.volumeKnob = new VolumeKnob();
    this.volumeKnob.y = SETTINGS_VOLUME_Y;
    this.addChild(this.volumeKnob);
    this._setVolumePosition(app.options.volume);
    this.volumeKnob.addEventListener(MouseEvent.MOUSE_DOWN, () => {
      this._dragging = true;
      this._moveSlider(this.app.input.GetMousePos());
    });
    this._stageMove = (e) => { if (this._dragging) this._moveSlider(e); };
    this._stageUp = () => { this._dragging = false; };
    app.stage.addEventListener(MouseEvent.MOUSE_MOVE, this._stageMove);
    app.stage.addEventListener(MouseEvent.MOUSE_UP, this._stageUp);

    // flavours (FlavourSelection): the default plus one per beaten column
    this.swatches = [];
    this._createSwatches();
  }
  _save(prop, value) {
    this.app.sharedObject.setProperty(prop, value);
    try { this.app.sharedObject.flush(); } catch (e) {}
  }
  _addKeyButton(x, y, asset, binding) {
    const b = new DynamicButton(asset);
    b.x = x; b.y = y;
    b.text = this.keyNames.getName(binding.get());
    b.addEventListener(MouseEvent.CLICK, () => {
      // clicking the button while capturing is a stage mousedown first
      if (this._capture) return;
      this._beginCapture(b, binding);
    });
    this.addChild(b);
    return b;
  }
  _beginCapture(button, binding) {
    this._capture = { button, binding };
    this._stageDown = (e) => {
      if (e.target !== button) this._endCapture();
    };
    this.app.stage.addEventListener(MouseEvent.MOUSE_DOWN, this._stageDown);
  }
  _endCapture() {
    if (this._stageDown) this.app.stage.removeEventListener(MouseEvent.MOUSE_DOWN, this._stageDown);
    this._stageDown = null;
    this._capture = null;
  }
  _setVolumePosition(volume) {
    const x = SETTINGS_VOLUME_X + Math.min(1, Math.max(0, volume)) * SETTINGS_VOLUME_BAR;
    this.volumeKnob.x = x;
    this.volumeKnob.text = String(Math.trunc(100 * volume));
  }
  _moveSlider(e) {
    const stageX = e.stageX !== undefined ? e.stageX : e.x;
    const left = this.volumeBar.localToGlobal({ x: 0, y: 0 }).x;
    const local = Math.min(SETTINGS_VOLUME_BAR, Math.max(0, stageX - left));
    const volume = local / SETTINGS_VOLUME_BAR;
    this.app.options.volume = volume;
    this.app.setVolume(volume);
    this._setVolumePosition(volume);
    this._save(SavedProperties.VOLUME, volume);
  }
  _createSwatches() {
    const episodes = this.app.episodes;
    const cols = 7;
    const rows = Math.ceil(episodes.numberOfSets / 10 / cols);
    const size = SETTINGS_SWATCH;
    const freeX = SETTINGS_FLAVOUR_W - cols * size - 2;
    const freeY = SETTINGS_FLAVOUR_H - rows * size - 2;
    const gap = Math.min(freeX / (cols + 1), freeY / (rows + 1));
    const topMargin = (freeY - (rows - 1) * gap) / 2;
    const leftMargin = (freeX - (cols - 1) * gap) / 2;
    const place = (swatch, bx, by) => {
      swatch.x = SETTINGS_FLAVOUR_X + bx * (size + gap) + leftMargin + size / 2;
      swatch.y = SETTINGS_FLAVOUR_Y + by * (size + gap) + topMargin + size / 2;
      this.addChild(swatch);
      this.swatches.push(swatch);
    };
    place(new FlavourSwatch(this, 0), 0, 0);
    for (let col = 0; col < episodes.numberOfSets / 10; col++) {
      if (!episodes.isRangeBeaten(col * 10, col * 10 + 9)) continue;
      place(new FlavourSwatch(this, col + 1),
        Math.trunc((col + 1) % cols), Math.trunc((col + 1) / cols));
    }
  }
  pickFlavour(index) {
    const options = this.app.options;
    const old = options.ninjaFlavour;
    if (index === old) return;
    options.ninjaFlavour = index;
    options.p1Colour = this.app.flavours.getP1Flavour(index);
    options.p2Colour = this.app.flavours.getP2Flavour(index);
    this._save(SavedProperties.FLAVOUR, index);
  }
  handleKey(code) {
    if (this._capture) {
      const { button, binding } = this._capture;
      binding.set(code);
      button.text = this.keyNames.getName(code);
      this._endCapture();
      return;
    }
    const g = this.app.globalKeys;
    if (code === g.back || code === g.select) this.app.showMainMenu();
  }
  dispose() {
    this._endCapture();
    this._dragging = false;
    if (this.app && this.app.stage) {
      this.app.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this._stageMove);
      this.app.stage.removeEventListener(MouseEvent.MOUSE_UP, this._stageUp);
    }
    super.dispose();
  }
}

export class PreloaderScreen extends Sprite {
  constructor(lib) {
    super();
    this.baked = new MovieClip("asset_ui_preloader");
    this.addChild(this.baked);
    this.timebar = new TimeBar();
    this.js_timebar = this.timebar;
    this.addChild(this.timebar);
    this.progress = 0;
  }
  setProgress(p) {
    this.progress = p;
    this.timebar.progress = p;
    const n = 502;
    // PreloaderScreen's timebar is the same 624px bar; progress 0..1.
  }
}

/* ------------------------------------------------------------------ time bar */
export class TimeBar extends Sprite {
  constructor() {
    super();
    this.progress = 1;
    this._frame = null;
    this._bounds = [0, 0, 0, 0];
  }
  _ensureFrame() {
    if (!this._frame && globalThis.AssetLibrary) {
      const s = globalThis.AssetLibrary.sprites["asset_ui_timebar"];
      if (s) this._frame = s.frames[s.frames.length - 1];
    }
  }
  _customDraw(renderer, m, mult, add) {
    this._ensureFrame();
    if (!this._frame) return;
    renderer.drawFrameQuad(this._frame, m, mult, add, this._frame.w * Math.max(0, Math.min(1, this.progress)));
  }
}

/* ------------------------------------------------------------------ HUD */
export class HUD extends Sprite {
  constructor(app) {
    super();
    this.app = app;
    const A = globalThis.AssetLibrary;
    this.timebar = new TimeBar();
    this.addChild(this.timebar);

    this.timetext = new Sprite();
    this.digits = [];
    const centers = [23, 30, 37, 44, 55, 62, 69];
    const digitFields = [0, 1, 2, 3, 4, 5, 6];
    for (let i = 0; i < 7; i++) {
      const t = new TextField();
      t._font = "uni 05_53_8pt_st";
      t._fontSize = 8;
      t.textColor = 0;
      t._align = "center";
      t._textW = 8; t._textH = 10;
      t._bounds = [0, 0, 8, 10];
      t.x = centers[i] - 4;
      t.y = 5;
      t.text = "0";
      this.timetext.addChild(t);
      this.digits.push(t);
    }
    // decimal point (static art in the original HUD)
    const dot = new Shape();
    dot.graphics.beginFill(0x000000, 1);
    dot.graphics.drawRect(0, 0, 2, 2);
    dot.x = 49; dot.y = 12;
    this.timetext.addChild(dot);
    this.addChild(this.timetext);

    this.leveltext = new TextField();
    this.leveltext._font = "uni 05_53_8pt_st";
    this.leveltext._fontSize = 8;
    this.leveltext.textColor = 0;
    this.leveltext._textW = 640;
    this.leveltext._textH = 10;
    this.leveltext._bounds = [0, 0, 640, 10];
    this.leveltext.x = 32; this.leveltext.y = 582;
    this.addChild(this.leveltext);

    // gold counter (hidden unless playing a challenge)
    this.gold_collected = new Sprite();
    this.gold_collected.visible = false;
    if (A && A.sprites["asset_ui_goldcounter"]) {
      const gc = new Sprite();
      gc.x = 3; gc.y = -1;
      gc._goldFrame = A.sprites["asset_ui_goldcounter"].frames[0];
      gc._customDraw = (r, m, mult, add) => r.drawFrameQuad(gc._goldFrame, m, mult, add, 20);
      this.gold_collected.addChild(gc);
      this.numgold = new TextField();
      this.numgold._font = "uni 05_53_8pt_st";
      this.numgold._fontSize = 8;
      this.numgold.textColor = 0;
      this.numgold._align = "right";
      this.numgold._textW = 31; this.numgold._textH = 10;
      this.numgold._bounds = [0, 0, 31, 10];
      this.numgold.x = 723; this.numgold.y = 4;
      this.gold_collected.addChild(this.numgold);
    }
    this.addChild(this.gold_collected);

    this.prompt = new MovieClip("asset_ui_prompt");
    this.prompt.gotoAndStop("begin");
    this.addChild(this.prompt);
  }
  setLevelName(name) { this.leveltext.text = name; }
  setTime(ticks, rate) {
    this.timebar.progress = Math.max(0, Math.min(1, ticks / (360 * rate)));
    const s = timeFormatter.formatTime(ticks, rate);
    for (let i = 0; i < 7; i++) this.digits[i].text = s.charAt(i);
    this.digits[4].text = s.charAt(4);
  }
  setGold(n) { if (this.numgold) this.numgold.text = String(n); }
  setPromptLabel(label) { this.prompt.gotoAndPlay(label); }
}

/* ------------------------------------------------------------------ game over */
export class GameOverPopup extends Sprite {
  constructor(app) {
    super();
    this.app = app;
    this._frame = null;
    this._slideX = 0;
    this._ticks = 0;
    this._sectionMap = {};
    const A = globalThis.AssetLibrary;
    const s = A && A.sprites["asset_ui_gameover"];
    if (s) {
      const starts = Object.values(s.labels).sort((a, b) => a - b);
      for (let i = 0; i < starts.length; i++) {
        const label = Object.keys(s.labels).find(k => s.labels[k] === starts[i]);
        const end = i + 1 < starts.length ? starts[i + 1] - 1 : s.frameCount;
        const idx = s.frameNumbers.indexOf(end);
        this._sectionMap[label] = idx >= 0 ? s.frames[idx] : s.frames[0];
      }
      this._frame = s.frames[0];
    }
    this.kong_logo2 = new DisplayObject();
    this.kong_logo2.visible = false;
    this._bounds = [178, 159, 408, 66];
  }
  gotoAndPlay(label) {
    if (this._sectionMap[label]) this._frame = this._sectionMap[label];
    this._slideX = 640;
    this._ticks = 0;
  }
  tick() {
    this._ticks++;
    if (this._slideX > 0) {
      this._slideX = Math.max(0, this._slideX - 32);
    }
  }
  _customDraw(renderer, m, mult, add) {
    if (this._frame) renderer.drawFrameQuad(this._frame, m, mult, add, null, this._slideX);
  }
}

/* ThumbnailView: 1/6-scale level preview, matching ThumbnailGenerator.as. */
function matMul(m, p) {
  return {
    a: m.a * p.a + m.b * p.c, b: m.a * p.b + m.b * p.d,
    c: m.c * p.a + m.d * p.c, d: m.c * p.b + m.d * p.d,
    tx: m.tx * p.a + m.ty * p.c + p.tx,
    ty: m.tx * p.b + m.ty * p.d + p.ty,
  };
}
const TRANSLATE = (x, y) => ({ a: 1, b: 0, c: 0, d: 1, tx: x, ty: y });
const SCALE = (s) => ({ a: s, b: 0, c: 0, d: s, tx: 0, ty: 0 });
const IDENT = { a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0 };

export class ThumbnailView extends Sprite {
  constructor(state) {
    super();
    this.state = state;
    this._bounds = [0, 0, 132, 100];
  }
  _customDraw(renderer, m, mult, add) {
    const A = globalThis.AssetLibrary;
    if (!A || !this.state) return;
    const tiles = A.sprites["asset_gfx_tiles"];
    const st = this.state;
    for (let i = 0; i < st.tileIDs.length; i++) {
      const c = i % 31, r = Math.floor(i / 31);
      const t = st.tileIDs[i];
      const idx = Math.min(t, tiles.frames.length - 1);
      const fr = tiles.frames[idx];
      if (!fr) continue;
      const cx = (c + 1 + 0.5) * 4;
      const cy = (r + 1 + 0.5) * 4;
      const mm = matMul(matMul(SCALE(1 / 6), TRANSLATE(cx, cy)), m);
      renderer.drawFrameQuad(fr, mm, [1, 1, 1, 1], [0, 0, 0]);
    }
    const colors = {
      0: [0, 0, 0], 1: [0.55, 0.1, 0.1], 2: [0.8, 0.65, 0], 3: [0, 0.7, 0.7],
      4: [0, 0.7, 0.7], 5: [0, 0.7, 0.7], 6: [0, 0.7, 0.7], 7: [0, 0.7, 0.7],
      8: [0.6, 0.6, 0.6], 9: [0, 0.7, 0], 10: [0, 0.7, 0], 11: [0.7, 0.2, 0],
      12: [0.7, 0.2, 0], 13: [0.7, 0.2, 0], 14: [0.7, 0.2, 0], 15: [0.5, 0.5, 0],
      16: [0.4, 0.4, 0.9], 17: [0.6, 0.6, 0.9], 18: [0.7, 0.3, 0], 19: [0.4, 0.4, 0.4],
      20: [0.4, 0.4, 0.4],
    };
    for (const e of st.entities) {
      const type = e[0];
      const x = e[1] * 6 / 6, y = e[2] * 6 / 6;
      const col = colors[type] || [0.5, 0.5, 0.5];
      const mm = matMul(m, TRANSLATE(x, y));
      renderer.drawSolidQuad(mm, -1.2, -1.2, 2.4, 2.4, col[0], col[1], col[2], 1);
    }
  }
}
