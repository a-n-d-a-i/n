package com.metanet.screens.shared
{
   import com.metanet.events.MenuEvent;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class LoginButtonMediator extends Mediator
   {
      
      public function LoginButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         dispatch(new MenuEvent(MenuEvent.LOGIN));
      }
   }
}

