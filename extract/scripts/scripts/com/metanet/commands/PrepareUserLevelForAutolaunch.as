package com.metanet.commands
{
   import com.metanet.data.AccountDetails;
   import com.metanet.data.Level;
   import com.metanet.data.Options;
   import com.metanet.data.Search;
   import com.metanet.events.SearchEvent;
   import com.metanet.events.StartEvent;
   import com.metanet.remote.AmazonServerConnector;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import org.robotlegs.mvcs.Command;
   
   public class PrepareUserLevelForAutolaunch extends Command
   {
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var event:StartEvent;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var search:Search;
      
      [Inject]
      public var amazon:AmazonServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var server:NServerConnector;
      
      public function PrepareUserLevelForAutolaunch()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.options.selectedLevel = new Level();
         this.options.selectedLevel.id = this.event.levelID;
         this.options.selectedLevel.minimumHighscore = int.MAX_VALUE;
         this.search.details[0] = this.options.selectedLevel;
         commandMap.mapEvent(SearchEvent.ALL_LEVELS_LOADED,StartUnloadedLevel);
         this.amazon.loadLevel(this.event.levelID,false);
         if(this.account.loggedIn)
         {
            this.server.sendRequest(this.requestFactory.getPersonalBestDetailsFor(this.options.selectedLevel));
         }
      }
   }
}

