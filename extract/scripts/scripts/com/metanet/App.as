package com.metanet
{
   import flash.utils.ByteArray;
   
   public interface App
   {
      
      function initialize() : void;
      
      function tick() : void;
      
      function useLevelSet(param1:Vector.<ByteArray>) : void;
      
      function resumeLevelSet(param1:int, param2:int) : void;
      
      function startLevelSet() : void;
      
      function playSingleLevelFromBytes(param1:ByteArray, param2:String) : void;
      
      function showReplay(param1:ByteArray, param2:ByteArray) : void;
      
      function watchPlayerSelectedReplay(param1:ByteArray, param2:ByteArray) : void;
      
      function showRandomReplay() : void;
      
      function stopReplay() : void;
      
      function get gameState() : int;
      
      function get uiState() : int;
   }
}

