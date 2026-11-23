package com.metanet.commands
{
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import org.robotlegs.mvcs.Command;
   
   public class Logout extends Command
   {
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      public function Logout()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.server.sendRequest(this.requestFactory.logout());
      }
   }
}

