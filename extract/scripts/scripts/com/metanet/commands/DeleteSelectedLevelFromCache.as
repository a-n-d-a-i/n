package com.metanet.commands
{
   import com.metanet.data.Options;
   import com.metanet.events.InitializeEvent;
   import com.metanet.global.SavedProperties;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Command;
   
   public class DeleteSelectedLevelFromCache extends Command
   {
      
      [Inject]
      public var sharedObject:SharedObject;
      
      [Inject]
      public var options:Options;
      
      public function DeleteSelectedLevelFromCache()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.options.selectedLevel.waitingForUpload = false;
         var _loc1_:Array = this.sharedObject.data[SavedProperties.CACHED_LEVELS];
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:String = this.options.selectedLevel.id;
         var _loc3_:SharedObject = SharedObject.getLocal(_loc2_,"/");
         var _loc4_:int = int(_loc1_.indexOf(_loc2_));
         if(_loc4_ == -1)
         {
            return;
         }
         _loc1_.splice(_loc4_,1);
         this.sharedObject.setProperty(SavedProperties.CACHED_LEVELS,_loc1_);
         try
         {
            this.sharedObject.flush();
         }
         catch(e:Error)
         {
         }
         delete _loc3_.data["name"];
         delete _loc3_.data["data"];
         try
         {
            _loc3_.flush();
         }
         catch(e:Error)
         {
         }
         dispatch(new InitializeEvent(InitializeEvent.DELETED_CACHED_LEVEL));
      }
   }
}

