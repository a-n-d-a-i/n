package com.metanet.commands
{
   import com.metanet.data.EpisodeData;
   import flash.utils.ByteArray;
   import org.robotlegs.mvcs.Command;
   
   public class StoreMetanetLevelData extends Command
   {
      
      [Inject]
      public var episodes:EpisodeData;
      
      private var Levels:Class = StoreMetanetLevelData_Levels;
      
      public function StoreMetanetLevelData()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:ByteArray = null;
         var _loc1_:ByteArray = new this.Levels();
         while(_loc1_.position < _loc1_.length)
         {
            _loc2_ = _loc1_.readInt();
            _loc3_ = _loc1_.readInt();
            _loc4_ = _loc1_.readInt();
            _loc5_ = new ByteArray();
            _loc1_.readBytes(_loc5_,0,_loc4_);
            this.episodes.storeDownloadedLevel(_loc2_,_loc3_,_loc5_);
         }
      }
   }
}

