package com.metanet.data
{
   import flash.utils.ByteArray;
   
   public class AttractMode
   {
      
      private var _index:int;
      
      private var _levels:Vector.<int>;
      
      private var _replayData:Vector.<ByteArray>;
      
      public function AttractMode()
      {
         super();
         this._levels = new Vector.<int>();
         this._replayData = new Vector.<ByteArray>();
      }
      
      public function storeReplay(param1:int, param2:ByteArray) : void
      {
         this._levels[this._levels.length] = param1;
         this._replayData[this._replayData.length] = param2;
      }
      
      public function getRandomReplay() : int
      {
         this._index = Math.random() * this._levels.length * 0.9999;
         return this._index;
      }
      
      public function getNextReplay() : int
      {
         this._index = (this._index + 1) % this._levels.length;
         return this._index;
      }
      
      public function getReplayLevel(param1:int) : int
      {
         return this._levels[param1];
      }
      
      public function getReplayData(param1:int) : ByteArray
      {
         return this._replayData[param1];
      }
   }
}

