package com.metanet.screens.levels.userlevels
{
   import com.metanet.data.Level;
   import com.metanet.data.Options;
   import com.metanet.events.NServerEvent;
   import com.metanet.events.SearchEvent;
   import com.metanet.remote.NRequest;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import com.metanet.ui.BasicButton;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class RatingMediator extends Mediator
   {
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var options:Options;
      
      protected var _rating:int;
      
      protected var _view:BasicButton;
      
      public function RatingMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
         addContextListener(SearchEvent.SELECT_LEVEL,this.updateSelectedState);
         addContextListener(NServerEvent.RATE_COMPLETE,this.updateSelectedState);
      }
      
      private function updateSelectedState(param1:*) : void
      {
         if(Number(this.options.selectedLevel.id) < 1000)
         {
            this._view.visible = false;
         }
         else
         {
            this._view.visible = true;
         }
         if(this.options.selectedLevel.personalRating == this._rating)
         {
            this._view.selected = true;
         }
         else
         {
            this._view.selected = false;
         }
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         this.sendRating(this._rating);
      }
      
      private function sendRating(param1:int) : void
      {
         var _loc2_:Level = this.options.selectedLevel;
         _loc2_.personalRating = this._rating;
         var _loc3_:NRequest = this.requestFactory.rateLevel(_loc2_.id,param1);
         this.server.sendRequest(_loc3_);
      }
   }
}

