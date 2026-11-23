package com.metanet
{
   import flash.utils.ByteArray;
   
   public class ReplayCache
   {
      
      private var _replays:Object = {};
      
      private var _scores:Object = {};
      
      public function ReplayCache()
      {
         super();
      }
      
      public function storeReplay(param1:String, param2:int, param3:int, param4:ByteArray) : void
      {
         if(!this._replays[param1])
         {
            this._replays[param1] = [];
            this._scores[param1] = [];
         }
         this._replays[param1][param2] = param4;
         this._scores[param1][param2] = param3;
      }
      
      public function hasReplay(param1:String, param2:int, param3:int) : Boolean
      {
         if(!this._replays[param1])
         {
            return false;
         }
         if(!this._replays[param1][param2])
         {
            return false;
         }
         if(this._scores[param1][param2] != param3)
         {
            return false;
         }
         return true;
      }
      
      public function getReplay(param1:String, param2:int) : ByteArray
      {
         if(!this._replays[param1])
         {
            return null;
         }
         if(!this._replays[param1][param2])
         {
            return null;
         }
         this._replays[param1][param2].position = 0;
         return this._replays[param1][param2];
      }
   }
}

