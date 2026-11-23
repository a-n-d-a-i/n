package com.metanet.commands
{
   import com.metanet.events.ReplayEvent;
   import com.metanet.remote.AmazonServerConnector;
   import org.robotlegs.mvcs.Command;
   
   public class DownloadReplay extends Command
   {
      
      [Inject]
      public var amazon:AmazonServerConnector;
      
      [Inject]
      public var event:ReplayEvent;
      
      public function DownloadReplay()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.amazon.loadReplay(this.event.level,this.event.user,this.event.score);
      }
   }
}

