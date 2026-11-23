package com.metanet.screens.menu
{
   import com.metanet.events.MenuEvent;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class AccountButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:AccountButton;
      
      public function AccountButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.MOUSE_DOWN,this.clicked);
      }
      
      private function clicked(param1:MouseEvent) : void
      {
         dispatch(new MenuEvent(MenuEvent.SHOW_ACCOUNT));
      }
   }
}

