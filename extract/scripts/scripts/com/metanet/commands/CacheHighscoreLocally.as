package com.metanet.commands
{
   import com.metanet.data.AccountDetails;
   import com.metanet.data.GameStats;
   import com.metanet.global.SavedProperties;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Command;
   
   public class CacheHighscoreLocally extends Command
   {
      
      [Inject]
      public var sharedObject:SharedObject;
      
      [Inject]
      public var lastGame:GameStats;
      
      [Inject]
      public var account:AccountDetails;
      
      public function CacheHighscoreLocally()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc3_:Array = null;
         var _loc1_:String = this.lastGame.level + this.account.userID;
         var _loc2_:SharedObject = SharedObject.getLocal(_loc1_,"/");
         _loc2_.setProperty("user",this.account.userID);
         _loc2_.setProperty("level",this.lastGame.level);
         _loc2_.setProperty("score",this.lastGame.score);
         _loc2_.setProperty("replay",this.lastGame.replayBytes);
         try
         {
            _loc2_.flush();
         }
         catch(e:Error)
         {
         }
         if(!this.sharedObject.hasOwnProperty(SavedProperties.CACHED_SCORES))
         {
            _loc3_ = [];
         }
         else
         {
            _loc3_ = this.sharedObject[SavedProperties.CACHED_SCORES];
         }
         if(_loc3_.indexOf(_loc1_) == -1)
         {
            _loc3_[_loc3_.length] = _loc1_;
            this.sharedObject.setProperty(SavedProperties.CACHED_SCORES,_loc3_);
            try
            {
               this.sharedObject.flush();
            }
            catch(e:Error)
            {
            }
         }
      }
   }
}

