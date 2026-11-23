package
{
   import com.metanet.App;
   import com.metanet.App_MultiPurpose;
   import com.metanet.commands.CommandMappings;
   import com.metanet.data.AccountDetails;
   import com.metanet.data.AttractMode;
   import com.metanet.data.EpisodeData;
   import com.metanet.data.GameStats;
   import com.metanet.data.Options;
   import com.metanet.data.Search;
   import com.metanet.remote.AmazonServerConnector;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import com.metanet.screens.account.AccountMappings;
   import com.metanet.screens.credits.CreditsMediator;
   import com.metanet.screens.episodes.EpisodesScreenMediator;
   import com.metanet.screens.game.ControlDisplayMediator;
   import com.metanet.screens.help.HelpMappings;
   import com.metanet.screens.levels.LevelsMappings;
   import com.metanet.screens.menu.MenuMappings;
   import com.metanet.screens.shared.SharedMappings;
   import com.metanet.ui.GlobalKeys;
   import com.metanet.ui.InputRelay;
   import com.metanet.ui.KeyNames;
   import com.metanet.ui.PlayerKeys;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Context;
   import simpleFramework.SimpleInput;
   import simpleFramework.SimpleRenderer;
   
   public class AppContext extends Context
   {
      
      public function AppContext(param1:DisplayObjectContainer)
      {
         super(param1);
      }
      
      override public function startup() : void
      {
         mediatorMap.mapView(EpisodesScreen,EpisodesScreenMediator);
         mediatorMap.mapView(CreditsScreen,CreditsMediator);
         mediatorMap.mapView(ControlDisplay,ControlDisplayMediator);
         SharedMappings.mapMediators(mediatorMap);
         AccountMappings.mapMediators(mediatorMap);
         MenuMappings.mapMediators(mediatorMap);
         LevelsMappings.mapMediators(mediatorMap);
         HelpMappings.mapMediators(mediatorMap);
         _injector.mapSingletonOf(App,App_MultiPurpose);
         _injector.mapSingleton(GlobalKeys);
         _injector.mapSingleton(EpisodeData);
         _injector.mapSingleton(GameStats);
         _injector.mapSingleton(AttractMode);
         _injector.mapSingleton(NRequestFactory);
         _injector.mapSingleton(KeyNames);
         _injector.mapSingleton(NServerConnector);
         _injector.mapSingleton(AmazonServerConnector);
         _injector.mapSingleton(AccountDetails);
         _injector.mapSingleton(Options);
         _injector.mapSingleton(Search);
         _injector.mapSingleton(PlayerKeys,"coop");
         _injector.mapSingleton(PlayerKeys,"solo");
         _injector.mapSingleton(Sprite,"gameStage");
         _injector.mapSingleton(Sprite,"uiStage");
         var _loc1_:InputRelay = new InputRelay(contextView.stage);
         _injector.mapValue(InputRelay,_loc1_);
         _injector.mapValue(LoaderInfo,contextView.loaderInfo);
         _injector.mapValue(SimpleRenderer,new SimpleRenderer(contextView.stage));
         _injector.mapValue(SimpleInput,new SimpleInput(_loc1_.defaultDispatcher));
         _injector.mapValue(SharedObject,SharedObject.getLocal("n_account","/"));
         CommandMappings.mapCommands(commandMap);
         mediatorMap.mapView(N,NMediator);
      }
   }
}

