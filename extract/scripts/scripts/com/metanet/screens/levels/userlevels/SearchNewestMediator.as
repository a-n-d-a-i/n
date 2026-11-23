package com.metanet.screens.levels.userlevels
{
   import com.metanet.data.Options;
   import com.metanet.data.Search;
   import com.metanet.events.SearchEvent;
   import com.metanet.global.SearchCriteria;
   import com.metanet.global.SearchSort;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class SearchNewestMediator extends Mediator
   {
      
      [Inject]
      public var search:Search;
      
      [Inject]
      public var options:Options;
      
      public function SearchNewestMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         this.search.clearTerms();
         this.search.addSearchTerms(SearchCriteria.MIN_RATING,[0]);
         this.search.sort = SearchSort.NEWEST;
         dispatch(new SearchEvent(SearchEvent.INITIATE_SEARCH));
      }
   }
}

