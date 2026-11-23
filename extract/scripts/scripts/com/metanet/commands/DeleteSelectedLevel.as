package com.metanet.commands
{
   import com.metanet.data.Options;
   import com.metanet.remote.NRequest;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import org.robotlegs.mvcs.Command;
   
   public class DeleteSelectedLevel extends Command
   {
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      [Inject]
      public var options:Options;
      
      public function DeleteSelectedLevel()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:NRequest = this.requestFactory.deleteLevel(this.options.selectedLevel);
         this.server.sendRequest(_loc1_);
      }
   }
}

