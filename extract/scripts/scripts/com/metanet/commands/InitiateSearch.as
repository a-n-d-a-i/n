package com.metanet.commands
{
   import com.metanet.data.EpisodeData;
   import com.metanet.data.Options;
   import com.metanet.data.Search;
   import com.metanet.global.SearchCriteria;
   import com.metanet.remote.NRequest;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import org.robotlegs.mvcs.Command;
   
   public class InitiateSearch extends Command
   {
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var search:Search;
      
      [Inject]
      public var episodes:EpisodeData;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      public function InitiateSearch()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.server.cancelRequests("loadLevel");
         this.search.levelsDownloaded = 0;
         this.options.selectedLevelIndexInSearch = -1;
         this.options.selectedLevel = null;
         if(this.search.mode == Search.METANET)
         {
            this.searchForMetanetLevels();
            return;
         }
         if(this.search.mode == Search.MY_LEVELS)
         {
            this.search.addSearchTerms(SearchCriteria.USER_ID,["self"]);
         }
         else if(this.search.getSearchTerms(SearchCriteria.USER_ID) == "self")
         {
            this.search.clearTerm(SearchCriteria.USER_ID);
         }
         this.searchForUserLevels();
      }
      
      private function searchForMetanetLevels() : void
      {
         var _loc1_:NRequest = this.requestFactory.getBeatenLevels(this.search.offset,this.episodes.beaten);
         this.server.sendRequest(_loc1_);
      }
      
      private function searchForUserLevels() : void
      {
         var _loc1_:NRequest = this.requestFactory.search(this.search);
         this.server.sendRequest(_loc1_);
      }
   }
}

