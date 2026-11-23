/* Game application: a direct port of App_MultiPurpose.as plus the parts of
 * NMediator/commands that drive the offline single-player game. */
import {
  Sprite, MovieClip, ByteArray, SharedObject, SoundMixer, SoundTransform,
  Keyboard, getTimer, MouseEvent, KeyboardEvent, Stage, AudioSystem,
} from "./flash.js";
import { AssetLibrary } from "./assets.js";
import { Editor_State } from "./game/editorstate.js";
import { LoadLevel_EditorState } from "./game/simloader.js";
import { Simulator } from "./game/simulator.js";
import { GraphicsManager } from "./game/graphicsmanager.js";
import { SoundManager } from "./game/soundmanager.js";
import { SimpleInput, GlobalKeys, PlayerKeys } from "./game/input.js";
import { Options, EpisodeData, AccountDetails, GameStats, Flavours, SavedProperties, TimeFormatter, AttractMode } from "./game/data.js";
import { MenuScreen, EpisodesScreen, HelpScreen, CreditsScreen, StoryScreen, SettingsScreen, HUD, GameOverPopup, PreloaderScreen } from "./ui.js";

const GameStates = { UNLOADED: 0, PRE_GAME: 1, GAME: 2, POST_GAME: 3, PAUSED_IN_GAME: 4 };
const MenuStates = { MAIN_MENU: 0, PLAYING_GAME: 1, GAME_OVER: 2, WATCHING_REPLAY: 3 };

export class GameApp {
  constructor(stage, lib, gameLayer, uiLayer, menuLayer) {
    this.stage = stage;
    this.lib = lib;
    this.gameLayer = gameLayer;
    this.uiLayer = uiLayer;
    this.menuLayer = menuLayer;
    this.sharedObject = SharedObject.getLocal("n_account");
    this.options = new Options();
    this.account = new AccountDetails();
    this.episodes = new EpisodeData(lib, this.sharedObject);
    this.attractMode = new AttractMode(lib);
    this.stats = new GameStats();
    this.input = new SimpleInput(stage);
    this.globalKeys = new GlobalKeys();
    this.soloKeys = new PlayerKeys();
    this.coopKeys = new PlayerKeys();
    this.flavours = new Flavours(lib);
    this.timeFormatter = new TimeFormatter();
    this.currentScreen = null;
    this.lastScreenName = "menu";
    this._mouseOverTarget = null;
    this._mouseDownTarget = null;
    this._sim = null;
    this._gfx = null;
    this._sfx = null;
    this._hud = null;
    this._gameOver = null;
    this._uiState = MenuStates.MAIN_MENU;
    this._gameState = GameStates.UNLOADED;
    this._isReplay = false;
    this._replayChosenByPlayer = false;
    this._playingLevelset = false;
    this._currentLevelInSet = 0;
    this._levelSet = null;
    this._levelData = null;
    this._levelName = "";
    this._currentTicks = 0;
    this._startingTicks = 0;
    this._ticksElapsed = 0;
    this._goldCollected = 0;
    this._goldCountdown = 0;
    this._GOLD_DELAY = 8;
    this._gameOverCooldown = 0;
    this._start = 0;
    this._pausedTime = 0;
    this._thisTick = 0;
    this._lastTick = 0;
    this._gameTooSlow = false;
    this.playerKeys = this.soloKeys;
    this.initialize();
  }

