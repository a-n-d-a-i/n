package com.metanet.screens.levels.mylevels
{
   import com.metanet.data.Options;
   import com.metanet.events.ConfirmationEvent;
   import com.metanet.events.InitializeEvent;
   import com.metanet.events.MenuEvent;
   import com.metanet.events.SearchEvent;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class PublishButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:PublishButton;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var options:Options;
      
      public function PublishButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
         addContextListener(SearchEvent.SELECT_LEVEL,this.handleLevelSelected);
         addContextListener(InitializeEvent.DELETED_CACHED_LEVEL,this.handleLevelDeletedFromCache);
      }
      
      private function handleLevelSelected(param1:SearchEvent) : void
      {
         this.updateState();
      }
      
      private function handleLevelDeletedFromCache(param1:InitializeEvent) : void
      {
         this.updateState();
      }
      
      private function updateState() : void
      {
         if(Boolean(this.options.selectedLevel.data) && !this.options.selectedLevel.waitingForUpload)
         {
            this.view.visible = true;
         }
         else
         {
            this.view.visible = false;
         }
      }
      
      private function handleClick(param1:Event) : void
      {
         var _loc2_:ConfirmationEvent = new ConfirmationEvent(ConfirmationEvent.CONFIRM_ACTION);
         _loc2_.message = "are you sure you want to publish this level (y/n)";
         _loc2_.yesEvent = new MenuEvent(MenuEvent.PUBLISH_LEVEL);
         dispatch(_loc2_);
      }
   }
}

