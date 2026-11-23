package com.metanet.commands
{
   import com.metanet.data.AccountDetails;
   import com.metanet.data.GameStats;
   import com.metanet.events.InitializeEvent;
   import com.metanet.global.SavedProperties;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Command;
   
   public class DeleteScoreFromCache extends Command
   {
      
      [Inject]
      public var sharedObject:SharedObject;
      
      [Inject]
      public var gameStats:GameStats;
      
      [Inject]
      public var account:AccountDetails;
      
      public function DeleteScoreFromCache()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:String = this.gameStats.level + this.account.userID;
         var _loc2_:Array = this.sharedObject.data[SavedProperties.CACHED_SCORES];
         var _loc3_:SharedObject = SharedObject.getLocal(_loc1_,"/");
         var _loc4_:int = int(_loc2_.indexOf(_loc1_));
         _loc2_.splice(_loc4_,1);
         this.sharedObject.setProperty(SavedProperties.CACHED_SCORES,_loc2_);
         try
         {
            this.sharedObject.flush();
         }
         catch(e:Error)
         {
         }
         delete _loc3_.data["user"];
         delete _loc3_.data["level"];
         delete _loc3_.data["score"];
         delete _loc3_.data["replay"];
         try
         {
            _loc3_.flush();
         }
         catch(e:Error)
         {
         }
         dispatch(new InitializeEvent(InitializeEvent.DELETED_CACHED_SCORE));
      }
   }
}

