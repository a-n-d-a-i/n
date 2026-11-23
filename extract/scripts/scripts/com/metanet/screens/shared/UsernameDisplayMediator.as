package com.metanet.screens.shared
{
   import com.metanet.data.AccountDetails;
   import com.metanet.events.NServerEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class UsernameDisplayMediator extends Mediator
   {
      
      [Inject]
      public var view:UsernameDisplay;
      
      [Inject]
      public var account:AccountDetails;
      
      public function UsernameDisplayMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         this.view.text.text = this.account.loggedInUserName;
         addContextListener(NServerEvent.LOGIN_COMPLETE,this.handleLoginComplete);
      }
      
      private function handleLoginComplete(param1:NServerEvent) : void
      {
         this.view.text.text = this.account.loggedInUserName;
      }
   }
}

