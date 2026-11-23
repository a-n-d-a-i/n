package com.metanet.screens.levels.mylevels
{
   import com.metanet.data.AccountDetails;
   import com.metanet.data.Options;
   import com.metanet.events.NServerEvent;
   import com.metanet.events.StartEvent;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class NewButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:NewButton;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var account:AccountDetails;
      
      public function NewButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
         addContextListener(NServerEvent.DELETE_LEVEL_COMPLETE,this.handleUncommitedLevelRemoved);
         addContextListener(NServerEvent.COMMIT_LEVEL_COMPLETE,this.handleUncommitedLevelRemoved);
         this.view.visible = this.account.canCreateNewLevel;
      }
      
      private function handleUncommitedLevelRemoved(param1:*) : void
      {
         this.view.visible = true;
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         this.options.selectedLevelIndexInSearch = -1;
         this.options.selectedLevel = null;
         dispatch(new StartEvent(StartEvent.START_EDITOR));
      }
   }
}

