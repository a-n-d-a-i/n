package com.metanet.commands
{
   import com.metanet.data.EpisodeData;
   import com.metanet.data.Options;
   import org.robotlegs.mvcs.Command;
   
   public class BeatEpisode extends Command
   {
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var episodeData:EpisodeData;
      
      public function BeatEpisode()
      {
         super();
      }
      
      override public function execute() : void
      {
         if(this.options.selectedEpisode >= this.episodeData.numberOfSets || this.episodeData.isBeaten(this.options.selectedEpisode))
         {
            return;
         }
         this.episodeData.beatEpisodeFromGameplay(this.options.selectedEpisode);
      }
   }
}

