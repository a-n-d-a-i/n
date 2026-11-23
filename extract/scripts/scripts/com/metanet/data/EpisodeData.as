package com.metanet.data
{
   import com.metanet.global.SavedProperties;
   import com.metanet.remote.NRequest;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import flash.net.SharedObject;
   import flash.utils.ByteArray;
   
   public class EpisodeData extends LevelSetLoader
   {
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var sharedObject:SharedObject;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      public var numberBeaten:int;
      
      private var _lastBeatenByColumn:Array;
      
      private var _beaten:Array;
      
      private var _unlocked:Array;
      
      private const EPISODES_PER_COLUMN:int = 10;
      
      private const NUMBER_OF_EPISODES:int = 120;
      
      private var _serverProgressOutOfDate:Boolean;
      
      public function EpisodeData()
      {
         super();
         numberOfSets = this.NUMBER_OF_EPISODES;
         levelsPerSet = 5;
         this.init();
         this.unlockDefaultEpisodes();
      }
      
      override protected function init() : void
      {
         super.init();
         this._beaten = new Array(this.NUMBER_OF_EPISODES);
         var _loc1_:int = 0;
         while(_loc1_ < this.NUMBER_OF_EPISODES)
         {
            this._beaten[_loc1_] = false;
            _loc1_++;
         }
         this._unlocked = [];
         this._lastBeatenByColumn = new Array(this.NUMBER_OF_EPISODES / this.EPISODES_PER_COLUMN);
      }
      
      public function clearPlayerData() : void
      {
         this._beaten = new Array(this.NUMBER_OF_EPISODES);
         var _loc1_:int = 0;
         while(_loc1_ < this.NUMBER_OF_EPISODES)
         {
            this._beaten[_loc1_] = false;
            _loc1_++;
         }
         this._unlocked = [];
         this._lastBeatenByColumn = new Array(this.NUMBER_OF_EPISODES / this.EPISODES_PER_COLUMN);
         this.unlockDefaultEpisodes();
      }
      
      public function beatEpisodeFromGameplay(param1:int) : void
      {
         if(!this._unlocked[param1 + 1])
         {
            this.unlockEpisode(param1 + 1);
         }
         if(!this._beaten[param1])
         {
            this.beatEpisode(param1);
            if(this.account.loggedIn && this.account.useDatabase)
            {
               this.beatEpisodeOnServer(param1);
            }
         }
         this.saveToSharedObject();
      }
      
      public function syncWithServerData(param1:XMLList) : void
      {
         var _loc2_:Array = this.generateColumnArrayFromServerData(param1);
         var _loc3_:Array = this._lastBeatenByColumn.concat();
         var _loc4_:int = 0;
         while(_loc4_ < this._lastBeatenByColumn.length)
         {
            if(_loc3_[_loc4_] == -1)
            {
               _loc3_[_loc4_] = _loc4_ * 10;
            }
            else
            {
               _loc3_[_loc4_] += _loc4_ * 10;
            }
            _loc4_++;
         }
         this.syncColumns(_loc3_,_loc2_);
         this.saveToSharedObject();
         if(this._serverProgressOutOfDate)
         {
            this.saveProgressToServer();
         }
      }
      
      public function getLevelByID(param1:String) : ByteArray
      {
         var _loc2_:int = Number(param1) - 1;
         var _loc3_:int = _loc2_ / 5;
         var _loc4_:int = _loc2_ % 5;
         return getLevel(_loc3_,_loc4_);
      }
      
      public function createLevelSetForColumn(param1:int) : Vector.<ByteArray>
      {
         var _loc2_:Vector.<ByteArray> = new Vector.<ByteArray>();
         var _loc3_:int = 0;
         while(_loc3_ < 10)
         {
            _loc2_ = _loc2_.concat(getLevelSet(_loc3_ + param1 * 10));
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function generateColumnArrayFromServerData(param1:XMLList) : Array
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         for each(_loc6_ in param1)
         {
            _loc5_ = Number(_loc6_);
            _loc4_ = int(_loc5_ / 10);
            _loc3_[_loc4_] = true;
            _loc2_[_loc4_] = _loc5_;
         }
         _loc7_ = 0;
         while(_loc7_ < this._lastBeatenByColumn.length)
         {
            if(!_loc3_[_loc7_])
            {
               _loc2_[_loc7_] = -1;
            }
            _loc7_++;
         }
         return _loc2_;
      }
      
      private function syncColumns(param1:Array, param2:Array) : void
      {
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            this.syncColumn(_loc3_,param1[_loc3_],param2[_loc3_]);
            _loc3_++;
         }
         this.saveToSharedObject();
      }
      
      private function syncColumn(param1:int, param2:int, param3:int) : void
      {
         while(param2 <= param3)
         {
            this.beatEpisodeFromServerData(param2);
            param2++;
         }
         while(param3 < param2 - 1)
         {
            this._serverProgressOutOfDate = true;
            param3++;
         }
      }
      
      public function getEpisodeLabelFor(param1:int) : String
      {
         if(param1 < 10)
         {
            return "0" + String(param1);
         }
         if(int(param1 / 10) == 10)
         {
            return String(param1).split("10").join("a");
         }
         if(int(param1 / 10) == 11)
         {
            return String(param1).split("11").join("b");
         }
         return String(param1);
      }
      
      private function beatEpisodeFromServerData(param1:int) : void
      {
         if(!this._unlocked[param1 + 1])
         {
            this.unlockEpisode(param1 + 1);
         }
         if(!this._beaten[param1])
         {
            this.beatEpisode(param1);
         }
      }
      
      public function beatEpisodeFromSharedObject(param1:int) : void
      {
         if(!this._unlocked[param1 + 1])
         {
            this.unlockEpisode(param1 + 1);
         }
         if(!this._beaten[param1])
         {
            this.beatEpisode(param1);
            if(this.account.loggedIn && this.account.useDatabase)
            {
               this.beatEpisodeOnServer(param1);
            }
         }
      }
      
      private function unlockDefaultEpisodes() : void
      {
         var _loc1_:int = this.NUMBER_OF_EPISODES / this.EPISODES_PER_COLUMN;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            this._unlocked[_loc2_ * this.EPISODES_PER_COLUMN] = true;
            this._lastBeatenByColumn[_loc2_] = -1;
            _loc2_++;
         }
      }
      
      private function unlockEpisode(param1:int) : void
      {
         this._unlocked[param1] = true;
      }
      
      private function beatEpisode(param1:int) : void
      {
         var _loc2_:int = param1 / this.EPISODES_PER_COLUMN;
         ++this.numberBeaten;
         ++this._lastBeatenByColumn[_loc2_];
         if(this._lastBeatenByColumn[_loc2_] > 9)
         {
            throw new Error("Only 10 episodes in a column");
         }
         this._beaten[param1] = true;
      }
      
      private function saveToSharedObject() : void
      {
         this.sharedObject.setProperty(SavedProperties.BEATEN_LEVELS,this._beaten);
         try
         {
            this.sharedObject.flush();
         }
         catch(e:Error)
         {
         }
      }
      
      private function saveProgressToServer() : void
      {
         var _loc1_:NRequest = this.requestFactory.updateProgress(this._lastBeatenByColumn);
         this.server.sendRequest(_loc1_);
      }
      
      private function beatEpisodeOnServer(param1:int) : void
      {
         var _loc2_:NRequest = this.requestFactory.finishedEpisode(param1);
         this.server.sendRequest(_loc2_);
      }
      
      public function isUnlocked(param1:int) : Boolean
      {
         return this._unlocked[param1];
      }
      
      public function isRangeBeaten(param1:int, param2:int) : Boolean
      {
         var _loc3_:Boolean = true;
         var _loc4_:int = param1;
         while(_loc4_ <= param2)
         {
            _loc3_ &&= this.isBeaten(_loc4_);
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function isBeaten(param1:int) : Boolean
      {
         return this._beaten[param1];
      }
      
      public function get lastUnbeaten() : int
      {
         return this._beaten.indexOf(false);
      }
      
      public function get lastBeatenByColumn() : Array
      {
         return this._lastBeatenByColumn;
      }
      
      public function get beaten() : Array
      {
         return this._beaten.concat();
      }
   }
}

