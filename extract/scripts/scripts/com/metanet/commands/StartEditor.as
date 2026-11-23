package com.metanet.commands
{
   import com.metanet.data.AccountDetails;
   import com.metanet.data.Level;
   import com.metanet.data.Options;
   import com.metanet.data.Search;
   import com.metanet.screens.editor.EditorApp;
   import org.robotlegs.mvcs.Command;
   
   public class StartEditor extends Command
   {
      
      [Inject]
      public var search:Search;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var account:AccountDetails;
      
      public function StartEditor()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:EditorApp = new EditorApp();
         injector.injectInto(_loc1_);
         _loc1_.init();
         if(this.options.selectedLevelIndexInSearch == -1)
         {
            this.options.selectedLevel = new Level();
            this.options.selectedLevel.creatorName = this.account.loggedInUserName;
            _loc1_.newLevel(this.options.selectedLevel);
         }
         else
         {
            _loc1_.loadLevel(this.options.selectedLevel);
         }
      }
   }
}

