package com.metanet.data
{
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.utils.ByteArray;
   import org.robotlegs.mvcs.Actor;
   
   public class LevelSetLoader extends Actor
   {
      
      public var loaders:Vector.<Vector.<URLLoader>>;
      
      public var downloaded:Vector.<Vector.<ByteArray>>;
      
      public var numberOfSets:int;
      
      protected var levelsPerSet:int;
      
      public function LevelSetLoader()
      {
         super();
      }
      
      protected function init() : void
      {
         this.downloaded = new Vector.<Vector.<ByteArray>>(this.numberOfSets);
         this.loaders = new Vector.<Vector.<URLLoader>>(this.numberOfSets);
         this.downloaded.fixed = true;
         this.loaders.fixed = true;
         var _loc1_:int = 0;
         while(_loc1_ < this.numberOfSets)
         {
            this.downloaded[_loc1_] = new Vector.<ByteArray>(this.levelsPerSet);
            this.loaders[_loc1_] = new Vector.<URLLoader>(this.levelsPerSet);
            this.downloaded[_loc1_].fixed = true;
            this.loaders[_loc1_].fixed;
            _loc1_++;
         }
      }
      
      public function storeLevelLoader(param1:int, param2:int, param3:URLLoader) : void
      {
         this.loaders[param1][param2] = param3;
         param3.addEventListener(Event.COMPLETE,this.handleLoaderComplete);
      }
      
      public function storeDownloadedLevel(param1:int, param2:int, param3:ByteArray) : void
      {
         this.downloaded[param1][param2] = param3;
      }
      
      public function getLevel(param1:int, param2:int) : ByteArray
      {
         return this.downloaded[param1][param2];
      }
      
      public function getLevelSet(param1:int) : Vector.<ByteArray>
      {
         return this.downloaded[param1];
      }
      
      public function isLevelReady(param1:int, param2:int) : Boolean
      {
         if(this.downloaded.length <= param1 - 1)
         {
            return false;
         }
         if(this.downloaded[param1].length <= param2 - 1)
         {
            return false;
         }
         return this.downloaded[param1][param2] != null;
      }
      
      private function handleLoaderComplete(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:URLLoader = param1.target as URLLoader;
         var _loc5_:int = 0;
         while(_loc5_ < this.numberOfSets)
         {
            _loc7_ = 0;
            while(_loc7_ < this.levelsPerSet)
            {
               if(this.loaders[_loc5_][_loc7_] == _loc2_)
               {
                  _loc3_ = _loc5_;
                  _loc4_ = _loc7_;
               }
               _loc7_++;
            }
            _loc5_++;
         }
         var _loc6_:ByteArray = _loc2_.data;
         this.storeDownloadedLevel(_loc3_,_loc4_,_loc6_);
      }
   }
}

