package com.metanet.screens.levels
{
   import com.metanet.data.Options;
   import com.metanet.events.NServerEvent;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class FavouriteButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:FavouriteButton;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var options:Options;
      
      public function FavouriteButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
         addContextListener(NServerEvent.UNFAVOURITE_COMPLETE,this.handleUnfavourited);
         addContextListener(NServerEvent.FAVOURITE_COMPLETE,this.handleFavourited);
         addContextListener(NServerEvent.FAVOURITE_FAILED,this.handleFavouriteFailed);
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         var _loc2_:String = this.options.selectedLevel.id;
         this.server.sendRequest(this.requestFactory.favouriteLevel(_loc2_));
         this.view.visible = false;
         this.options.selectedLevel.favourite = true;
      }
      
      private function handleUnfavourited(param1:NServerEvent) : void
      {
         this.view.visible = true;
      }
      
      private function handleFavourited(param1:NServerEvent) : void
      {
         var _loc2_:XML = new XML(param1.data);
         if(_loc2_..error.length() > 0)
         {
            this.view.visible = true;
         }
      }
      
      private function handleFavouriteFailed(param1:NServerEvent) : void
      {
         this.view.visible = true;
      }
   }
}

