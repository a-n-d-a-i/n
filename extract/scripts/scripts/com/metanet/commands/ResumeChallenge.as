package com.metanet.commands
{
   import com.metanet.App;
   import com.metanet.data.EpisodeData;
   import com.metanet.data.Options;
   import com.metanet.global.SavedProperties;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Command;
   
   public class ResumeChallenge extends Command
   {
      
      [Inject]
      public var sharedObject:SharedObject;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var episodes:EpisodeData;
      
      [Inject]
      public var app:App;
      
      public function ResumeChallenge()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.options.resetScoreOnDeath = false;
         this.options.scoreGoldImmediately = false;
         this.app.stopReplay();
         this.app.useLevelSet(this.episodes.createLevelSetForColumn(this.options.selectedChallenge));
         this.app.resumeLevelSet(this.options.selectedLevelIndexInSearch,this.options.ticksToResumeWith);
         this.sharedObject.setProperty(SavedProperties.SAVED_CHALLENGE,this.options.selectedChallenge);
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

