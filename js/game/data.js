/* Ports of the com.metanet.data classes used by the offline game. */
import { ByteArray, SharedObject } from "../flash.js";

export const SavedProperties = {
  USERNAME: "user", COOKIE: "cookie", VOLUME: "volume", BEATEN_LEVELS: "unlocked",
  KEY_CONFIG_COOP: "keyconfig", KEY_CONFIG_SOLO: "solokeyconfig",
  MENU_CONFIG_UP: "menuconfigup", MENU_CONFIG_DOWN: "menuconfigdown",
  MENU_CONFIG_LEFT: "menuconfigleft", MENU_CONFIG_RIGHT: "menuconfigright",
  MENU_CONFIG_BACK: "menuconfigback", MENU_CONFIG_SELECT: "menuconfigselect",
  MENU_CONFIG_PAUSE: "menuconfigpause",
  SAVED_EPISODE: "savedEpisode", SAVED_LEVEL: "savedLevel",
  SAVED_TICKS_REMAINING: "savedTicks", SAVED_CHALLENGE: "savedChallenge",
  FLAVOUR: "p1Flavour", USER_ID: "userID",
};

export class Options {
  constructor() {
    this.enteredTerm = ""; this.enteredType = null; this.selectedTerm = null; this.selectedType = null;
    this.volume = 1; this.coopMode = false; this.selectedLevel = null;
    this.selectedLevelIndexInSearch = -1; this.selectedEpisode = -1; this.selectedChallenge = -1;
    this.ticksToResumeWith = 0; this.scoreGoldImmediately = false; this.resetScoreOnDeath = false;
    this.ninjaFlavour = 0; this.p1Colour = 0; this.p2Colour = 0;
  }
}

export class Level {
  constructor() {
    this.id = ""; this.name = "Untitled"; this.creatorName = ""; this.creatorID = "";
    this.meanRating = 0; this.loaded = false; this.personalBest = 0; this.minimumHighscore = 0;
    this.favourite = false; this.data = null; this.isNew = false; this.published = false;
    this.personalRating = 0; this.fullData = false; this.waitingForUpload = false;
  }
  get isMetanetLevel() { return Number(this.id) < 1000; }
}

export class AccountDetails {
  constructor() {
    this.enteredUserName = ""; this.enteredPassword = ""; this.loggedInUserName = "";
    this.email = ""; this.enteredPasswordRetype = ""; this.loggedIn = false;
    this.cookie = null; this.userID = null; this.error = null;
    // Offline build: there is no backend.  All online account features are
    // disabled; the entry points are NOT IMPLEMENTED in app.js.
    this.useDatabase = false;
    this.isWeb = false;
    this.canAddFavourites = false;
    this.canCreateNewLevel = true;
  }
}

export class GameStats {
  constructor() { this.score = 0; this.level = null; this.replayBytes = null; this.isEpisode = false; }
}

export class TimeFormatter {
  formatTime(ticks, rate) {
    const seconds = ticks / rate;
    const parts = seconds.toString().split(".");
    let whole = parts[0];
    let frac = parts.length === 1 ? "000" : parts[1].substr(0, 3);
    while (whole.length < 4) whole = " " + whole;
    while (frac.length < 3) frac += "0";
    return whole + frac;
  }
}

export class Flavours {
  constructor(lib) { this.lib = lib; }
  getP1Flavour(i) { return this.lib.flavours[0][i]; }
  getP2Flavour(i) { return this.lib.flavours[1][i]; }
}

export class EpisodeData {
  constructor(lib, sharedObject) {
    this.lib = lib;
    this.sharedObject = sharedObject;
    this.EPISODES_PER_COLUMN = 10;
    this.NUMBER_OF_EPISODES = 120;
    this.levelsPerSet = 5;
    this.numberOfSets = 120;
    this.numberBeaten = 0;
    this._beaten = new Array(120).fill(false);
    this._unlocked = [];
    this._lastBeatenByColumn = new Array(12).fill(-1);
    this.init();
    this.unlockDefaultEpisodes();
    this.loadFromSharedObject();
  }
  init() {
    this._beaten = new Array(this.NUMBER_OF_EPISODES).fill(false);
    this._unlocked = [];
    this._lastBeatenByColumn = new Array(12).fill(-1);
  }
  unlockDefaultEpisodes() {
    for (let i = 0; i < 12; i++) {
      this._unlocked[i * 10] = true;
      this._lastBeatenByColumn[i] = -1;
    }
  }
  loadFromSharedObject() {
    const arr = this.sharedObject.data[SavedProperties.BEATEN_LEVELS];
    if (Array.isArray(arr)) {
      for (let i = 0; i < arr.length; i++) {
        if (arr[i]) this.beatEpisodeFromSharedObject(i);
      }
    }
  }
  beatEpisodeFromSharedObject(i) {
    if (!this._unlocked[i + 1]) this._unlocked[i + 1] = true;
    if (!this._beaten[i]) this.beatEpisode(i);
  }
  beatEpisodeFromGameplay(i) {
    if (!this._unlocked[i + 1]) this._unlocked[i + 1] = true;
    if (!this._beaten[i]) this.beatEpisode(i);
    this.saveToSharedObject();
  }
  beatEpisode(i) {
    const col = Math.floor(i / 10);
    this.numberBeaten++;
    this._lastBeatenByColumn[col]++;
    this._beaten[i] = true;
  }
  saveToSharedObject() {
    this.sharedObject.setProperty(SavedProperties.BEATEN_LEVELS, this._beaten);
    try { this.sharedObject.flush(); } catch (e) {}
  }
  isUnlocked(i) { return !!this._unlocked[i]; }
  isBeaten(i) { return !!this._beaten[i]; }
  isRangeBeaten(a, b) {
    for (let i = a; i <= b; i++) if (!this.isBeaten(i)) return false;
    return true;
  }
  get lastUnbeaten() { return this._beaten.indexOf(false); }
  get lastBeatenByColumn() { return this._lastBeatenByColumn; }
  get beaten() { return this._beaten.concat(); }
  getEpisodeLabelFor(i) {
    if (i < 10) return "0" + String(i);
    const tens = Math.floor(i / 10);
    if (tens === 10) return String(i).split("10").join("a");
    if (tens === 11) return String(i).split("11").join("b");
    return String(i);
  }
  getLevel(ep, idx) {
    const l = this.lib.levels.find(x => x.e === ep && x.i === idx);
    return l ? ByteArray.fromBase64(l.data) : new ByteArray();
  }
  getLevelSet(ep) {
    const out = [];
    for (let i = 0; i < this.levelsPerSet; i++) out.push(this.getLevel(ep, i));
    return out;
  }
  createLevelSetForColumn(col) {
    const out = [];
    for (let i = 0; i < 10; i++) out.push(...this.getLevelSet(i + col * 10));
    return out;
  }
}

export class AttractMode {
  constructor(lib) {
    this._index = 0; this._levels = []; this._replayData = [];
    if (lib && lib.attract) {
      for (const r of lib.attract) {
        this.storeReplay(r.level, ByteArray.fromBase64(r.data));
      }
    }
  }
  storeReplay(level, data) { this._levels.push(level); this._replayData.push(data); }
  getRandomReplay() { this._index = Math.floor(Math.random() * this._levels.length * 0.9999); return this._index; }
  getNextReplay() { this._index = (this._index + 1) % this._levels.length; return this._index; }
  getReplayLevel(i) { return this._levels[i]; }
  getReplayData(i) { return this._replayData[i]; }
}