  initialize() {
    this.sim_rate = 60;
    this._defaultStartingTicks = 90 * 60;
    this._startingTicks = this._defaultStartingTicks;
    this._ticksPerGold = 2 * 60;
    this._uiState = MenuStates.MAIN_MENU;
    this._gameState = GameStates.UNLOADED;
    this.applyDefaultOptions();
    this.loadSavedOptions();
    this.playerKeys = this.soloKeys;
  }
  // StoreDefaults.as
  applyDefaultOptions() {
    this.soloKeys.bindActionKeyForPlayer(PlayerKeys.JUMP, Keyboard.Z, 0);
    this.soloKeys.bindActionKeyForPlayer(PlayerKeys.LEFT, Keyboard.LEFT, 0);
    this.soloKeys.bindActionKeyForPlayer(PlayerKeys.RIGHT, Keyboard.RIGHT, 0);
    this.soloKeys.bindActionKeyForPlayer(PlayerKeys.SUICIDE, Keyboard.K, 0);
    this.coopKeys.bindActionKeyForPlayer(PlayerKeys.JUMP, Keyboard.SHIFT, 0);
    this.coopKeys.bindActionKeyForPlayer(PlayerKeys.LEFT, 65, 0);
    this.coopKeys.bindActionKeyForPlayer(PlayerKeys.RIGHT, 68, 0);
    this.coopKeys.bindActionKeyForPlayer(PlayerKeys.SUICIDE, 84, 0);
    this.coopKeys.bindActionKeyForPlayer(PlayerKeys.JUMP, 78, 1);
    this.coopKeys.bindActionKeyForPlayer(PlayerKeys.LEFT, 188, 1);
    this.coopKeys.bindActionKeyForPlayer(PlayerKeys.RIGHT, 190, 1);
    this.coopKeys.bindActionKeyForPlayer(PlayerKeys.SUICIDE, 79, 1);
    this.globalKeys.up = Keyboard.UP; this.globalKeys.down = Keyboard.DOWN;
    this.globalKeys.left = Keyboard.LEFT; this.globalKeys.right = Keyboard.RIGHT;
    this.globalKeys.back = Keyboard.ESCAPE;
    this.globalKeys.pause = Keyboard.P; this.globalKeys.quit = Keyboard.Q;
    this.globalKeys.select = Keyboard.Z;
    this.options.volume = 0.3;
    SoundMixer.soundTransform = new SoundTransform(0.3);
    this.options.ninjaFlavour = 0;
    this.options.p1Colour = this.flavours.getP1Flavour(0);
    this.options.p2Colour = this.flavours.getP2Flavour(0);
  }
  // StoreDataFromSharedObject.as
  loadSavedOptions() {
    const d = this.sharedObject.data;
    const P = SavedProperties;
    if (d.hasOwnProperty(P.VOLUME)) {
      this.options.volume = d[P.VOLUME];
      SoundMixer.soundTransform = new SoundTransform(this.options.volume);
    }
    if (d.hasOwnProperty(P.KEY_CONFIG_COOP)) this.coopKeys.keyConfigString = d[P.KEY_CONFIG_COOP];
    if (d.hasOwnProperty(P.KEY_CONFIG_SOLO)) this.soloKeys.keyConfigString = d[P.KEY_CONFIG_SOLO];
    if (d.hasOwnProperty(P.MENU_CONFIG_BACK)) this.globalKeys.back = d[P.MENU_CONFIG_BACK];
    if (d.hasOwnProperty(P.MENU_CONFIG_DOWN)) this.globalKeys.down = d[P.MENU_CONFIG_DOWN];
    if (d.hasOwnProperty(P.MENU_CONFIG_LEFT)) this.globalKeys.left = d[P.MENU_CONFIG_LEFT];
    if (d.hasOwnProperty(P.MENU_CONFIG_PAUSE)) this.globalKeys.pause = d[P.MENU_CONFIG_PAUSE];
    if (d.hasOwnProperty(P.MENU_CONFIG_RIGHT)) this.globalKeys.right = d[P.MENU_CONFIG_RIGHT];
    if (d.hasOwnProperty(P.MENU_CONFIG_SELECT)) this.globalKeys.select = d[P.MENU_CONFIG_SELECT];
    if (d.hasOwnProperty(P.MENU_CONFIG_UP)) this.globalKeys.up = d[P.MENU_CONFIG_UP];
    if (d.hasOwnProperty(P.FLAVOUR)) {
      this.options.ninjaFlavour = d[P.FLAVOUR];
      this.options.p1Colour = this.flavours.getP1Flavour(this.options.ninjaFlavour);
      this.options.p2Colour = this.flavours.getP2Flavour(this.options.ninjaFlavour);
    }
  }
  setVolume(volume) {
    SoundMixer.soundTransform = new SoundTransform(volume);
  }
  // ResetLocalData.as (the logout request is online-only and is skipped)
  resetLocalData() {
    this.episodes.init();
    this.episodes.unlockDefaultEpisodes();
    this.sharedObject.data = {};
    try { this.sharedObject.flush(); } catch (e) {}
    this.applyDefaultOptions();
  }

