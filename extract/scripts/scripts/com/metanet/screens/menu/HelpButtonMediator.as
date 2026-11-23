package com.metanet.screens.menu
{
   import com.metanet.events.MenuEvent;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class HelpButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:HelpButton;
      
      public function HelpButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.MOUSE_DOWN,this.clicked);
      }
      
      private function clicked(param1:MouseEvent) : void
      {
         dispatch(new MenuEvent(MenuEvent.SHOW_HELP));
      }
   }
}

