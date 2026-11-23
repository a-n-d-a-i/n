package com.metanet.commands
{
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import org.robotlegs.mvcs.Command;
   
   public class SynchronizeWithServer extends Command
   {
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var server:NServerConnector;
      
      public function SynchronizeWithServer()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.server.sendRequest(this.requestFactory.getEpisodes());
      }
   }
}