  // ---------------------------------------------------------------- screens
  setScreen(screen) {
    if (this.currentScreen) {
      disposeDisplayTree(this.currentScreen);
      if (this.currentScreen.parent) this.currentScreen.parent.removeChild(this.currentScreen);
    }
    this.currentScreen = screen;
    if (screen) this.menuLayer.addChild(screen);
  }
  removeScreen(screen) {
    if (this.currentScreen === screen) this.setScreen(null);
    else if (screen && screen.parent) screen.parent.removeChild(screen);
  }
  showMainMenu() {
    this.lastScreenName = "menu";
    this.setScreen(new MenuScreen(this));
    this.showRandomReplay();
  }
  showEpisodes() {
    this.stopReplay();
    this.lastScreenName = "episodes";
    this.setScreen(new EpisodesScreen(this));
  }
  showHelp() { this.stopReplay(); this.setScreen(new HelpScreen(this)); }
  showCredits() { this.stopReplay(); this.setScreen(new CreditsScreen(this)); }
  showStory() { this.stopReplay(); this.setScreen(new StoryScreen(this)); }
  showSettings() { this.stopReplay(); this.setScreen(new SettingsScreen(this)); }
  showLastScreen() {
    if (this.lastScreenName === "episodes") this.showEpisodes();
    else this.showMainMenu();
  }
  // NOT IMPLEMENTED: online account / community levels.  These entry points
  // in the original app talk to nserver.thewayoftheninja.org.  This offline
  // build deliberately has no networking code.
  showAccount() { /* NOT IMPLEMENTED */ }
  showUserLevels() { /* NOT IMPLEMENTED */ }

  // ---------------------------------------------------------------- start levels
  useLevelSet(set) { this._levelSet = set; }
  startLevelSet() {
    this._currentLevelInSet = 0;
    this._startingTicks = this._defaultStartingTicks;
    this.playLevelSet();
  }
  resumeLevelSet(index, ticks) {
    this._currentLevelInSet = index;
    this._startingTicks = ticks;
    this.playLevelSet();
  }
  playLevelSet() {
    this._currentTicks = this._startingTicks;
    this._ticksElapsed = 0;
    this._playingLevelset = true;
    this.playLevel(this._levelSet[this._currentLevelInSet]);
    this.saveProgress();
  }
  playSingleLevelFromBytes(data, name) {
    this.playLevel(data);
    this._currentLevel = name;
    this._startingTicks = this._defaultStartingTicks;
    this._currentTicks = this._startingTicks;
    this._ticksElapsed = 0;
    this._playingLevelset = false;
  }
  playLevel(data) {
    this._levelData = data;
    this._isReplay = false;
    this.prepareSessionFromBytes(this._levelData, null);
    this._goldCollected = 0;
    this._uiState = MenuStates.PLAYING_GAME;
    this._gameState = GameStates.PRE_GAME;
    this._hud = new HUD(this);
    this.initializeInGameUI();
    this.uiLayer.addChild(this._hud);
  }

  startEpisode(index) {
    this.options.resetScoreOnDeath = true;
    this.options.scoreGoldImmediately = true;
    this.options.selectedChallenge = -1;
    this.options.selectedEpisode = index;
    this.stopReplay();
    this.useLevelSet(this.episodes.getLevelSet(index));
    this.setScreen(null);
    this.lastScreenName = "episodes";
    this.startLevelSet();
    this.sharedObject.setProperty(SavedProperties.SAVED_EPISODE, index);
    delete this.sharedObject.data[SavedProperties.SAVED_CHALLENGE];
    try { this.sharedObject.flush(); } catch (e) {}
  }
  startChallenge(col) {
    this.options.resetScoreOnDeath = false;
    this.options.scoreGoldImmediately = false;
    this.options.selectedEpisode = -1;
    this.options.selectedChallenge = col;
    this.stopReplay();
    this.useLevelSet(this.episodes.createLevelSetForColumn(col));
    this.setScreen(null);
    this.lastScreenName = "episodes";
    this.startLevelSet();
    this.sharedObject.setProperty(SavedProperties.SAVED_CHALLENGE, col);
    delete this.sharedObject.data[SavedProperties.SAVED_EPISODE];
    try { this.sharedObject.flush(); } catch (e) {}
  }
  resumeSaved() {
    const d = this.sharedObject.data;
    this.options.selectedLevelIndexInSearch = d[SavedProperties.SAVED_LEVEL] || 0;
    this.options.ticksToResumeWith = d[SavedProperties.SAVED_TICKS_REMAINING] || this._defaultStartingTicks;
    if (d.hasOwnProperty(SavedProperties.SAVED_EPISODE)) {
      this.options.resetScoreOnDeath = true;
      this.options.scoreGoldImmediately = true;
      this.options.selectedEpisode = d[SavedProperties.SAVED_EPISODE];
      this.setScreen(null);
      this.useLevelSet(this.episodes.getLevelSet(this.options.selectedEpisode));
      this.resumeLevelSet(this.options.selectedLevelIndexInSearch, this.options.ticksToResumeWith);
    } else if (d.hasOwnProperty(SavedProperties.SAVED_CHALLENGE)) {
      this.options.resetScoreOnDeath = false;
      this.options.scoreGoldImmediately = false;
      this.options.selectedChallenge = d[SavedProperties.SAVED_CHALLENGE];
      this.setScreen(null);
      this.useLevelSet(this.episodes.createLevelSetForColumn(this.options.selectedChallenge));
      this.resumeLevelSet(this.options.selectedLevelIndexInSearch, this.options.ticksToResumeWith);
    }
  }
  stopReplay() {
    if (this._isReplay || this._uiState === MenuStates.WATCHING_REPLAY) {
      this._gameState = GameStates.UNLOADED;
      this.clearGame();
      this.hideAllGUI();
      this._uiState = MenuStates.MAIN_MENU;
    }
    this._isReplay = false;
  }
  showRandomReplay() {
    if (!this.attractMode || this.attractMode._levels.length === 0) return;
    this._isReplay = true;
    this._replayChosenByPlayer = false;
    const i = this.attractMode.getRandomReplay();
    this.loadAttractReplay(i);
  }
  showNextReplay() {
    if (!this.attractMode || this.attractMode._levels.length === 0) return;
    this._isReplay = true;
    this._replayChosenByPlayer = false;
    const i = this.attractMode.getNextReplay();
    this.loadAttractReplay(i);
  }
  loadAttractReplay(i) {
    const levelID = this.attractMode.getReplayLevel(i);
    const replay = this.attractMode.getReplayData(i);
    const levelData = this.episodes.getLevel(Math.floor(levelID / 5), levelID % 5);
    this.showReplay(levelData, replay);
  }
  showReplay(levelBa, replayBa) {
    levelBa.position = 0;
    replayBa.position = 0;
    this._startingTicks = this._defaultStartingTicks;
    this._currentTicks = this._defaultStartingTicks;
    this._ticksElapsed = 0;
    this._isReplay = true;
    this.prepareSessionFromBytes(levelBa, replayBa);
    this.startReplay();
    this._uiState = MenuStates.WATCHING_REPLAY;
    this._gameState = GameStates.GAME;
  }
  startReplay() {
    if (this._replayChosenByPlayer) {
      this._hud = new HUD(this);
      this._hud.prompt.visible = false;
      this.initializeInGameUI();
      this.uiLayer.addChild(this._hud);
    } else {
      this.hideAllGUI();
    }
    this.startGameImmediately();
  }

