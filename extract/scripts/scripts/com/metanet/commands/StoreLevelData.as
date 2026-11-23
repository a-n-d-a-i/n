package com.metanet.commands
{
   import com.foxarc.util.Base64;
   import com.metanet.data.Search;
   import com.metanet.events.NServerEvent;
   import com.metanet.events.SearchEvent;
   import flash.utils.ByteArray;
   import org.robotlegs.mvcs.Command;
   
   public class StoreLevelData extends Command
   {
      
      [Inject]
      public var event:NServerEvent;
      
      [Inject]
      public var search:Search;
      
      public function StoreLevelData()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:ByteArray = null;
         if(this.event.type == NServerEvent.LEVEL_DATA_LOADED)
         {
            _loc1_ = Base64.decode(this.event.data);
            _loc1_.uncompress();
         }
         this.search.details[this.search.levelsDownloaded].loaded = true;
         this.search.details[this.search.levelsDownloaded].data = _loc1_;
         ++this.search.levelsDownloaded;
         if(this.search.levelsDownloaded < this.search.details.length)
         {
            dispatch(new SearchEvent(SearchEvent.LOAD_NEXT_LEVEL));
         }
         else
         {
            dispatch(new SearchEvent(SearchEvent.ALL_LEVELS_LOADED));
         }
      }
   }
}

