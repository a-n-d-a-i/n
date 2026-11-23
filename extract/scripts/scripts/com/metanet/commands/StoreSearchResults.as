package com.metanet.commands
{
   import com.metanet.data.EpisodeData;
   import com.metanet.data.Level;
   import com.metanet.data.Options;
   import com.metanet.data.Search;
   import com.metanet.events.NServerEvent;
   import com.metanet.events.SearchEvent;
   import org.robotlegs.mvcs.Command;
   
   public class StoreSearchResults extends Command
   {
      
      [Inject]
      public var event:NServerEvent;
      
      [Inject]
      public var search:Search;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var episodes:EpisodeData;
      
      public function StoreSearchResults()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc3_:Level = null;
         var _loc4_:XML = null;
         var _loc1_:XML = new XML("<results>" + this.event.data + "</results>");
         var _loc2_:XMLList = _loc1_..row;
         this.search.details = new Vector.<Level>();
         this.checkForEnd(_loc1_);
         for each(_loc4_ in _loc2_)
         {
            _loc3_ = this.levelFromXML(_loc4_);
            this.search.details[this.search.details.length] = _loc3_;
            this.search.detailsByID[_loc3_.id] = _loc3_;
         }
         dispatch(new SearchEvent(SearchEvent.SEARCH_RESULTS_UPDATED));
      }
      
      private function checkForEnd(param1:XML) : void
      {
         if(this.search.mode == Search.METANET)
         {
            if(this.episodes.numberBeaten * 5 < this.search.offset + 11)
            {
               this.search.finalPage = true;
            }
            else
            {
               this.search.finalPage = false;
            }
         }
         else if(String(param1..end.text()) == "End")
         {
            this.search.finalPage = true;
         }
         else
         {
            this.search.finalPage = false;
         }
      }
      
      private function levelFromXML(param1:XML) : Level
      {
         var _loc2_:Level = new Level();
         _loc2_.id = param1.level_id;
         if(this.search.detailsByID[_loc2_.id])
         {
            return this.search.detailsByID[_loc2_.id];
         }
         _loc2_.creatorName = param1.username;
         _loc2_.name = param1.level_name;
         _loc2_.personalBest = param1.personal_best;
         _loc2_.personalRating = param1.user_rating;
         if(param1.favorited_at.length())
         {
            _loc2_.favourite = true;
         }
         if(param1.mean_rating.length() > 0)
         {
            _loc2_.meanRating = Number(String(param1.mean_rating));
            _loc2_.published = true;
         }
         _loc2_.fullData = true;
         return _loc2_;
      }
   }
}

