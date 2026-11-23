package com.metanet.screens.levels.userlevels
{
   import com.metanet.data.Options;
   import com.metanet.data.Search;
   import com.metanet.events.SearchEvent;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class SearchButtonMediator extends Mediator
   {
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var search:Search;
      
      public function SearchButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.MOUSE_DOWN,this.handleClicked);
      }
      
      private function handleClicked(param1:MouseEvent) : void
      {
         this.updateTerms();
         if(!this.search.isLegal)
         {
            return;
         }
         dispatch(new SearchEvent(SearchEvent.INITIATE_SEARCH));
      }
      
      private function updateTerms() : void
      {
         this.search.clearTerms();
         if(this.options.selectedType != null)
         {
            this.search.clearTerm(this.options.selectedType);
         }
         if(this.options.enteredType == null)
         {
            return;
         }
         this.search.addSearchTerms(this.options.enteredType,[this.options.enteredTerm]);
         this.options.selectedTerm = this.options.enteredTerm;
         this.options.selectedType = this.options.enteredType;
      }
   }
}

