package com.metanet.screens.shared
{
   import com.metanet.data.AccountDetails;
   import com.metanet.events.MenuEvent;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class SignupButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:SignupButton;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var account:AccountDetails;
      
      public function SignupButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         dispatch(new MenuEvent(MenuEvent.SIGNUP));
      }
   }
}

