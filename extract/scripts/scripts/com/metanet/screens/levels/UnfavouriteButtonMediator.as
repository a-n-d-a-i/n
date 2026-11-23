package com.metanet.screens.levels
{
   import com.metanet.data.Options;
   import com.metanet.events.NServerEvent;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class UnfavouriteButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:UnfavouriteButton;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var options:Options;
      
      public function UnfavouriteButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
         addContextListener(NServerEvent.FAVOURITE_COMPLETE,this.handleFavourited);
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         var _loc2_:String = this.options.selectedLevel.id;
         this.server.sendRequest(this.requestFactory.unfavouriteLevel(_loc2_));
         this.view.visible = false;
         this.options.selectedLevel.favourite = false;
      }
      
      private function handleFavourited(param1:NServerEvent) : void
      {
         var _loc2_:XML = new XML(param1.data);
         if(_loc2_..error.length() > 0)
         {
            return;
         }
         this.view.visible = true;
      }
   }
}

