package com.metanet.commands
{
   import com.metanet.App;
   import com.metanet.data.Options;
   import com.metanet.events.StartEvent;
   import org.robotlegs.mvcs.Command;
   
   public class StartLevel extends Command
   {
      
      [Inject]
      public var event:StartEvent;
      
      [Inject]
      public var app:App;
      
      [Inject]
      public var options:Options;
      
      public function StartLevel()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.options.resetScoreOnDeath = true;
         this.options.scoreGoldImmediately = true;
         this.app.stopReplay();
         if(this.event.replayData)
         {
            this.app.watchPlayerSelectedReplay(this.event.levelData,this.event.replayData);
         }
         else
         {
            this.app.playSingleLevelFromBytes(this.event.levelData,this.event.levelID);
         }
      }
   }
}

