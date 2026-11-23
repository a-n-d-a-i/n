package com.metanet.commands
{
   import com.metanet.data.AccountDetails;
   import com.metanet.events.MenuEvent;
   import com.metanet.remote.NRequest;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import org.robotlegs.mvcs.Command;
   
   public class Login extends Command
   {
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var server:NServerConnector;
      
      public function Login()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:String = this.account.enteredUserName;
         var _loc2_:String = this.account.enteredPassword;
         if(_loc1_ == "" || _loc2_ == "")
         {
            if(this.account.loggedIn)
            {
               dispatch(new MenuEvent(MenuEvent.LOGOUT));
            }
            return;
         }
         var _loc3_:NRequest = this.requestFactory.login(_loc1_,_loc2_);
         _loc3_.priority = true;
         this.server.sendRequest(_loc3_);
      }
   }
}

