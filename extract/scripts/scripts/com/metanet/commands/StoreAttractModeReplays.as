package com.metanet.commands
{
   import com.metanet.data.AttractMode;
   import flash.utils.ByteArray;
   import org.robotlegs.mvcs.Command;
   
   public class StoreAttractModeReplays extends Command
   {
      
      [Inject]
      public var attractMode:AttractMode;
      
      private var Replays:Class = StoreAttractModeReplays_Replays;
      
      public function StoreAttractModeReplays()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:ByteArray = new this.Replays();
         this.loadFrom(_loc1_);
      }
      
      private function loadFrom(param1:ByteArray) : void
      {
         var _loc3_:int = 0;
         var _loc4_:ByteArray = null;
         var _loc2_:ByteArray = param1;
         while(_loc2_.position < _loc2_.length)
         {
            _loc3_ = _loc2_.readInt();
            _loc4_ = this.readAttractModeReplayFrom(_loc2_);
            this.attractMode.storeReplay(_loc3_,_loc4_);
         }
      }
      
      private function readAttractModeReplayFrom(param1:ByteArray) : ByteArray
      {
         var _loc2_:ByteArray = new ByteArray();
         var _loc3_:uint = uint(param1.readInt());
         param1.readBytes(_loc2_,0,_loc3_);
         return _loc2_;
      }
   }
}