  // ---------------------------------------------------------------- session
  prepareSessionFromBytes(levelBa, replayBa) {
    this.clearGame();
    let replayCopy = null;
    if (replayBa) {
      replayCopy = new ByteArray();
      replayBa.readBytes(replayCopy, 0, replayBa.bytesAvailable);
      replayBa.position = 0;
    }
    this._levelName = levelBa.readUTF();
    this.initializeInGameUI();
    const body = new ByteArray();
    levelBa.readBytes(body);
    levelBa.position = 0;
    const state = Editor_State.Load_From_Bytes(body);
    let numPlayers;
    if (this.options.coopMode && !this._replayChosenByPlayer) {
      numPlayers = 2;
      this.playerKeys = this.coopKeys;
    } else {
      numPlayers = 1;
      this.playerKeys = this.soloKeys;
    }
    const actionKeys = this.playerKeys.getActions([PlayerKeys.JUMP, PlayerKeys.LEFT, PlayerKeys.RIGHT]);
    this._sim = LoadLevel_EditorState(actionKeys,
      [this.options.p1Colour, this.options.p2Colour], this.input, replayCopy, numPlayers, state);
    this.initializeEngine();
  }
  initializeEngine() {
    this._gfx = new GraphicsManager(this.gameLayer, this._sim.GFX_GetEntityList(),
      this._sim.GFX_GetPlayerList(), this._sim.GFX_GetTileIDs(),
      Simulator.GRID_NUM_ROWS, Simulator.GRID_NUM_COLS, true);
    this._sfx = new SoundManager();
    this._sim.HACKY_SetAV(this._gfx, this._sfx);
    this._gfx.Render();
    this._sim.APP_EnablePlayer(0);
    if (this.options.coopMode && !this._replayChosenByPlayer) this._sim.APP_EnablePlayer(1);
  }
  clearGame() {
    this._sim = null;
    if (this._gfx !== null) { this._gfx.Clear(); this._gfx = null; }
    if (this._sfx !== null) { this._sfx.dispose(); this._sfx = null; }
  }

