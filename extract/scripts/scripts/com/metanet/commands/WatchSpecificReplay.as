package com.metanet.commands
{
   import com.metanet.data.Options;
   import com.metanet.events.NServerEvent;
   import com.metanet.events.StartEvent;
   import org.robotlegs.mvcs.Command;
   
   public class WatchSpecificReplay extends Command
   {
      
      [Inject]
      public var event:NServerEvent;
      
      [Inject]
      public var options:Options;
      
      public function WatchSpecificReplay()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:StartEvent = new StartEvent(StartEvent.START_LEVEL);
         _loc1_.levelID = this.options.selectedLevel.id;
         _loc1_.levelData = this.options.selectedLevel.data;
         _loc1_.replayData = this.event.data;
         dispatch(_loc1_);
      }
   }
}

