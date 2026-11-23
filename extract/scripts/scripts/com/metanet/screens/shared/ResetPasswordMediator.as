package com.metanet.screens.shared
{
   import com.metanet.data.AccountDetails;
   import com.metanet.remote.NRequest;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class ResetPasswordMediator extends Mediator
   {
      
      [Inject]
      public var view:ResetPassword;
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      public function ResetPasswordMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClicked);
      }
      
      private function handleClicked(param1:MouseEvent) : void
      {
         var _loc2_:NRequest = null;
         if(this.account.loggedIn)
         {
            _loc2_ = this.requestFactory.resetPasswordByUsername(this.account.loggedInUserName);
         }
         else if(this.account.enteredUserName != "")
         {
            _loc2_ = this.requestFactory.resetPasswordByUsername(this.account.enteredUserName);
         }
         else
         {
            _loc2_ = this.requestFactory.resetPasswordByEmail(this.account.email);
         }
         this.server.sendRequest(_loc2_);
      }
   }
}