  // ---------------------------------------------------------------- tick
  tick() {
    this._thisTick = getTimer();
    this.pollGamepad();
    this.input.Tick();
    switch (this._uiState) {
      case MenuStates.PLAYING_GAME: this.tickGame(); break;
      case MenuStates.GAME_OVER: this.tickGameOver(); break;
      case MenuStates.WATCHING_REPLAY: this.tickReplay(); break;
    }
    if (this._gameOver) this._gameOver.tick();
    this._lastTick = this._thisTick;
  }
  /* Controller support: the first connected gamepad controls player 0.
   * The D-pad moves, D-pad up and the X/Cross face button jump.  The pad
   * presses the keys currently bound to those actions (so rebinding still
   * applies), and pressing a button also drives menu navigation. */
  pollGamepad() {
    let gp = null;
    if (typeof navigator !== "undefined" && navigator.getGamepads) {
      const pads = navigator.getGamepads();
      for (let i = 0; i < pads.length; i++) {
        if (pads[i] && pads[i].connected) { gp = pads[i]; break; }
      }
    }
    const pressed = (i) => !!(gp && gp.buttons[i] &&
      (gp.buttons[i].pressed || gp.buttons[i].value > 0.5));
    const axisX = gp && gp.axes.length > 0 ? gp.axes[0] : 0;
    const state = {
      left: pressed(14) || axisX < -0.5,    // D-pad left / left stick
      right: pressed(15) || axisX > 0.5,    // D-pad right / left stick
      up: pressed(12),                      // D-pad up (jump in game)
      down: pressed(13),                    // D-pad down (menus only)
      jump: pressed(2) || pressed(0),       // X / Cross (and A for pads that label it so)
    };
    const jumpKey = this.playerKeys.getActionKeyForPlayer(PlayerKeys.JUMP, 0);
    const leftKey = this.playerKeys.getActionKeyForPlayer(PlayerKeys.LEFT, 0);
    const rightKey = this.playerKeys.getActionKeyForPlayer(PlayerKeys.RIGHT, 0);
    const g = this.globalKeys;
    const actionKeys = {
      left: [leftKey, g.left],
      right: [rightKey, g.right],
      up: [jumpKey, g.up],
      down: [g.down],
      jump: [jumpKey],
    };
    const menuKey = { left: g.left, right: g.right, up: g.up, down: g.down, jump: g.select };
    if (!this._padState) this._padState = {};
    const codes = [];
    for (const action in actionKeys) {
      const now = state[action], was = !!this._padState[action];
      if (now) {
        for (const code of actionKeys[action]) {
          if (code != null && code >= 0 && !codes.includes(code)) codes.push(code);
        }
      }
      if (now && !was && this.currentScreen && this.currentScreen.handleKey) {
        this.currentScreen.handleKey(menuKey[action]);
      }
      this._padState[action] = now;
    }
    for (const code of this._padVirtual || []) {
      if (!codes.includes(code)) this.input.SetVirtualKey(code, false);
    }
    for (const code of codes) this.input.SetVirtualKey(code, true);
    this._padVirtual = codes;
  }
  tickGame() {
    switch (this._gameState) {
      case GameStates.PRE_GAME: this.tickPreGame(); break;
      case GameStates.GAME: this.tickGameInProgress(); break;
      case GameStates.POST_GAME: this.tickPostGame(); break;
      case GameStates.PAUSED_IN_GAME: this.tickPausedGame(); break;
    }
  }
  tickGameOver() { if (this.playerReadyToProceed()) this.exit(); }
  tickReplay() {
    switch (this._gameState) {
      case GameStates.GAME: this.tickReplayInProgress(); break;
      case GameStates.POST_GAME: this.tickReplayPostGame(); break;
    }
  }
  tickReplayInProgress() {
    if (this._replayChosenByPlayer) this.updateInGameDisplay();
    if (this._replayChosenByPlayer && this.input.IsKeyPressed(this.globalKeys.back)) {
      this.exitReplay();
    } else this.continueReplay();
  }
  tickReplayPostGame() {
    this.tickSimulator();
    this._gameOverCooldown = Math.max(0, this._gameOverCooldown - 1);
    if (this._gameOverCooldown > 0) return;
    this.endReplay();
  }
  continueReplay() {
    this.tickSimulator();
    if (this._sim.APP_IsGameDone()) {
      this._gameState = GameStates.POST_GAME;
      this._gameOverCooldown = 30;
      this._goldCountdown = 0;
    }
  }
  endReplay() {
    if (this._replayChosenByPlayer) this.exitReplay();
    else this.showNextReplay();
  }
  tickPreGame() {
    this.updateInGameDisplay();
    this._gfx.Render();
    if (this.playerReadyToProceed()) this.startGameImmediately();
    else if (this.playerWantsToExit()) this.exit();
  }
  startGameImmediately() {
    this._gameState = GameStates.GAME;
    this._start = getTimer();
    this._pausedTime = 0;
  }
  tickGameInProgress() {
    this.updateInGameDisplay();
    this._hud.prompt.visible = false;
    this.checkForSuicides();
    if (this.playerWantsToPause()) {
      this._gameState = GameStates.PAUSED_IN_GAME;
      this._hud.prompt.visible = true;
      this._hud.prompt.gotoAndStop("paused");
      return;
    }
    this.tickSimulator();
    if (this.finished) this.triggerGameEnd();
  }
  tickPostGame() {
    this.updateInGameDisplay();
    this.tickSimulator();
    this._gameOverCooldown = Math.max(0, this._gameOverCooldown - 1);
    if (this._gameOverCooldown > 0) return;
    if (this.playerReadyToProceed()) {
      this.showHUD();
      this.continueGame();
    } else if (this.playerWantsToExit()) this.exit();
    if (this._goldCollected > 0 && this.victory) this.tickGoldTransferToTimebar();
  }
  tickPausedGame() {
    const actions = this.playerKeys.getActions([PlayerKeys.JUMP, PlayerKeys.LEFT, PlayerKeys.RIGHT]);
    actions.push(this.globalKeys.pause);
    if (this.input.IsKeyPressed(this.globalKeys.quit)) this.exit();
    else if (this.input.IsOnePressed(actions)) this._gameState = GameStates.GAME;
    this._pausedTime += getTimer() - this._lastTick;
  }
  tickSimulator() {
    this._sim.Tick(null);
    if (!this.finished) {
      this._currentTicks--;
      this._ticksElapsed++;
      if (this._currentTicks <= 0) {
        this._currentTicks = 0;
        this._sim.APP_Event_TimeUp();
      } else if (this.options.scoreGoldImmediately) {
        this._currentTicks += this._sim.APP_GetNumGoldCollectedDuringTick(0) * this._ticksPerGold;
        if (this.options.coopMode && !this._isReplay)
          this._currentTicks += this._sim.APP_GetNumGoldCollectedDuringTick(1) * this._ticksPerGold;
      } else {
        this._goldCollected += this._sim.APP_GetNumGoldCollectedDuringTick(0);
        if (this.options.coopMode && !this._isReplay)
          this._goldCollected += this._sim.APP_GetNumGoldCollectedDuringTick(1);
      }
    }
    this._gfx.Render();
    this._sfx.Tick();
  }
  tickGoldTransferToTimebar() {
    this._goldCountdown--;
    if (this._goldCountdown <= 0) this.transferOneUnitOfGoldToTimebar();
  }
  transferOneUnitOfGoldToTimebar() {
    this._goldCollected--;
    this._currentTicks += this._ticksPerGold;
    this._goldCountdown = this._GOLD_DELAY;
  }
  instantlyTransferRemainingGoldToTimebar() {
    this._currentTicks += this._goldCollected * this._ticksPerGold;
    this._goldCollected = 0;
  }
  triggerGameEnd() {
    const elapsed = getTimer() - this._start - this._pausedTime;
    const expected = elapsed / 17;
    const diff = expected - this._ticksElapsed;
    this._gameTooSlow = expected > 0 && diff / expected > 0.15;
    this._gameState = GameStates.POST_GAME;
    this._gameOverCooldown = 30;
    this._hud.prompt.visible = true;
    if (this._playingLevelset) {
      if (this.victory) this._hud.prompt.gotoAndPlay("win");
      else this._hud.prompt.gotoAndPlay("lose");
    } else {
      this.storeGameStats();
      this.showLevelResultDialog();
    }
  }
  continueGame() {
    if (this.victory) this.instantlyTransferRemainingGoldToTimebar();
    if (this._playingLevelset) {
      if (this.victory) this.advanceToNextLevel();
      else if (this._currentTicks <= 0) this.gameOverTimeUp();
      else {
        if (this.options.resetScoreOnDeath) {
          this._currentTicks = this._startingTicks;
          this._ticksElapsed = 0;
        }
        this._goldCollected = 0;
        this.prepareSessionFromBytes(this._levelData, null);
      }
    } else if (this.playerReadyToProceed()) {
      this._currentTicks = this._startingTicks;
      this._ticksElapsed = 0;
      this.prepareSessionFromBytes(this._levelData, null);
    } else {
      this.exit();
    }
    this._gameState = GameStates.PRE_GAME;
  }
  advanceToNextLevel() {
    this._currentLevelInSet++;
    this._startingTicks = this._currentTicks;
    if (this._currentLevelInSet >= this._levelSet.length) {
      if (this.options.selectedEpisode !== -1) {
        this.episodes.beatEpisodeFromGameplay(this.options.selectedEpisode);
        // The original dispatches COMPLETE_EPISODE, then increments this.
        this.options.selectedEpisode++;
      }
      this.showEpisodeVictoryDialog();
    } else {
      if (this._playingLevelset) this.saveProgress();
      this._levelData = this._levelSet[this._currentLevelInSet];
      this.prepareSessionFromBytes(this._levelData, null);
    }
  }
  saveProgress() {
    this.sharedObject.setProperty(SavedProperties.SAVED_LEVEL, this._currentLevelInSet);
    this.sharedObject.setProperty(SavedProperties.SAVED_TICKS_REMAINING, this._currentTicks);
    try { this.sharedObject.flush(); } catch (e) {}
  }
  clearSavedProgress() {
    delete this.sharedObject.data[SavedProperties.SAVED_CHALLENGE];
    delete this.sharedObject.data[SavedProperties.SAVED_EPISODE];
    delete this.sharedObject.data[SavedProperties.SAVED_LEVEL];
    delete this.sharedObject.data[SavedProperties.SAVED_TICKS_REMAINING];
    try { this.sharedObject.flush(); } catch (e) {}
  }
  showEpisodeVictoryDialog() {
    this.clearSavedProgress();
    this.showGameOver("episode");
    this._uiState = MenuStates.GAME_OVER;
  }
  gameOverTimeUp() {
    if (this._playingLevelset) {
      if (!this.options.resetScoreOnDeath) this.clearSavedProgress();
      this.showGameOver("failure-episode");
    } else this.showGameOver("failure");
    this._uiState = MenuStates.GAME_OVER;
  }
  showLevelResultDialog() {
    this.clearSavedProgress();
    if (!this.victory) {
      this.showGameOver(this._currentTicks > 0 ? "failure-ouch" : "failure-time");
    } else this.showGameOver("nothing");
  }
  storeGameStats() {
    // NOT IMPLEMENTED: online score submission/highscores.  There is no
    // network backend in this build; the original posted to nserver.
    if (this._isReplay || !this.victory) return;
  }
  checkHighscore() {
    // NOT IMPLEMENTED: server-side highscore lookup.
  }
  exit() {
    if (this._playingLevelset && this.victory && this._currentLevelInSet < this._levelSet.length) {
      this.instantlyTransferRemainingGoldToTimebar();
      this.advanceToNextLevel();
      this.storeGameStats();
    }
    this.clearGame();
    this.hideAllGUI();
    this._uiState = MenuStates.MAIN_MENU;
    this.showLastScreen();
  }
  exitReplay() {
    this.clearGame();
    this.hideAllGUI();
    this._uiState = MenuStates.MAIN_MENU;
    this.showLastScreen();
  }

