package com.metanet.screens.menu
{
   import com.metanet.events.MenuEvent;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class EpisodesButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:EpisodesButton;
      
      public function EpisodesButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.MOUSE_DOWN,this.clicked);
      }
      
      private function clicked(param1:MouseEvent) : void
      {
         dispatch(new MenuEvent(MenuEvent.SHOW_EPISODES));
      }
   }
}

