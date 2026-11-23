package com.metanet.commands
{
   import com.metanet.data.AccountDetails;
   import com.metanet.events.NServerEvent;
   import org.robotlegs.mvcs.Command;
   
   public class CheckForMaximumLevels extends Command
   {
      
      [Inject]
      public var event:NServerEvent;
      
      [Inject]
      public var account:AccountDetails;
      
      public function CheckForMaximumLevels()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:XML = new XML(this.event.data);
         if(String(_loc1_.success.text()) == "MAXIMUM REACHED")
         {
            this.account.canCreateNewLevel = false;
         }
      }
   }
}

