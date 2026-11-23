package com.metanet.commands
{
   import com.metanet.data.AccountDetails;
   import com.metanet.events.InitializeEvent;
   import org.robotlegs.mvcs.Command;
   
   public class StartOfflineMode extends Command
   {
      
      [Inject]
      public var account:AccountDetails;
      
      public function StartOfflineMode()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.account.useDatabase = false;
         dispatch(new InitializeEvent(InitializeEvent.READY));
      }
   }
}

