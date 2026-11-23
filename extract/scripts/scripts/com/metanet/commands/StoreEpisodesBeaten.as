package com.metanet.commands
{
   import com.metanet.data.EpisodeData;
   import com.metanet.events.InitializeEvent;
   import com.metanet.events.NServerEvent;
   import org.robotlegs.mvcs.Command;
   
   public class StoreEpisodesBeaten extends Command
   {
      
      [Inject]
      public var event:NServerEvent;
      
      [Inject]
      public var episodeData:EpisodeData;
      
      public function StoreEpisodesBeaten()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:XML = new XML(this.event.data);
         var _loc2_:XMLList = _loc1_..episode.text();
         this.episodeData.syncWithServerData(_loc2_);
         dispatch(new InitializeEvent(InitializeEvent.READY));
      }
   }
}

