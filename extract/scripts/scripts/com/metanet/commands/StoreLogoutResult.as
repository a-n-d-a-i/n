package com.metanet.commands
{
   import com.metanet.data.AccountDetails;
   import com.metanet.data.Search;
   import com.metanet.events.NServerEvent;
   import com.metanet.remote.NServerConnector;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Command;
   
   public class StoreLogoutResult extends Command
   {
      
      [Inject]
      public var event:NServerEvent;
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var so:SharedObject;
      
      [Inject]
      public var search:Search;
      
      [Inject]
      public var server:NServerConnector;
      
      public function StoreLogoutResult()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.account.loggedInUserName = "";
         this.account.enteredUserName = "";
         this.account.enteredPassword = "";
         this.account.enteredPasswordRetype = "";
         this.account.loggedIn = false;
         this.so.clear();
         this.search.clear();
         this.server.clearCache();
      }
   }
}

