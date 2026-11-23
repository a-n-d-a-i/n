package com.metanet.commands
{
   import com.metanet.App;
   import com.metanet.data.AttractMode;
   import com.metanet.data.EpisodeData;
   import flash.utils.ByteArray;
   import org.robotlegs.mvcs.Command;
   
   public class WatchNextReplay extends Command
   {
      
      [Inject]
      public var attractMode:AttractMode;
      
      [Inject]
      public var episodes:EpisodeData;
      
      [Inject]
      public var app:App;
      
      public function WatchNextReplay()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:int = this.attractMode.getNextReplay();
         var _loc2_:int = this.attractMode.getReplayLevel(_loc1_);
         var _loc3_:ByteArray = this.attractMode.getReplayData(_loc1_);
         var _loc4_:int = _loc2_ % 5;
         var _loc5_:int = _loc2_ / 5;
         var _loc6_:ByteArray = this.episodes.getLevel(_loc5_,_loc4_);
         this.app.showReplay(_loc6_,_loc3_);
      }
   }
}

