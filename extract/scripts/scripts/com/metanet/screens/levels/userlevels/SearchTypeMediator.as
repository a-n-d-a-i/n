package com.metanet.screens.levels.userlevels
{
   import com.metanet.data.Options;
   import com.metanet.data.Search;
   import com.metanet.global.SearchCriteria;
   import com.metanet.global.SearchSort;
   import com.metanet.ui.BasicComboBoxEvent;
   import flash.events.Event;
   import org.robotlegs.mvcs.Mediator;
   
   public class SearchTypeMediator extends Mediator
   {
      
      [Inject]
      public var view:SearchTypeDropdown;
      
      [Inject]
      public var playOptions:Options;
      
      [Inject]
      public var search:Search;
      
      private var _sortTypes:Array = [SearchSort.RATING,SearchSort.RELEVANCE,SearchSort.NEWEST,SearchSort.NEWEST,SearchSort.RATING,SearchSort.RATING];
      
      public function SearchTypeMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         this.view.values = [SearchCriteria.USERNAME,SearchCriteria.LEVEL_NAME,SearchCriteria.MAX_DATE,SearchCriteria.MIN_DATE,SearchCriteria.MAX_RATING,SearchCriteria.MIN_RATING];
         this.view.labels = ["Author","Title","Before YYYY-MM-DD","After YYYY-MM-DD","Max Rating","Min Rating"];
         this.view.addEventListener(BasicComboBoxEvent.CHANGED,this.handleSelectionChanged);
      }
      
      private function handleSelectionChanged(param1:Event) : void
      {
         this.playOptions.enteredType = this.view.selectedValue;
         this.search.sort = this._sortTypes[this.view.selectedIndex];
      }
   }
}

