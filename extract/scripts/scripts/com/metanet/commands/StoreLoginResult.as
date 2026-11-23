package com.metanet.commands
{
   import com.metanet.data.AccountDetails;
   import com.metanet.events.NServerEvent;
   import com.metanet.global.SavedProperties;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Command;
   
   public class StoreLoginResult extends Command
   {
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var so:SharedObject;
      
      [Inject]
      public var event:NServerEvent;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var server:NServerConnector;
      
      public function StoreLoginResult()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:XML = new XML(this.event.data);
         if(!_loc1_.success.length() > 0)
         {
            return;
         }
         this.account.userID = _loc1_.user_id.text();
         this.account.loggedIn = true;
         this.account.loggedInUserName = this.account.enteredUserName;
         this.account.enteredPassword = "";
         this.account.cookie = _loc1_.success.text();
         this.account.canAddFavourites = String(_loc1_.fave_count.text()) != "MAXIMUM REACHED";
         this.account.canCreateNewLevel = String(_loc1_.uncommitted_count.text()) != "MAXIMUM REACHED";
         this.storeLoginDetailsInSharedObject();
         dispatch(new NServerEvent(NServerEvent.READY_TO_SYNC));
      }
      
      private function storeLoginDetailsInSharedObject() : void
      {
         this.so.setProperty(SavedProperties.USERNAME,this.account.loggedInUserName);
         this.so.setProperty(SavedProperties.USER_ID,this.account.userID);
         this.so.setProperty(SavedProperties.COOKIE,this.account.cookie);
      }
   }
}

