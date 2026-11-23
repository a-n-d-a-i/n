package com.metanet.screens.levels
{
   import com.metanet.data.Search;
   import com.metanet.events.SearchEvent;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class PreviousButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:PreviousButton;
      
      [Inject]
      public var search:Search;
      
      public function PreviousButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.MOUSE_DOWN,this.handleClicked);
         addContextListener(SearchEvent.SEARCH_RESULTS_UPDATED,this.handleSearchCompleted);
         this.view.visible = this.search.offset > 0;
      }
      
      private function handleClicked(param1:MouseEvent) : void
      {
         this.search.offset -= this.search.rowCount;
         this.view.visible = false;
         dispatch(new SearchEvent(SearchEvent.INITIATE_SEARCH));
      }
      
      private function handleSearchCompleted(param1:SearchEvent) : void
      {
         this.view.visible = this.search.offset > 0;
      }
   }
}

