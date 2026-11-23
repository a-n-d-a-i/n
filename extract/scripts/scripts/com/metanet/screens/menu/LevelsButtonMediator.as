package com.metanet.screens.menu
{
   import com.metanet.data.AccountDetails;
   import com.metanet.events.MenuEvent;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class LevelsButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:UserLevelsButton;
      
      [Inject]
      public var account:AccountDetails;
      
      public function LevelsButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         if(!this.account.useDatabase)
         {
            this.view.visible = false;
         }
         else
         {
            addViewListener(MouseEvent.MOUSE_DOWN,this.clicked);
         }
      }
      
      private function clicked(param1:MouseEvent) : void
      {
         dispatch(new MenuEvent(MenuEvent.SHOW_USER_LEVELS));
      }
   }
}

