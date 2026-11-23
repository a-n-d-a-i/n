package com.metanet.commands
{
   import com.metanet.data.AccountDetails;
   import com.metanet.data.GameStats;
   import com.metanet.events.InitializeEvent;
   import com.metanet.global.SavedProperties;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Command;
   
   public class SubmitLastCachedScore extends Command
   {
      
      [Inject]
      public var sharedObject:SharedObject;
      
      [Inject]
      public var gameStats:GameStats;
      
      [Inject]
      public var account:AccountDetails;
      
      public function SubmitLastCachedScore()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc2_:SharedObject = null;
         var _loc1_:Array = this.sharedObject.data[SavedProperties.CACHED_SCORES];
         if(!_loc1_)
         {
            return;
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.length)
         {
            _loc2_ = SharedObject.getLocal(_loc1_[_loc3_],"/");
            if(_loc2_.data.user == this.account.userID)
            {
               this.gameStats.isEpisode = false;
               this.gameStats.level = _loc2_.data.level;
               this.gameStats.score = _loc2_.data.score;
               this.gameStats.replayBytes = _loc2_.data.replay;
               if(_loc2_.data.replay)
               {
                  dispatch(new InitializeEvent(InitializeEvent.REUPLOAD_CACHED_SCORE));
                  return;
               }
               dispatch(new InitializeEvent(InitializeEvent.CACHED_SCORE_CORRUPTED));
               _loc3_++;
            }
            else
            {
               _loc3_++;
            }
         }
      }
   }
}