  // ---------------------------------------------------------------- HUD/game over
  initializeInGameUI() {
    if (!this._hud) return;
    this._hud.gold_collected.visible = !this.options.scoreGoldImmediately;
    this._hud.setLevelName(this._levelName);
  }
  updateInGameDisplay() { this.updateTimebar(); this.updateGoldCounter(); }
  updateTimebar() {
    if (!this._hud) return;
    this._hud.setTime(this._currentTicks, this.sim_rate);
  }
  updateGoldCounter() {
    if (!this._hud) return;
    this._hud.setGold(this._goldCollected);
  }
  showHUD() {
    if (!this._hud) {
      this._hud = new HUD(this);
      this.initializeInGameUI();
      this.uiLayer.addChild(this._hud);
    }
    if (this._gameOver) {
      this.uiLayer.removeChild(this._gameOver);
      this._gameOver = null;
    }
  }
  showGameOver(label) {
    if (!this._gameOver) {
      this._gameOver = new GameOverPopup(this);
      this.uiLayer.addChild(this._gameOver);
    }
    if (this._hud) {
      this.uiLayer.removeChild(this._hud);
      this._hud = null;
    }
    this._gameOver.gotoAndPlay(label);
    this._gameOver.kong_logo2.visible = false;
  }
  hideAllGUI() {
    if (this._gameOver) {
      this.uiLayer.removeChild(this._gameOver);
      this._gameOver = null;
    }
    if (this._hud) {
      disposeDisplayTree(this._hud);
      this.uiLayer.removeChild(this._hud);
      this._hud = null;
    }
  }

