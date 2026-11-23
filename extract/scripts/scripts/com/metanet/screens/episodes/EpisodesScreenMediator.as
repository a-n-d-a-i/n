package com.metanet.screens.episodes
{
   import com.goldengear.utils.GeneralUtils;
   import com.metanet.data.EpisodeData;
   import com.metanet.data.Options;
   import com.metanet.events.KeyboardFocusEvent;
   import com.metanet.events.StartEvent;
   import com.metanet.ui.DynamicButton;
   import com.metanet.ui.GlobalKeys;
   import com.metanet.ui.KeyboardNavigator;
   import editor.Editor_State;
   import editor.ThumbnailGenerator;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.utils.ByteArray;
   import org.robotlegs.mvcs.Mediator;
   
   public class EpisodesScreenMediator extends Mediator
   {
      
      [Inject]
      public var view:EpisodesScreen;
      
      [Inject]
      public var episodes:EpisodeData;
      
      [Inject]
      public var playOptions:Options;
      
      [Inject]
      public var keyMapping:GlobalKeys;
      
      private var _lastUnlocked:int;
      
      private var _columns:int;
      
      private var _episodeButtons:Vector.<DynamicButton>;
      
      private var _arcadeButtons:Vector.<DynamicButton>;
      
      private var _stage:DisplayObject;
      
      private var _navigator:KeyboardNavigator;
      
      private var _grid:EpisodeGrid;
      
      private const ROWS:int = 10;
      
      private const MARGIN:int = 30;
      
      private const BUTTON_SIZE:int = 20;
      
      private const ROW_GAP:int = 20;
      
      private const COLUMN_GAP:int = 20;
      
      private const NUMBER_OF_NORMAL_EPISODES:int = 100;
      
      public function EpisodesScreenMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         this._grid = this.view.grid;
         this._episodeButtons = new Vector.<DynamicButton>();
         this._arcadeButtons = new Vector.<DynamicButton>(12);
         this.createButtons();
         this.mapButtonNavigation();
         this._stage = this.view.stage;
         this._stage.addEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         addViewListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         if(this.playOptions.selectedEpisode != -1 && this.playOptions.selectedEpisode < this._episodeButtons.length)
         {
            this._navigator.setFocus(this._episodeButtons[this.playOptions.selectedEpisode]);
            this.playOptions.selectedEpisode = -1;
         }
      }
      
      override public function onRemove() : void
      {
         if(this._stage)
         {
            this._stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         }
         this._stage = null;
         GeneralUtils.smartDestroy(this.view);
         super.onRemove();
      }
      
      private function createButtons() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:DynamicButton = null;
         var _loc4_:int = 0;
         while(_loc4_ < this.episodes.numberOfSets)
         {
            _loc3_ = this.createEpisodeButton(_loc2_,_loc1_,this.episodes.isBeaten(_loc4_));
            this._episodeButtons[this._episodeButtons.length] = _loc3_;
            if(this.episodes.isUnlocked(_loc4_))
            {
               _loc3_.text = this.episodes.getEpisodeLabelFor(_loc4_);
               this._lastUnlocked = _loc4_;
            }
            else
            {
               _loc3_.text = "";
               _loc3_.mouseEnabled = false;
            }
            if(_loc4_ >= this.NUMBER_OF_NORMAL_EPISODES && !this.shouldSecretEpisodesBeShown)
            {
               _loc3_.visible = false;
            }
            this._grid.addChild(_loc3_);
            _loc1_++;
            if(_loc1_ >= this.ROWS)
            {
               _loc1_ = 0;
               if(this.episodes.isRangeBeaten(_loc4_ - this.ROWS + 1,_loc4_))
               {
                  this.createArcadeButton(_loc2_);
               }
               _loc2_++;
            }
            _loc4_++;
         }
      }
      
      private function get shouldSecretEpisodesBeShown() : Boolean
      {
         if(this.episodes.lastUnbeaten == -1)
         {
            return true;
         }
         return this.episodes.lastUnbeaten > this.NUMBER_OF_NORMAL_EPISODES - 1;
      }
      
      private function createEpisodeButton(param1:int, param2:int, param3:Boolean) : DynamicButton
      {
         var _loc4_:DynamicButton = null;
         if(param3)
         {
            _loc4_ = new BeatenEpisodeButton();
         }
         else
         {
            _loc4_ = new EpisodeButton();
         }
         _loc4_.x = this.MARGIN + param1 * this.BUTTON_SIZE + param1 * this.COLUMN_GAP;
         _loc4_.y = this.MARGIN + param2 * this.BUTTON_SIZE + param2 * this.ROW_GAP;
         _loc4_.tabEnabled = false;
         _loc4_.tabChildren = false;
         _loc4_.addEventListener(MouseEvent.CLICK,this.handleClickEpisode);
         _loc4_.addEventListener(MouseEvent.MOUSE_OVER,this.handleMouseOverEpisode);
         _loc4_.addEventListener(KeyboardFocusEvent.FOCUS_IN,this.handleMouseOverEpisode);
         return _loc4_;
      }
      
      private function createArcadeButton(param1:int) : void
      {
         var _loc2_:DynamicButton = new EpisodeButton();
         _loc2_.text = "a-" + param1;
         if(param1 == 10)
         {
            _loc2_.text = "a-a";
         }
         if(param1 == 11)
         {
            _loc2_.text = "a-b";
         }
         _loc2_.x = this.MARGIN + param1 * this.BUTTON_SIZE + param1 * this.COLUMN_GAP;
         _loc2_.y = this.MARGIN + 10 * this.BUTTON_SIZE + 10 * this.ROW_GAP;
         _loc2_.addEventListener(MouseEvent.CLICK,this.handleClickArcade);
         _loc2_.addEventListener(MouseEvent.MOUSE_OVER,this.handleMouseOverArcade);
         _loc2_.addEventListener(KeyboardFocusEvent.FOCUS_IN,this.handleMouseOverArcade);
         this._arcadeButtons[param1] = _loc2_;
         this._grid.addChild(_loc2_);
         if(param1 * 10 >= this.NUMBER_OF_NORMAL_EPISODES && !this.shouldSecretEpisodesBeShown)
         {
            _loc2_.visible = false;
         }
      }
      
      private function handleKeyDown(param1:KeyboardEvent) : void
      {
         this._navigator.navigate(param1.keyCode);
      }
      
      private function mapButtonNavigation() : void
      {
         var _loc1_:int = this._lastUnlocked;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         this._navigator = new KeyboardNavigator();
         this._navigator.useMapping(this.keyMapping);
         this.connectSequentialEpisodes();
         this.connectRows();
         this.connectArcadeButtonRow();
         this.addEntryPoints();
         this._navigator.setReturnButton(this.view.returnButton);
      }
      
      private function connectSequentialEpisodes() : void
      {
         var _loc1_:int = this._lastUnlocked;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc2_ < this._lastUnlocked)
         {
            do
            {
               _loc3_++;
            }
            while(!this.episodes.isUnlocked(_loc3_));
            
            if(Boolean(this._arcadeButtons[int(_loc2_ / 10)]) && int(_loc2_ / 10) != int(_loc3_ / 10))
            {
               this._navigator.connectVertically(this._episodeButtons[_loc2_],this._arcadeButtons[int(_loc2_ / 10)]);
               this._navigator.connectVertically(this._arcadeButtons[int(_loc2_ / 10)],this._episodeButtons[_loc3_]);
            }
            else
            {
               this._navigator.connectVertically(this._episodeButtons[_loc2_],this._episodeButtons[_loc3_]);
            }
            _loc1_ = _loc2_;
            _loc2_ = _loc3_;
         }
         if(this._arcadeButtons[11])
         {
            this._navigator.connectVertically(this._episodeButtons[this._lastUnlocked],this._arcadeButtons[11]);
            this._navigator.connectVertically(this._arcadeButtons[11],this._episodeButtons[0]);
         }
         else
         {
            this._navigator.connectVertically(this._episodeButtons[this._lastUnlocked],this._episodeButtons[0]);
         }
      }
      
      private function connectRows() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < 10)
         {
            this.connectRowStartingWith(_loc1_);
            _loc1_++;
         }
      }
      
      private function connectArcadeButtonRow() : void
      {
         var _loc3_:int = 0;
         var _loc1_:int = -1;
         var _loc2_:int = -1;
         var _loc4_:int = 0;
         while(_loc4_ < this._arcadeButtons.length)
         {
            if(Boolean(this._arcadeButtons[_loc4_]) && this._arcadeButtons[_loc4_].visible)
            {
               if(_loc1_ == -1)
               {
                  _loc1_ = _loc4_;
               }
               else
               {
                  this._navigator.connectHorizontally(this._arcadeButtons[_loc2_],this._arcadeButtons[_loc4_]);
               }
               _loc3_ = _loc4_;
               _loc2_ = _loc4_;
            }
            _loc4_++;
         }
         if(_loc1_ != _loc2_)
         {
            this._navigator.connectHorizontally(this._arcadeButtons[_loc2_],this._arcadeButtons[_loc1_]);
         }
      }
      
      private function connectRowStartingWith(param1:int) : void
      {
         var _loc2_:int = -1;
         var _loc3_:int = -1;
         var _loc4_:int = param1;
         while(_loc4_ <= this._lastUnlocked)
         {
            if(this.episodes.isUnlocked(_loc4_))
            {
               if(_loc2_ == -1)
               {
                  _loc2_ = _loc4_;
                  _loc3_ = _loc4_;
               }
               else
               {
                  this._navigator.connectHorizontally(this._episodeButtons[_loc3_],this._episodeButtons[_loc4_]);
                  _loc3_ = _loc4_;
               }
            }
            _loc4_ += 10;
         }
         if(_loc2_ != -1)
         {
            this._navigator.connectHorizontally(this._episodeButtons[_loc3_],this._episodeButtons[_loc2_]);
         }
      }
      
      private function addEntryPoints() : void
      {
         this._navigator.addEntryPoint(KeyboardNavigator.RIGHT,this._episodeButtons[0]);
         this._navigator.addEntryPoint(KeyboardNavigator.DOWN,this._episodeButtons[0]);
         this._navigator.addEntryPoint(KeyboardNavigator.LEFT,this._episodeButtons[this._lastUnlocked]);
         if(this._arcadeButtons[11])
         {
            this._navigator.addEntryPoint(KeyboardNavigator.UP,this._arcadeButtons[11]);
         }
         else
         {
            this._navigator.addEntryPoint(KeyboardNavigator.UP,this._episodeButtons[this._lastUnlocked]);
         }
      }
      
      private function handleClickEpisode(param1:MouseEvent) : void
      {
         var _loc2_:int = int(this._episodeButtons.indexOf(param1.target));
         this.playOptions.selectedEpisode = _loc2_;
         dispatch(new StartEvent(StartEvent.START_EPISODE));
      }
      
      private function handleMouseOverEpisode(param1:*) : void
      {
         var _loc3_:ByteArray = null;
         var _loc4_:ByteArray = null;
         var _loc5_:Editor_State = null;
         var _loc6_:Sprite = null;
         var _loc2_:int = int(this._episodeButtons.indexOf(param1.target));
         var _loc7_:Number = this.view.thumbnails.height;
         var _loc8_:Number = this.view.thumbnails.width;
         this.view.thumbnails.removeChildren(1);
         var _loc9_:int = 0;
         while(_loc9_ < 5)
         {
            _loc3_ = this.episodes.getLevel(_loc2_,_loc9_);
            _loc6_ = this.thumbnailFromData(_loc3_);
            _loc6_.scaleX = 0.125;
            _loc6_.scaleY = 0.125;
            this.view.thumbnails.addChild(_loc6_);
            _loc6_.x = (_loc8_ - _loc6_.width) / 2;
            _loc6_.y = _loc9_ * (_loc7_ / 5);
            _loc9_++;
         }
      }
      
      private function handleClickArcade(param1:*) : void
      {
         this.playOptions.selectedEpisode = -1;
         this.playOptions.selectedLevelIndexInSearch = -1;
         this.playOptions.selectedLevel = null;
         this.playOptions.selectedChallenge = this._arcadeButtons.indexOf(param1.target);
         dispatch(new StartEvent(StartEvent.START_CHALLENGE));
      }
      
      private function handleMouseOverArcade(param1:*) : void
      {
         this.view.thumbnails.removeChildren(1);
      }
      
      private function thumbnailFromData(param1:ByteArray) : Sprite
      {
         var _loc2_:ByteArray = null;
         var _loc3_:Editor_State = null;
         var _loc4_:Sprite = null;
         var _loc5_:Number = this.view.thumbnails.height;
         var _loc6_:Number = this.view.thumbnails.width;
         param1.readUTF();
         _loc2_ = new ByteArray();
         param1.readBytes(_loc2_);
         param1.position = 0;
         _loc3_ = Editor_State.Load_From_Bytes(_loc2_);
         _loc4_ = ThumbnailGenerator.Generate(_loc3_);
         _loc4_.scaleX = 0.125;
         _loc4_.scaleY = 0.125;
         return _loc4_;
      }
   }
}

