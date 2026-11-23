package com.metanet.commands
{
   import com.metanet.data.Level;
   import com.metanet.data.Options;
   import com.metanet.data.Search;
   import com.metanet.events.NServerEvent;
   import com.metanet.events.SearchEvent;
   import org.robotlegs.mvcs.Command;
   
   public class RemoveLevelFromSearch extends Command
   {
      
      [Inject]
      public var event:NServerEvent;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var search:Search;
      
      public function RemoveLevelFromSearch()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:Level = this.search.detailsByID[this.event.referenceLevel];
         if(!_loc1_)
         {
            return;
         }
         this.search.removeLevel(_loc1_);
         if(this.options.selectedLevel == _loc1_)
         {
            this.options.selectedLevelIndexInSearch = -1;
            this.options.selectedLevel = null;
         }
         dispatch(new SearchEvent(SearchEvent.SEARCH_RESULTS_UPDATED));
      }
   }
}

