package
{
   import com.metanet.App;
   import com.metanet.data.AccountDetails;
   import com.metanet.events.InitializeEvent;
   import com.metanet.events.MenuEvent;
   import com.metanet.events.StartEvent;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Mediator;
   import simpleFramework.SimpleRenderer;
   
   public class NMediator extends Mediator
   {
      
      [Inject]
      public var sharedObject:SharedObject;
      
      [Inject]
      public var view:N;
      
      [Inject]
      public var app:App;
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var debugRenderer:SimpleRenderer;
      
      [Inject(name="gameStage")]
      public var gameStage:Sprite;
      
      [Inject(name="uiStage")]
      public var uiStage:Sprite;
      
      private var _screensWithAttractMode:Array = [MenuScreen,SiteLockScreen];
      
      private var _currentScreen:Class;
      
      private var _lastScreen:Class;
      
      public function NMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         dispatch(new InitializeEvent(InitializeEvent.INITIALIZE));
         addContextListener(StartEvent.START_LEVEL,this.handleStartGame);
         addContextListener(StartEvent.START_EPISODE,this.handleStartGame);
         addContextListener(StartEvent.START_CHALLENGE,this.handleStartGame);
         addContextListener(StartEvent.START_EDITOR,this.handleStartGame);
         addContextListener(StartEvent.RESUME_EPISODE,this.handleStartGame);
         addContextListener(StartEvent.RESUME_CHALLENGE,this.handleStartGame);
         addContextListener(MenuEvent.SHOW_LAST_SCREEN,this.showLastScreen);
         addContextListener(MenuEvent.SHOW_MAIN_MENU,this.showMainMenu);
         addContextListener(MenuEvent.SHOW_ACCOUNT,this.showAccount);
         addContextListener(MenuEvent.SHOW_CREDITS,this.showCredits);
         addContextListener(MenuEvent.SHOW_HELP,this.showHelp);
         addContextListener(MenuEvent.SHOW_STORY,this.showStory);
         addContextListener(MenuEvent.SHOW_USER_LEVELS,this.showUserLevels);
         addContextListener(MenuEvent.SHOW_EPISODES,this.showEpisodes);
         addContextListener(MenuEvent.SHOW_SITELOCK,this.showSitelock);
         this.gameStage.addEventListener(Event.ADDED_TO_STAGE,this.preventGameObjectsFromTriggeringRobotLegs);
         this.gameStage.addEventListener(Event.REMOVED_FROM_STAGE,this.preventGameObjectsFromTriggeringRobotLegs);
         this.createChildren();
         if(!this.account.loggedIn)
         {
            dispatch(new InitializeEvent(InitializeEvent.READY));
         }
         try
         {
            this.sharedObject.flush();
         }
         catch(in_error:Error)
         {
            dispatch(new InitializeEvent(InitializeEvent.SHARED_OBJECT_FAILED));
         }
      }
      
      private function preventGameObjectsFromTriggeringRobotLegs(param1:Event) : void
      {
         param1.stopPropagation();
      }
      
      private function createChildren() : void
      {
         this.view.addChild(this.gameStage);
         this.view.addChild(this.uiStage);
         addViewListener(Event.ENTER_FRAME,this.handleEnterFrame);
         this.view.createChildren();
         this.view.addChild(new DynamicPrompt());
         this.app.initialize();
         this.showScreen(PreloaderScreen);
      }
      
      private function handleEnterFrame(param1:Event) : void
      {
         this.app.tick();
      }
      
      private function handleStartGame(param1:StartEvent) : void
      {
         this.stopEverything();
      }
      
      private function stopEverything() : void
      {
         this._currentScreen = null;
         this.view.removeScreen();
         this.view.stage.focus = null;
      }
      
      private function showLastScreen(param1:Event) : void
      {
         if(Boolean(this._lastScreen) && this._lastScreen != PreloaderScreen)
         {
            this.showScreen(this._lastScreen);
         }
         else
         {
            this.showScreen(MenuScreen);
         }
      }
      
      private function showMainMenu(param1:Event = null) : void
      {
         this.showScreen(MenuScreen);
      }
      
      private function showCredits(param1:MenuEvent) : void
      {
         this.showScreen(CreditsScreen);
      }
      
      private function showAccount(param1:MenuEvent) : void
      {
         this.showScreen(AccountScreen);
      }
      
      private function showHelp(param1:MenuEvent) : void
      {
         this.showScreen(HelpScreen);
      }
      
      private function showStory(param1:MenuEvent) : void
      {
         this.showScreen(StoryScreen);
      }
      
      private function showUserLevels(param1:MenuEvent) : void
      {
         this.showScreen(UserLevelsScreen);
      }
      
      private function showEpisodes(param1:MenuEvent) : void
      {
         this.showScreen(EpisodesScreen);
      }
      
      private function showSitelock(param1:MenuEvent) : void
      {
         this.showScreen(SiteLockScreen);
      }
      
      private function showScreen(param1:Class) : void
      {
         this.view.stage.focus = null;
         if(this._currentScreen == param1)
         {
            return;
         }
         this._currentScreen = param1;
         this._lastScreen = param1;
         this.view.changeScreen(new param1());
         if(this._screensWithAttractMode.indexOf(param1) != -1)
         {
            this.app.showRandomReplay();
            this.gameStage.mouseChildren = false;
            this.gameStage.mouseEnabled = false;
         }
         else
         {
            this.app.stopReplay();
            this.gameStage.mouseChildren = true;
            this.gameStage.mouseEnabled = true;
         }
      }
   }
}

