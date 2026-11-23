package com.metanet.commands
{
   import com.metanet.data.Level;
   import com.metanet.data.Options;
   import com.metanet.global.SavedProperties;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Command;
   
   public class CacheLevelLocally extends Command
   {
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var sharedObject:SharedObject;
      
      public function CacheLevelLocally()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc4_:Array = null;
         var _loc1_:Level = this.options.selectedLevel;
         _loc1_.waitingForUpload = true;
         var _loc2_:String = _loc1_.id;
         if(!_loc2_)
         {
            _loc2_ = "0000";
         }
         var _loc3_:SharedObject = SharedObject.getLocal(_loc2_,"/");
         _loc3_.setProperty("name",_loc1_.name);
         _loc3_.setProperty("data",_loc1_.data);
         try
         {
            _loc3_.flush();
         }
         catch(e:Error)
         {
         }
         if(!this.sharedObject.hasOwnProperty(SavedProperties.CACHED_LEVELS))
         {
            _loc4_ = [];
         }
         else
         {
            _loc4_ = this.sharedObject[SavedProperties.CACHED_LEVELS];
         }
         if(_loc4_.indexOf(_loc1_.id) == -1)
         {
            _loc4_[_loc4_.length] = _loc1_.id;
            this.sharedObject.setProperty(SavedProperties.CACHED_LEVELS,_loc4_);
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

