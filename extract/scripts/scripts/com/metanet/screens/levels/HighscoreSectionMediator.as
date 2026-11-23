package com.metanet.screens.levels
{
   import com.metanet.data.Level;
   import com.metanet.data.Options;
   import com.metanet.events.NServerEvent;
   import com.metanet.events.ReplayEvent;
   import com.metanet.events.SearchEvent;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import flash.events.MouseEvent;
   import flash.utils.ByteArray;
   import org.robotlegs.mvcs.Mediator;
   
   public class HighscoreSectionMediator extends Mediator
   {
      
      [Inject]
      public var view:HighscoreSection;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      private var _nextScoreIndex:int;
      
      private var _displays:Vector.<HighscoreDisplay>;
      
      private var _users:Vector.<int>;
      
      private var _scores:Vector.<int>;
      
      private var _level:Level;
      
      private const DISPLAYED_SCORES:int = 10;
      
      private const MARGIN:Number = 5;
      
      private const GAP:int = 5;
      
      public function HighscoreSectionMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addContextListener(SearchEvent.SELECT_LEVEL,this.handleSelectLevel);
         addContextListener(NServerEvent.HIGHSCORES_LOADED,this.handleScoresLoaded);
         this.createDisplays();
      }
      
      private function createDisplays() : void
      {
         var _loc1_:HighscoreDisplay = null;
         this._displays = new Vector.<HighscoreDisplay>(this.DISPLAYED_SCORES);
         this._users = new Vector.<int>(this.DISPLAYED_SCORES);
         this._scores = new Vector.<int>(this.DISPLAYED_SCORES);
         var _loc2_:int = 0;
         while(_loc2_ < this.DISPLAYED_SCORES)
         {
            _loc1_ = new HighscoreDisplay();
            _loc1_.x = this.MARGIN;
            _loc1_.y = this.MARGIN + _loc1_.height * _loc2_ + this.GAP * _loc2_;
            _loc1_.visible = false;
            _loc1_.watch.addEventListener(MouseEvent.CLICK,this.handleClickedWatch);
            _loc1_.flag.addEventListener(MouseEvent.CLICK,this.handleClickedFlag);
            this.view.addChild(_loc1_);
            this._displays[_loc2_] = _loc1_;
            _loc2_++;
         }
      }
      
      private function handleSelectLevel(param1:SearchEvent) : void
      {
         this.clear();
         this._level = this.options.selectedLevel;
         this.server.sendRequest(this.requestFactory.requestHighscores(this._level.id));
      }
      
      private function handleScoresLoaded(param1:NServerEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         this.clear();
         var _loc2_:ByteArray = param1.data;
         _loc2_.position = 0;
         this._users = new Vector.<int>(this.DISPLAYED_SCORES);
         this._scores = new Vector.<int>(this.DISPLAYED_SCORES);
         while(_loc2_.position < _loc2_.length - 1)
         {
            this.displayNextScore(_loc2_);
            ++this._nextScoreIndex;
         }
         if(this._scores.length > 0)
         {
            this._level.minimumHighscore = this._scores[this._scores.length - 1];
         }
         else
         {
            this._level.minimumHighscore = 0;
         }
      }
      
      private function handleClickedWatch(param1:MouseEvent) : void
      {
         var _loc2_:HighscoreDisplay = param1.target.parent;
         var _loc3_:int = int(this._displays.indexOf(_loc2_));
         var _loc4_:ReplayEvent = new ReplayEvent(ReplayEvent.WATCH);
         _loc4_.level = this._level.id;
         _loc4_.user = this._users[_loc3_];
         _loc4_.score = this._scores[_loc3_];
         dispatch(_loc4_);
      }
      
      private function handleClickedFlag(param1:MouseEvent) : void
      {
         var _loc2_:HighscoreDisplay = param1.target.parent;
         var _loc3_:int = int(this._displays.indexOf(_loc2_));
         var _loc4_:ReplayEvent = new ReplayEvent(ReplayEvent.FLAG);
         _loc4_.level = this._level.id;
         _loc4_.user = this._users[_loc3_];
         _loc4_.score = this._scores[_loc3_];
         dispatch(_loc4_);
      }
      
      private function displayNextScore(param1:ByteArray) : void
      {
         var _loc2_:int = this.readIntOfLength(param1,3);
         var _loc3_:int = this.readIntOfLength(param1,4);
         var _loc4_:String = this.readTextToDelimiter(param1);
         var _loc5_:HighscoreDisplay = this._displays[this._nextScoreIndex];
         _loc5_.user.text = _loc4_;
         _loc5_.time.text = String(_loc2_);
         _loc5_.visible = true;
         this._users[this._nextScoreIndex] = _loc3_;
         this._scores[this._nextScoreIndex] = _loc2_;
      }
      
      private function clear() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.DISPLAYED_SCORES)
         {
            this._displays[_loc1_].visible = false;
            _loc1_++;
         }
         this._nextScoreIndex = 0;
      }
      
      private function readIntOfLength(param1:ByteArray, param2:int) : int
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:int = param2 - 1;
         while(_loc5_ >= 0)
         {
            _loc4_ = int(param1.readUnsignedByte());
            _loc3_ += _loc4_ << _loc5_ * 8;
            _loc5_--;
         }
         return _loc3_;
      }
      
      private function readTextToDelimiter(param1:ByteArray) : String
      {
         var _loc3_:int = 0;
         var _loc2_:String = "";
         do
         {
            _loc3_ = int(param1.readUnsignedByte());
            if(_loc3_ > 31)
            {
               _loc2_ += String.fromCharCode(_loc3_);
            }
         }
         while(_loc3_ > 31);
         
         --param1.position;
         return _loc2_;
      }
   }
}

