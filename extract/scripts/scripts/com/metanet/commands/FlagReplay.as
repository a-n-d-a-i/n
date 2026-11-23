package com.metanet.commands
{
   import com.metanet.events.ReplayEvent;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import org.robotlegs.mvcs.Command;
   
   public class FlagReplay extends Command
   {
      
      [Inject]
      public var event:ReplayEvent;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var server:NServerConnector;
      
      public function FlagReplay()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.server.sendRequest(this.requestFactory.flagReplay(this.event.level,this.event.user));
      }
   }
}

