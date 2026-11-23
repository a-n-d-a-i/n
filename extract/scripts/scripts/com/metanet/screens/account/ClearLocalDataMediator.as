package com.metanet.screens.account
{
   import com.metanet.events.MenuEvent;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class ClearLocalDataMediator extends Mediator
   {
      
      public function ClearLocalDataMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         dispatch(new MenuEvent(MenuEvent.RESET_LOCAL_DATA));
         dispatch(new MenuEvent(MenuEvent.SHOW_MAIN_MENU));
      }
   }
}

