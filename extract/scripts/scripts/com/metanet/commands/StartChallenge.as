package com.metanet.commands
{
   import com.metanet.App;
   import com.metanet.data.EpisodeData;
   import com.metanet.data.Options;
   import com.metanet.global.SavedProperties;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Command;
   
   public class StartChallenge extends Command
   {
      
      [Inject]
      public var sharedObject:SharedObject;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var episodes:EpisodeData;
      
      [Inject]
      public var app:App;
      
      public function StartChallenge()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.options.resetScoreOnDeath = false;
         this.options.scoreGoldImmediately = false;
         this.options.selectedEpisode = -1;
         this.app.stopReplay();
         this.app.useLevelSet(this.episodes.createLevelSetForColumn(this.options.selectedChallenge));
         this.app.startLevelSet();
         this.sharedObject.setProperty(SavedProperties.SAVED_CHALLENGE,this.options.selectedChallenge);
         delete this.sharedObject.data[SavedProperties.SAVED_EPISODE];
         try
         {
            this.sharedObject.flush();
         }
         catch(e:Error)
         {
         }
      }
   }
}

