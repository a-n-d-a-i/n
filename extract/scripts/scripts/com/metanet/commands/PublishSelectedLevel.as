package com.metanet.commands
{
   import com.metanet.data.Options;
   import com.metanet.remote.NRequest;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import org.robotlegs.mvcs.Command;
   
   public class PublishSelectedLevel extends Command
   {
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      public function PublishSelectedLevel()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:NRequest = this.requestFactory.commitLevel(this.options.selectedLevel);
         this.server.sendRequest(_loc1_);
         this.server.clearCache();
      }
   }
}

