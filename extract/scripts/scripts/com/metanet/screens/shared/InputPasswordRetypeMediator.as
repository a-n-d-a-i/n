package com.metanet.screens.shared
{
   import com.metanet.data.AccountDetails;
   import com.metanet.events.NServerEvent;
   import flash.events.Event;
   import org.robotlegs.mvcs.Mediator;
   
   public class InputPasswordRetypeMediator extends Mediator
   {
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var view:InputPasswordRetype;
      
      public function InputPasswordRetypeMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(Event.ENTER_FRAME,this.handleTextChanged);
         addContextListener(NServerEvent.LOGOUT_COMPLETE,this.handleLogoutComplete);
         this.view.field.displayAsPassword = true;
         this.view.field.multiline = false;
      }
      
      override public function onRemove() : void
      {
         this.account.enteredPasswordRetype = "";
      }
      
      private function handleTextChanged(param1:Event) : void
      {
         this.account.enteredPasswordRetype = this.view.field.text.split("\r").join("");
      }
      
      private function handleLogoutComplete(param1:NServerEvent) : void
      {
         this.view.field.text = "";
      }
   }
}

