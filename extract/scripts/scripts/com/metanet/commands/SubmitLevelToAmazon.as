package com.metanet.commands
{
   import com.metanet.events.NServerEvent;
   import com.metanet.remote.AmazonServerConnector;
   import org.robotlegs.mvcs.Command;
   
   public class SubmitLevelToAmazon extends Command
   {
      
      [Inject]
      public var event:NServerEvent;
      
      [Inject]
      public var amazonConnector:AmazonServerConnector;
      
      public function SubmitLevelToAmazon()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:* = this.event.data;
         _loc1_ = "<response>" + _loc1_ + "</response>";
         this.amazonConnector.useCredentials(new XML(_loc1_));
         this.amazonConnector.completeLevelUpload();
      }
   }
}