  // ---------------------------------------------------------------- input helpers
  checkForSuicides() {
    const n = this.options.coopMode ? 2 : 1;
    for (let i = 0; i < n; i++) this.checkForPlayerSuicide(i);
  }
  checkForPlayerSuicide(i) {
    if (!this._sim.APP_IsPlayerDead(i)) {
      if (this.input.IsKeyPressed(this.playerKeys.getActionKeyForPlayer(PlayerKeys.SUICIDE, i)))
        this._sim.APP_Event_Suicide(i);
    }
  }
  playerReadyToProceed() {
    if (this.input.IsKeyPressed(this.playerKeys.getActionKeyForPlayer(PlayerKeys.JUMP, 0))) return true;
    if (this.input.IsKeyPressed(Keyboard.SPACE)) return true;
    return false;
  }
  playerWantsToExit() { return this.input.IsKeyPressed(this.globalKeys.back); }
  playerWantsToPause() {
    if (this.input.IsKeyPressed(this.globalKeys.back)) return true;
    if (this.input.IsKeyPressed(this.globalKeys.pause)) return true;
    return false;
  }
  get finished() { return this._sim ? this._sim.APP_IsGameDone() : false; }
  get victory() { return this._sim ? this._sim.APP_DidPlayerWin() : false; }
  get uiState() { return this._uiState; }
  get gameState() { return this._gameState; }

