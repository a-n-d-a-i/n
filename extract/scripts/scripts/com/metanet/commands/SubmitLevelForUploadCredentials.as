package com.metanet.commands
{
   import com.metanet.data.Level;
   import com.metanet.data.Options;
   import com.metanet.data.Search;
   import com.metanet.remote.AmazonServerConnector;
   import org.robotlegs.mvcs.Command;
   
   public class SubmitLevelForUploadCredentials extends Command
   {
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var search:Search;
      
      [Inject]
      public var amazon:AmazonServerConnector;
      
      public function SubmitLevelForUploadCredentials()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:Level = this.options.selectedLevel;
         if(_loc1_.isNew)
         {
            this.amazon.uploadNewLevel(_loc1_);
            this.search.details[this.search.details.length] = _loc1_;
            ++this.search.levelsDownloaded;
         }
         else
         {
            this.amazon.uploadExistingLevel(_loc1_);
         }
         _loc1_.isNew = false;
      }
   }
}

