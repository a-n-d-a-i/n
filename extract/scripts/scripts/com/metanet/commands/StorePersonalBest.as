package com.metanet.commands
{
   import com.metanet.data.Options;
   import com.metanet.events.NServerEvent;
   import org.robotlegs.mvcs.Command;
   
   public class StorePersonalBest extends Command
   {
      
      [Inject]
      public var event:NServerEvent;
      
      [Inject]
      public var options:Options;
      
      public function StorePersonalBest()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:XML = new XML(this.event.data);
         this.options.selectedLevel.personalBest = _loc1_.row.personal_best;
      }
   }
}