  // ---------------------------------------------------------------- DOM input
  installInput(canvas, renderer) {
    const toStage = (ev) => {
      const rect = canvas.getBoundingClientRect();
      const bx = (ev.clientX - rect.left) * (canvas.width / rect.width);
      const by = (ev.clientY - rect.top) * (canvas.height / rect.height);
      return { x: (bx - renderer.viewX) / renderer.scale, y: (by - renderer.viewY) / renderer.scale };
    };
    const pick = (obj, x, y) => {
      if (!obj.visible) return null;
      if (obj.children && obj.mouseChildren !== false) {
        for (let i = obj.children.length - 1; i >= 0; i--) {
          const r = pick(obj.children[i], x, y);
          if (r) return r;
        }
      }
      if (obj.mouseEnabled && obj.hitTestPoint(x, y)) return obj;
      return null;
    };
    const fire = (target, ev) => {
      if (!target) target = this.stage;
      target.dispatchEvent(ev);
    };
    canvas.addEventListener("mousemove", (e) => {
      const p = toStage(e);
      const t = pick(this.stage, p.x, p.y);
      if (t !== this._mouseOverTarget) {
        if (this._mouseOverTarget)
          this._mouseOverTarget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, true, p.x, p.y));
        this._mouseOverTarget = t;
        if (t) t.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER, true, p.x, p.y));
      }
      fire(t, new MouseEvent(MouseEvent.MOUSE_MOVE, true, p.x, p.y));
      canvas.style.cursor = t && t.buttonMode ? "pointer" : "default";
    });
    canvas.addEventListener("mousedown", (e) => {
      AudioSystem.resume();
      const p = toStage(e);
      const t = pick(this.stage, p.x, p.y);
      this._mouseDownTarget = t;
      fire(t, new MouseEvent(MouseEvent.MOUSE_DOWN, true, p.x, p.y, true));
    });
    canvas.addEventListener("mouseup", (e) => {
      const p = toStage(e);
      const t = pick(this.stage, p.x, p.y);
      fire(t, new MouseEvent(MouseEvent.MOUSE_UP, true, p.x, p.y, false));
      if (t && t === this._mouseDownTarget) fire(t, new MouseEvent(MouseEvent.CLICK, true, p.x, p.y, false));
      this._mouseDownTarget = null;
    });
    window.addEventListener("keydown", (e) => {
      AudioSystem.resume();
      Keyboard.capsLock = e.getModifierState ? e.getModifierState("CapsLock") : false;
      if ([32, 37, 38, 39, 40, 8].includes(e.keyCode)) e.preventDefault();
      const ke = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, e.keyCode);
      ke.ctrlKey = e.ctrlKey; ke.shiftKey = e.shiftKey;
      this.stage.dispatchEvent(ke);
      if (!e.repeat && this.currentScreen && this.currentScreen.handleKey) {
        this.currentScreen.handleKey(e.keyCode);
      }
    });
    window.addEventListener("keyup", (e) => {
      const ke = new KeyboardEvent(KeyboardEvent.KEY_UP, true, e.keyCode);
      ke.ctrlKey = e.ctrlKey; ke.shiftKey = e.shiftKey;
      this.stage.dispatchEvent(ke);
    });
    // Browsers do not deliver keyup while the tab/window is unfocused, so
    // release everything when focus is lost (Flash did this itself).
    window.addEventListener("blur", () => {
      this.input.keys.fill(false);
      this.input.mouseIsDown = false;
      this._mouseDownTarget = null;
      this._mouseOverTarget = null;
    });
  }
}
