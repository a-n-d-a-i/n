package com.metanet
{
   import audiovisual.GraphicsManager;
   import audiovisual.SoundManager;
   import com.metanet.data.AccountDetails;
   import com.metanet.data.AttractMode;
   import com.metanet.data.EpisodeData;
   import com.metanet.data.GameStats;
   import com.metanet.data.Level;
   import com.metanet.data.Options;
   import com.metanet.events.InGameEvent;
   import com.metanet.events.MenuEvent;
   import com.metanet.events.ReplayEvent;
   import com.metanet.global.GameStates;
   import com.metanet.global.MenuStates;
   import com.metanet.global.SavedProperties;
   import com.metanet.ui.GlobalKeys;
   import com.metanet.ui.PlayerKeys;
   import com.metanet.ui.TimeFormatter;
   import editor.Editor_State;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.net.SharedObject;
   import flash.ui.Keyboard;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import org.robotlegs.mvcs.Actor;
   import simpleFramework.SimpleInput;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.sim_globals;
   import simulation.sim_loader;
   
   public class App_MultiPurpose extends Actor implements App
   {
      
      private static const POSTGAME_DELAY:int = 30;
      
      [Inject]
      public var attractMode:AttractMode;
      
      [Inject]
      public var input:SimpleInput;
      
      [Inject]
      public var globalKeys:GlobalKeys;
      
      [Inject]
      public var debugRenderer:SimpleRenderer;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var episodeData:EpisodeData;
      
      [Inject]
      public var stats:GameStats;
      
      [Inject]
      public var sharedObject:SharedObject;
      
      [Inject(name="coop")]
      public var coopKeys:PlayerKeys;
      
      [Inject(name="solo")]
      public var soloKeys:PlayerKeys;
      
      [Inject(name="gameStage")]
      public var gameStage:Sprite;
      
      [Inject(name="uiStage")]
      public var uiStage:Sprite;
      
      [Inject]
      public var account:AccountDetails;
      
      private var _timeFormatter:TimeFormatter;
      
      private var _sim:Simulator;
      
      private var _gfx:GraphicsManager;
      
      private var _sfx:SoundManager;
      
      private var _playerKeys:PlayerKeys;
      
      private var _performanceGraph:Bitmap;
      
      private var _hud:HUD;
      
      private var _gameOver:GameOverPopup;
      
      private var _uiState:int = -1;
      
      private var _gameState:int;
      
      private var _isHighscore:Boolean;
      
      private var _isPersonalBest:Boolean;
      
      private var _levelSet:Vector.<ByteArray>;
      
      private var _currentLevelInSet:int;
      
      private var _gameOverCooldown:int;
      
      private var _startingTicks:int;
      
      private var _defaultStartingTicks:int;
      
      private var _currentTicks:int;
      
      private var _ticksElapsed:int;
      
      private var _currentLevel:String;
      
      private var _playingLevelset:Boolean;
      
      private var _levelData:ByteArray;
      
      private var _replayChosenByPlayer:Boolean = false;
      
      private var _levelName:String;
      
      private var _ticksPerGold:int;
      
      private var _thisTick:int;
      
      private var _lastTick:int;
      
      private var _goldCollected:int;
      
      private var GOLD_DELAY:int = 8;
      
      private var _goldCountdown:int;
      
      private var _isReplay:Boolean;
      
      private var _start:int;
      
      private var _gameTooSlow:Boolean;
      
      private var _pausedTime:int;
      
      private var SLOW_THRESHOLD:Number = 0.15;
      
      public function App_MultiPurpose()
      {
         super();
         this._timeFormatter = new TimeFormatter();
      }
      
      public function initialize() : void
      {
         sim_globals.sim_rate = 60;
         this._defaultStartingTicks = 90 * sim_globals.sim_rate;
         this._startingTicks = this._defaultStartingTicks;
         this._ticksPerGold = 2 * sim_globals.sim_rate;
         this._gameOverCooldown = 0;
         this._uiState = MenuStates.MAIN_MENU;
         this._gameState = GameStates.UNLOADED;
      }
      
      public function useLevelSet(param1:Vector.<ByteArray>) : void
      {
         this._levelSet = param1;
      }
      
      public function startLevelSet() : void
      {
         this._currentLevelInSet = 0;
         this._startingTicks = this._defaultStartingTicks;
         this.playLevelSet();
      }
      
      public function resumeLevelSet(param1:int, param2:int) : void
      {
         this._currentLevelInSet = param1;
         this._startingTicks = param2;
         this.playLevelSet();
      }
      
      private function playLevelSet() : void
      {
         this._currentTicks = this._startingTicks;
         this._ticksElapsed = 0;
         this._playingLevelset = true;
         this.playLevel(this._levelSet[this._currentLevelInSet]);
         this.saveProgress();
      }
      
      public function playSingleLevelFromBytes(param1:ByteArray, param2:String) : void
      {
         this.playLevel(param1);
         this._currentLevel = param2;
         this._startingTicks = this._defaultStartingTicks;
         this._currentTicks = this._startingTicks;
         this._ticksElapsed = 0;
         this._playingLevelset = false;
      }
      
      private function playLevel(param1:ByteArray) : void
      {
         this._levelData = param1;
         this._isReplay = false;
         this.prepareSessionFromBytes(this._levelData,null);
         this._goldCollected = 0;
         this._uiState = MenuStates.PLAYING_GAME;
         this._gameState = GameStates.PRE_GAME;
         this._hud = new HUD();
         this.initializeInGameUI();
         this.uiStage.addChild(this._hud);
      }
      
      public function showRandomReplay() : void
      {
         this._isReplay = true;
         this._replayChosenByPlayer = false;
         dispatch(new ReplayEvent(ReplayEvent.RANDOM));
      }
      
      public function showNextReplay() : void
      {
         this._isReplay = true;
         this._replayChosenByPlayer = false;
         dispatch(new ReplayEvent(ReplayEvent.NEXT));
      }
      
      public function watchPlayerSelectedReplay(param1:ByteArray, param2:ByteArray) : void
      {
         this._replayChosenByPlayer = true;
         this.showReplay(param1,param2);
      }
      
      public function showReplay(param1:ByteArray, param2:ByteArray) : void
      {
         param1.position = 0;
         param2.position = 0;
         this._startingTicks = this._defaultStartingTicks;
         this._currentTicks = this._startingTicks;
         this._ticksElapsed = 0;
         this._isReplay = true;
         this.prepareSessionFromBytes(param1,param2);
         this.startReplay();
         this._uiState = MenuStates.WATCHING_REPLAY;
         this._gameState = GameStates.GAME;
      }
      
      public function stopReplay() : void
      {
         this._gameState = GameStates.UNLOADED;
         this.clearGame();
         this.hideAllGUI();
         this.setState(MenuStates.MAIN_MENU);
      }
      
      public function getReplay() : ByteArray
      {
         return this._sim.APP_GetReplayBytes()[0];
      }
      
      public function tick() : void
      {
         this._thisTick = getTimer();
         this.input.Tick();
         this.debugRenderer.Clear();
         switch(this._uiState)
         {
            case MenuStates.PLAYING_GAME:
               this.tickGame();
               break;
            case MenuStates.GAME_OVER:
               this.tickGameOver();
               break;
            case MenuStates.WATCHING_REPLAY:
               this.tickReplay();
         }
         this.checkDebugKeys();
         this._lastTick = this._thisTick;
      }
      
      private function checkDebugKeys() : void
      {
         if(this.input.IsKeyDown(Keyboard.INSERT) || this.input.CapsLock())
         {
            this.debugRenderer.DrawStringAtPosition("ms/f: " + (this._thisTick - this._lastTick),1,530);
            if(this._performanceGraph)
            {
               this._performanceGraph.visible = true;
            }
         }
         else if(this._performanceGraph)
         {
            this._performanceGraph.visible = false;
         }
      }
      
      private function prepareSessionFromBytes(param1:ByteArray, param2:ByteArray) : void
      {
         var _loc3_:ByteArray = null;
         var _loc6_:int = 0;
         this.clearGame();
         if(param2)
         {
            _loc3_ = new ByteArray();
            param2.readBytes(_loc3_,0,param2.bytesAvailable);
         }
         this._levelName = param1.readUTF();
         this.initializeInGameUI();
         var _loc4_:ByteArray = new ByteArray();
         param1.readBytes(_loc4_);
         param1.position = 0;
         var _loc5_:Editor_State = Editor_State.Load_From_Bytes(_loc4_);
         if(this.options.coopMode && !this._replayChosenByPlayer)
         {
            _loc6_ = 2;
            this._playerKeys = this.coopKeys;
         }
         else
         {
            _loc6_ = 1;
            this._playerKeys = this.soloKeys;
         }
         var _loc7_:Vector.<int> = this._playerKeys.getActions([PlayerKeys.JUMP,PlayerKeys.LEFT,PlayerKeys.RIGHT]);
         this._sim = sim_loader.LoadLevel_EditorState(_loc7_,[this.options.p1Colour,this.options.p2Colour],this.input,_loc3_,_loc6_,_loc5_);
         this.initializeEngine();
      }
      
      private function startReplay() : void
      {
         if(this._replayChosenByPlayer)
         {
            this._hud = new HUD();
            this._hud.prompt.visible = false;
            this.initializeInGameUI();
            this.uiStage.addChild(this._hud);
         }
         else
         {
            this.hideAllGUI();
         }
         this.setState(this._uiState);
         this.startGameImmediately();
      }
      
      private function initializeEngine() : void
      {
         this._gfx = new GraphicsManager(this.gameStage,this._sim.GFX_GetEntityList(),this._sim.GFX_GetPlayerList(),this._sim.GFX_GetTileIDs(),Simulator.GRID_NUM_ROWS,Simulator.GRID_NUM_COLS,true);
         this._sfx = new SoundManager();
         this._sim.HACKY_SetAV(this._gfx,this._sfx);
         this._gfx.Render();
         this._sim.APP_EnablePlayer(0);
         if(this.options.coopMode && !this._replayChosenByPlayer)
         {
            this._sim.APP_EnablePlayer(1);
         }
      }
      
      private function tickGame() : void
      {
         switch(this._gameState)
         {
            case GameStates.PRE_GAME:
               this.tickPreGame();
               break;
            case GameStates.GAME:
               this.tickGameInProgress();
               break;
            case GameStates.POST_GAME:
               this.tickPostGame();
               break;
            case GameStates.PAUSED_IN_GAME:
               this.tickPausedGame();
         }
      }
      
      private function tickGameOver() : void
      {
         if(this.playerReadyToProceed())
         {
            this.exit();
         }
      }
      
      private function tickReplay() : void
      {
         switch(this._gameState)
         {
            case GameStates.GAME:
               this.tickReplayInProgress();
               break;
            case GameStates.POST_GAME:
               this.tickReplayPostGame();
         }
      }
      
      private function tickPreGame() : void
      {
         this.updateInGameDisplay();
         this._gfx.Render();
         if(this.playerReadyToProceed())
         {
            this.startGameImmediately();
         }
         else if(this.playerWantsToExit())
         {
            this.exit();
         }
      }
      
      private function startGameImmediately() : void
      {
         this._gameState = GameStates.GAME;
         this._start = getTimer();
         this._pausedTime = 0;
      }
      
      private function exit() : void
      {
         if(this._playingLevelset && this.victory && this._currentLevelInSet < this._levelSet.length)
         {
            this.instantlyTransferRemainingGoldToTimebar();
            this.advanceToNextLevel();
            this.storeGameStats();
         }
         this.clearGame();
         this.hideAllGUI();
         this.setState(MenuStates.MAIN_MENU);
         dispatch(new MenuEvent(MenuEvent.SHOW_LAST_SCREEN));
      }
      
      private function exitReplay() : void
      {
         this.clearGame();
         this.hideAllGUI();
         this.setState(MenuStates.MAIN_MENU);
         dispatch(new MenuEvent(MenuEvent.SHOW_LAST_SCREEN));
      }
      
      private function tickGameInProgress() : void
      {
         this.updateInGameDisplay();
         this._hud.prompt.visible = false;
         this.checkForSuicides();
         if(this.playerWantsToPause())
         {
            this._gameState = GameStates.PAUSED_IN_GAME;
            this._hud.prompt.visible = true;
            this._hud.prompt.gotoAndStop("paused");
            return;
         }
         this.tickSimulator();
         if(this.finished)
         {
            this.triggerGameEnd();
         }
      }
      
      private function tickPostGame() : void
      {
         this.updateInGameDisplay();
         this.tickSimulator();
         this._gameOverCooldown = Math.max(0,this._gameOverCooldown - 1);
         if(this._gameOverCooldown > 0)
         {
            return;
         }
         if(this.playerReadyToProceed())
         {
            this.showHUD();
            this.continueGame();
         }
         else if(this.playerWantsToExit())
         {
            this.exit();
         }
         if(this._goldCollected > 0 && this.victory)
         {
            this.tickGoldTransferToTimebar();
         }
      }
      
      private function tickGoldTransferToTimebar() : void
      {
         --this._goldCountdown;
         if(this._goldCountdown <= 0)
         {
            this.transferOneUnitOfGoldToTimebar();
         }
      }
      
      private function transferOneUnitOfGoldToTimebar() : void
      {
         --this._goldCollected;
         this._currentTicks += this._ticksPerGold;
         this._goldCountdown = this.GOLD_DELAY;
      }
      
      private function instantlyTransferRemainingGoldToTimebar() : void
      {
         this._currentTicks += this._goldCollected * this._ticksPerGold;
         this._goldCollected = 0;
      }
      
      private function tickPausedGame() : void
      {
         var _loc1_:Vector.<int> = this._playerKeys.getActions([PlayerKeys.JUMP,PlayerKeys.LEFT,PlayerKeys.RIGHT]);
         _loc1_[_loc1_.length] = this.globalKeys.pause;
         if(this.input.IsKeyPressed(this.globalKeys.quit))
         {
            this.exit();
         }
         else if(this.input.IsOnePressed(_loc1_))
         {
            this._gameState = GameStates.GAME;
         }
         this._pausedTime += getTimer() - this._lastTick;
      }
      
      private function tickReplayInProgress() : void
      {
         if(this._replayChosenByPlayer)
         {
            this.updateInGameDisplay();
         }
         if(this.input.IsKeyPressed(this.globalKeys.back) && this._replayChosenByPlayer)
         {
            this.exitReplay();
         }
         else
         {
            this.continueReplay();
         }
      }
      
      private function tickReplayPostGame() : void
      {
         this.tickSimulator();
         this._gameOverCooldown = Math.max(0,this._gameOverCooldown - 1);
         if(this._gameOverCooldown > 0)
         {
            return;
         }
         this.endReplay();
      }
      
      private function endReplay() : void
      {
         if(this._replayChosenByPlayer)
         {
            this.exitReplay();
         }
         else
         {
            this.showNextReplay();
         }
      }
      
      private function continueGame() : void
      {
         if(this.victory)
         {
            this.instantlyTransferRemainingGoldToTimebar();
         }
         if(this._playingLevelset)
         {
            if(this.victory)
            {
               this.advanceToNextLevel();
            }
            else if(this._currentTicks <= 0)
            {
               this.gameOverTimeUp();
            }
            else
            {
               if(this.options.resetScoreOnDeath)
               {
                  this._currentTicks = this._startingTicks;
                  this._ticksElapsed = 0;
               }
               this._goldCollected = 0;
               this.prepareSessionFromBytes(this._levelData,null);
            }
         }
         else if(this.playerReadyToProceed())
         {
            this._currentTicks = this._startingTicks;
            this._ticksElapsed = 0;
            this.prepareSessionFromBytes(this._levelData,null);
         }
         else
         {
            this.exit();
         }
         this._gameState = GameStates.PRE_GAME;
      }
      
      private function advanceToNextLevel() : void
      {
         ++this._currentLevelInSet;
         this._startingTicks = this._currentTicks;
         if(this._currentLevelInSet >= this._levelSet.length)
         {
            if(this.options.selectedEpisode != -1)
            {
               dispatch(new InGameEvent(InGameEvent.COMPLETE_EPISODE));
               ++this.options.selectedEpisode;
            }
            this.showEpisodeVictoryDialog();
         }
         else
         {
            if(this._playingLevelset)
            {
               this.saveProgress();
            }
            this._levelData = this._levelSet[this._currentLevelInSet];
            this.prepareSessionFromBytes(this._levelData,null);
         }
      }
      
      private function saveProgress() : void
      {
         this.sharedObject.setProperty(SavedProperties.SAVED_LEVEL,this._currentLevelInSet);
         this.sharedObject.setProperty(SavedProperties.SAVED_TICKS_REMAINING,this._currentTicks);
         try
         {
            this.sharedObject.flush();
         }
         catch(e:Error)
         {
         }
      }
      
      private function showEpisodeVictoryDialog() : void
      {
         this.clearSavedProgress();
         this.showGameOver("episode");
         this.setState(MenuStates.GAME_OVER);
      }
      
      private function clearSavedProgress() : void
      {
         delete this.sharedObject.data[SavedProperties.SAVED_CHALLENGE];
         delete this.sharedObject.data[SavedProperties.SAVED_EPISODE];
         delete this.sharedObject.data[SavedProperties.SAVED_LEVEL];
         delete this.sharedObject.data[SavedProperties.SAVED_TICKS_REMAINING];
         try
         {
            this.sharedObject.flush();
         }
         catch(e:Error)
         {
         }
      }
      
      private function gameOverTimeUp() : void
      {
         if(this._playingLevelset)
         {
            if(!this.options.resetScoreOnDeath)
            {
               this.clearSavedProgress();
            }
            this.showGameOver("failure-episode");
         }
         else
         {
            this.showGameOver("failure");
         }
         this.setState(MenuStates.GAME_OVER);
      }
      
      private function continueReplay() : void
      {
         this.tickSimulator();
         if(this._sim.APP_IsGameDone())
         {
            this._gameState = GameStates.POST_GAME;
            this._gameOverCooldown = POSTGAME_DELAY;
            this._goldCountdown = 0;
         }
      }
      
      private function clearGame() : void
      {
         this._sim = null;
         if(this._gfx != null)
         {
            this._gfx.Clear();
            this._gfx = null;
         }
         this._sfx = null;
      }
      
      private function tickSimulator() : void
      {
         this._sim.Tick(this.debugRenderer);
         if(!this.finished)
         {
            --this._currentTicks;
            ++this._ticksElapsed;
            if(this._currentTicks <= 0)
            {
               this._currentTicks = 0;
               this._sim.APP_Event_TimeUp();
            }
            else if(this.options.scoreGoldImmediately)
            {
               this._currentTicks += this._sim.APP_GetNumGoldCollectedDuringTick(0) * this._ticksPerGold;
               if(this.options.coopMode && !this._isReplay)
               {
                  this._currentTicks += this._sim.APP_GetNumGoldCollectedDuringTick(1) * this._ticksPerGold;
               }
            }
            else
            {
               this._goldCollected += this._sim.APP_GetNumGoldCollectedDuringTick(0);
               if(this.options.coopMode && !this._isReplay)
               {
                  this._goldCollected += this._sim.APP_GetNumGoldCollectedDuringTick(1);
               }
            }
         }
         this._gfx.Render();
         this._sfx.Tick();
      }
      
      private function triggerGameEnd() : void
      {
         var _loc1_:uint = uint(getTimer());
         var _loc2_:uint = uint(_loc1_ - this._start - this._pausedTime);
         var _loc3_:Number = _loc2_ / 17;
         var _loc4_:int = _loc3_ - this._ticksElapsed;
         this._gameTooSlow = _loc4_ / _loc3_ > this.SLOW_THRESHOLD;
         this._gameState = GameStates.POST_GAME;
         this._gameOverCooldown = POSTGAME_DELAY;
         this._hud.prompt.visible = true;
         if(this._playingLevelset)
         {
            if(this.victory)
            {
               this._hud.prompt.gotoAndPlay("win");
            }
            else
            {
               this._hud.prompt.gotoAndPlay("lose");
            }
         }
         else
         {
            this.storeGameStats();
            this.showLevelResultDialog();
         }
      }
      
      private function storeGameStats() : void
      {
         if(this._isReplay || !this.victory)
         {
            return;
         }
         this.stats.score = this._currentTicks + this._ticksPerGold * this._goldCollected;
         this.stats.isEpisode = this._playingLevelset;
         this.stats.level = this._currentLevel;
         this.checkHighscore();
         if(this._currentTicks != this._startingTicks)
         {
            try
            {
               this.stats.replayBytes = this._sim.APP_GetReplayBytes()[0];
            }
            catch(in_error:Error)
            {
            }
         }
         if(this._isPersonalBest && !this.options.coopMode && !this._playingLevelset && !this._gameTooSlow)
         {
            dispatch(new InGameEvent(InGameEvent.SUBMIT_SCORE));
         }
      }
      
      private function showLevelResultDialog() : void
      {
         this.clearSavedProgress();
         if(!this.victory)
         {
            if(this._currentTicks > 0)
            {
               this.showGameOver("failure-ouch");
            }
            else
            {
               this.showGameOver("failure-time");
            }
         }
         else if(this._isPersonalBest)
         {
            if(this._gameTooSlow)
            {
               this.showGameOver("failure-tooslow");
            }
            else if(this._isHighscore)
            {
               this.showGameOver("highscore");
            }
            else
            {
               this.showGameOver("personal");
            }
         }
         else
         {
            this.showGameOver("nothing");
         }
      }
      
      private function checkHighscore() : void
      {
         if(this._playingLevelset || this.options.coopMode)
         {
            return;
         }
         var _loc1_:Level = this.options.selectedLevel;
         if(this.victory)
         {
            this._isHighscore = this._currentTicks > _loc1_.minimumHighscore;
            if(this._isHighscore)
            {
               _loc1_.minimumHighscore = this._currentTicks;
            }
            this._isPersonalBest = this._currentTicks > _loc1_.personalBest;
            if(this._isPersonalBest)
            {
               _loc1_.personalBest = this._currentTicks;
            }
         }
         else
         {
            this._isPersonalBest = false;
         }
      }
      
      private function setState(param1:int) : void
      {
         this._uiState = param1;
      }
      
      private function showHUD() : void
      {
         if(!this._hud)
         {
            this._hud = new HUD();
            this.initializeInGameUI();
            this.uiStage.addChild(this._hud);
         }
         if(this._gameOver)
         {
            this.uiStage.removeChild(this._gameOver);
            this._gameOver = null;
         }
      }
      
      private function showGameOver(param1:String) : void
      {
         if(!this._gameOver)
         {
            this._gameOver = new GameOverPopup();
            this.uiStage.addChild(this._gameOver);
         }
         if(this._hud)
         {
            this.uiStage.removeChild(this._hud);
            this._hud = null;
         }
         this._gameOver.gotoAndPlay(param1);
         if(!this.account.isWeb)
         {
            this._gameOver.kong_logo2.visible = false;
         }
      }
      
      private function hideAllGUI() : void
      {
         if(this._gameOver)
         {
            this.uiStage.removeChild(this._gameOver);
            this._gameOver = null;
         }
         if(this._hud)
         {
            this.uiStage.removeChild(this._hud);
            this._hud = null;
         }
      }
      
      private function initializeInGameUI() : void
      {
         if(!this._hud)
         {
            return;
         }
         this._hud.gold_collected.visible = !this.options.scoreGoldImmediately;
         this._hud.leveltext.text = this._levelName;
      }
      
      private function updateInGameDisplay() : void
      {
         this.updateTimebar();
         this.updateGoldCounter();
      }
      
      private function updateTimebar() : void
      {
         if(!this._hud)
         {
            return;
         }
         var _loc1_:Number = 360 * sim_globals.sim_rate;
         var _loc2_:Number = Math.max(0,Math.min(1,this._currentTicks / _loc1_));
         var _loc3_:int = 1 + Math.round(_loc2_ * this._hud.timebar.framesLoaded);
         this._hud.timebar.gotoAndStop(_loc3_);
         var _loc4_:String = this._timeFormatter.formatTime(this._currentTicks,sim_globals.sim_rate);
         this._hud.timetext.timetext0.text = _loc4_.charAt(0);
         this._hud.timetext.timetext1.text = _loc4_.charAt(1);
         this._hud.timetext.timetext2.text = _loc4_.charAt(2);
         this._hud.timetext.timetext3.text = _loc4_.charAt(3);
         this._hud.timetext.timetext4.text = _loc4_.charAt(4);
         this._hud.timetext.timetext5.text = _loc4_.charAt(5);
         this._hud.timetext.timetext5.text = _loc4_.charAt(6);
      }
      
      private function updateGoldCounter() : void
      {
         if(!this._hud)
         {
            return;
         }
         this._hud.gold_collected.numgold.text = String(this._goldCollected);
      }
      
      private function checkForSuicides() : void
      {
         var _loc1_:int = this.options.coopMode ? 2 : 1;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            this.checkForPlayerSuicide(_loc2_);
            _loc2_++;
         }
      }
      
      private function checkForPlayerSuicide(param1:int) : void
      {
         if(!this._sim.APP_IsPlayerDead(param1))
         {
            if(this.input.IsKeyPressed(this._playerKeys.getActionKeyForPlayer(PlayerKeys.SUICIDE,param1)))
            {
               this._sim.APP_Event_Suicide(param1);
            }
         }
      }
      
      private function playerReadyToProceed() : Boolean
      {
         if(this.input.IsKeyPressed(this._playerKeys.getActionKeyForPlayer(PlayerKeys.JUMP,0)))
         {
            return true;
         }
         if(this.input.IsKeyPressed(Keyboard.SPACE))
         {
            return true;
         }
         return false;
      }
      
      private function playerWantsToExit() : Boolean
      {
         return this.input.IsKeyPressed(this.globalKeys.back);
      }
      
      private function playerWantsToPause() : Boolean
      {
         if(this.input.IsKeyPressed(this.globalKeys.back))
         {
            return true;
         }
         if(this.input.IsKeyPressed(this.globalKeys.pause))
         {
            return true;
         }
         return false;
      }
      
      private function get finished() : Boolean
      {
         return this._sim.APP_IsGameDone();
      }
      
      private function get victory() : Boolean
      {
         return this._sim.APP_DidPlayerWin();
      }
      
      public function get gameState() : int
      {
         return this._gameState;
      }
      
      public function get uiState() : int
      {
         return this._uiState;
      }
   }
}

