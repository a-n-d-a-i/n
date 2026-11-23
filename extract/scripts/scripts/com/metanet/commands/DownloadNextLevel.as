package com.metanet.commands
{
   import com.metanet.data.EpisodeData;
   import com.metanet.data.Level;
   import com.metanet.data.Search;
   import com.metanet.events.SearchEvent;
   import com.metanet.remote.AmazonServerConnector;
   import org.robotlegs.mvcs.Command;
   
   public class DownloadNextLevel extends Command
   {
      
      [Inject]
      public var search:Search;
      
      [Inject]
      public var episodes:EpisodeData;
      
      [Inject]
      public var amazon:AmazonServerConnector;
      
      public function DownloadNextLevel()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:int = this.search.levelsDownloaded;
         var _loc2_:Level = this.search.details[_loc1_];
         if(_loc2_.data)
         {
            ++this.search.levelsDownloaded;
            this.next();
            return;
         }
         var _loc3_:int = Number(_loc2_.id) - 1;
         if(_loc3_ < 1000)
         {
            _loc2_.data = this.episodes.getLevel(Math.floor(_loc3_ / 5),_loc3_ % 5);
            ++this.search.levelsDownloaded;
            this.next();
         }
         else
         {
            this.amazon.loadLevel(_loc2_.id,!_loc2_.published);
         }
      }
      
      private function next() : void
      {
         if(this.search.levelsDownloaded < this.search.details.length)
         {
            dispatch(new SearchEvent(SearchEvent.LOAD_NEXT_LEVEL));
         }
      }
   }
}

