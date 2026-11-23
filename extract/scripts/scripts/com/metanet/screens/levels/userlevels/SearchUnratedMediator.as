package com.metanet.screens.levels.userlevels
{
   import com.metanet.data.Options;
   import com.metanet.data.Search;
   import com.metanet.events.SearchEvent;
   import com.metanet.global.SearchCriteria;
   import com.metanet.global.SearchSort;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class SearchUnratedMediator extends Mediator
   {
      
      [Inject]
      public var search:Search;
      
      [Inject]
      public var options:Options;
      
      public function SearchUnratedMediator()
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
         this.search.addSearchTerms(SearchCriteria.MAX_RATING,[0]);
         this.search.sort = SearchSort.OLDEST;
         dispatch(new SearchEvent(SearchEvent.INITIATE_SEARCH));
      }
   }
}

