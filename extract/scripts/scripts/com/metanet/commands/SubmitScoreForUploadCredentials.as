package com.metanet.commands
{
   import com.metanet.data.GameStats;
   import com.metanet.remote.AmazonServerConnector;
   import org.robotlegs.mvcs.Command;
   
   public class SubmitScoreForUploadCredentials extends Command
   {
      
      [Inject]
      public var amazon:AmazonServerConnector;
      
      [Inject]
      public var lastGame:GameStats;
      
      public function SubmitScoreForUploadCredentials()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.amazon.uploadReplay(this.lastGame.level,this.lastGame.score,this.lastGame.replayBytes);
      }
   }
}

