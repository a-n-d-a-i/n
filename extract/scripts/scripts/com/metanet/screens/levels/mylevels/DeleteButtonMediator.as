package com.metanet.screens.levels.mylevels
{
   import com.metanet.data.Options;
   import com.metanet.data.Search;
   import com.metanet.events.ConfirmationEvent;
   import com.metanet.events.MenuEvent;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class DeleteButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:DeleteButton;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var search:Search;
      
      public function DeleteButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
      }
      
      private function handleClick(param1:Event) : void
      {
         var _loc2_:ConfirmationEvent = new ConfirmationEvent(ConfirmationEvent.CONFIRM_ACTION);
         _loc2_.message = "do you really want to delete this level? (y/n)";
         _loc2_.yesEvent = new MenuEvent(MenuEvent.DELETE_LEVEL);
         dispatch(_loc2_);
      }
   }
}

