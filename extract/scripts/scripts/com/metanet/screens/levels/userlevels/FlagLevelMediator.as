package com.metanet.screens.levels.userlevels
{
   import com.metanet.data.Options;
   import com.metanet.events.SearchEvent;
   import com.metanet.remote.NRequest;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class FlagLevelMediator extends Mediator
   {
      
      [Inject]
      public var view:FlagLevelButton;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var options:Options;
      
      public function FlagLevelMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
         addContextListener(SearchEvent.SELECT_LEVEL,this.handleSelectLevel);
      }
      
      private function handleSelectLevel(param1:SearchEvent) : void
      {
         if(Number(this.options.selectedLevel.id) < 1000)
         {
            this.view.visible = false;
         }
         else
         {
            this.view.visible = true;
         }
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         var _loc2_:NRequest = this.requestFactory.flagLevel(this.options.selectedLevel.id);
         this.server.sendRequest(_loc2_);
      }
   }
}

