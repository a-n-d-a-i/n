package com.metanet.commands
{
   import com.metanet.data.AccountDetails;
   import com.metanet.data.Level;
   import com.metanet.data.Options;
   import com.metanet.events.InitializeEvent;
   import com.metanet.global.SavedProperties;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Command;
   
   public class SubmitNextCachedLevel extends Command
   {
      
      [Inject]
      public var sharedObject:SharedObject;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var account:AccountDetails;
      
      public function SubmitNextCachedLevel()
      {
         super();
      }
      
      override public function execute() : void
      {
         if(!this.account.loggedIn || !this.account.useDatabase)
         {
            return;
         }
         if(!this.sharedObject.data.hasOwnProperty(SavedProperties.CACHED_LEVELS))
         {
            return;
         }
         if(this.sharedObject.data[SavedProperties.CACHED_LEVELS].length == 0)
         {
            return;
         }
         var _loc1_:Array = this.sharedObject.data[SavedProperties.CACHED_LEVELS];
         var _loc2_:String = _loc1_[0];
         if(_loc2_ == "null" || _loc2_ == null)
         {
            _loc1_.shift();
            this.execute();
            return;
         }
         var _loc3_:SharedObject = SharedObject.getLocal(_loc2_,"/");
         var _loc4_:Level = new Level();
         _loc4_.id = _loc1_[0];
         _loc4_.name = _loc3_.data["name"];
         _loc4_.data = _loc3_.data["data"];
         this.options.selectedLevel = _loc4_;
         dispatch(new InitializeEvent(InitializeEvent.REUPLOAD_CACHED_LEVEL));
      }
   }
}

