package com.metanet.commands
{
   import com.metanet.data.Options;
   import com.metanet.data.Search;
   import com.metanet.events.SearchEvent;
   import com.metanet.events.StartEvent;
   import org.robotlegs.mvcs.Command;
   
   public class StartUnloadedLevel extends Command
   {
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var search:Search;
      
      public function StartUnloadedLevel()
      {
         super();
      }
      
      override public function execute() : void
      {
         commandMap.unmapEvent(SearchEvent.ALL_LEVELS_LOADED,StartUnloadedLevel);
         var _loc1_:StartEvent = new StartEvent(StartEvent.START_LEVEL);
         _loc1_.levelID = this.options.selectedLevel.id;
         _loc1_.levelData = this.options.selectedLevel.data;
         dispatch(_loc1_);
         this.search.clear();
      }
   }
}

