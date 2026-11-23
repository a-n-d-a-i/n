package com.metanet.screens.shared
{
   import com.metanet.events.MenuEvent;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class ReturnToMenuButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:ReturnToMenuButton;
      
      public function ReturnToMenuButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.MOUSE_DOWN,this.clicked);
      }
      
      private function clicked(param1:MouseEvent) : void
      {
         dispatch(new MenuEvent(MenuEvent.SHOW_MAIN_MENU));
      }
   }
}

