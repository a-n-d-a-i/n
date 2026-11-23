package com.metanet.screens.shared
{
   import com.metanet.data.AccountDetails;
   import com.metanet.events.NServerEvent;
   import flash.events.Event;
   import org.robotlegs.mvcs.Mediator;
   
   public class InputPasswordMediator extends Mediator
   {
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var view:InputPassword;
      
      public function InputPasswordMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(Event.ENTER_FRAME,this.handleEnterFrame);
         addContextListener(NServerEvent.LOGOUT_COMPLETE,this.handleLogoutComplete);
         this.view.field.displayAsPassword = true;
         this.view.field.multiline = false;
      }
      
      override public function onRemove() : void
      {
         this.account.enteredPassword = "";
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
         this.account.enteredPassword = this.view.field.text.split("\r").join("");
      }
      
      private function handleLogoutComplete(param1:NServerEvent) : void
      {
         this.view.field.text = "";
      }
   }
}

