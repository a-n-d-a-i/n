package com.metanet.events
{
   import flash.events.Event;
   
   public class SearchEvent extends Event
   {
      
      public static const SEARCH_RESULTS_UPDATED:String = "searchResultsUpdated";
      
      public static const SELECT_LEVEL:String = "levelSelected";
      
      public static const LOAD_NEXT_LEVEL:String = "loadNextLevel";
      
      public static var INITIATE_SEARCH:String = "initiateSearch";
      
      public static var ALL_LEVELS_LOADED:String = "allLevelsLoaded";
      
      public function SearchEvent(param1:String)
      {
         super(param1,false,false);
      }
      
      override public function clone() : Event
      {
         return new SearchEvent(type);
      }
   }
}

