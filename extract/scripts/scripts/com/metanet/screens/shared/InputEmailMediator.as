package com.metanet.screens.shared
{
   import com.metanet.data.AccountDetails;
   import com.metanet.events.NServerEvent;
   import flash.events.Event;
   import org.robotlegs.mvcs.Mediator;
   
   public class InputEmailMediator extends Mediator
   {
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var view:InputEmail;
      
      public function InputEmailMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(Event.ENTER_FRAME,this.handleEnterFrame);
         addContextListener(NServerEvent.LOGOUT_COMPLETE,this.handleLogoutComplete);
         this.view.field.text = this.account.email;
         this.view.field.multiline = false;
      }
      
      private function handleEnterFrame(param1:Event) : void
      {
         if(!this.view.stage)
         {
            return;
         }
         if(this.view.stage.focus != this.view.field)
         {
            return;
         }
         this.account.email = this.view.field.text.split("\r").join("");
      }
      
      private function handleLogoutComplete(param1:NServerEvent) : void
      {
         this.view.field.text = "";
         this.account.email = "";
      }
   }
}

