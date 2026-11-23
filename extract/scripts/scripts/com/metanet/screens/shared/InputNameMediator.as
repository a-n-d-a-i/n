package com.metanet.screens.shared
{
   import com.metanet.data.AccountDetails;
   import com.metanet.events.NServerEvent;
   import flash.events.Event;
   import org.robotlegs.mvcs.Mediator;
   
   public class InputNameMediator extends Mediator
   {
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var view:InputName;
      
      public function InputNameMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(Event.ENTER_FRAME,this.handleEnterFrame);
         addContextListener(NServerEvent.LOGOUT_COMPLETE,this.handleLogoutComplete);
         this.view.field.multiline = false;
         this.view.field.restrict = " _./-a-z0-9+";
         if(this.account.loggedInUserName != "")
         {
            this.view.field.text = this.account.loggedInUserName;
         }
         else
         {
            this.view.field.text = this.account.enteredUserName;
         }
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
         this.account.enteredUserName = this.view.field.text.split("\r").join("");
      }
      
      private function handleLogoutComplete(param1:NServerEvent) : void
      {
         this.view.field.text = "";
      }
   }
}

