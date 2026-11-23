package com.metanet.screens.levels
{
   import com.goldengear.utils.GeneralUtils;
   import com.metanet.data.AccountDetails;
   import com.metanet.data.Search;
   import com.metanet.events.SearchEvent;
   import com.metanet.global.SearchCriteria;
   import com.metanet.global.SearchSort;
   import com.metanet.ui.GlobalKeys;
   import com.metanet.ui.KeyboardNavigator;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class LevelsScreenMediator extends Mediator
   {
      
      [Inject]
      public var view:UserLevelsScreen;
      
      [Inject]
      public var search:Search;
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var keyMapping:GlobalKeys;
      
      private var _levelTileContainer:Sprite;
      
      private var _levelTiles:Vector.<UserLevelDisplay>;
      
      private var _navigator:KeyboardNavigator;
      
      private const COLUMNS:int = 2;
      
      private const ROWS:int = 5;
      
      private var _stage:Stage;
      
      public function LevelsScreenMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         this.createLevelDisplays();
         addContextListener(SearchEvent.INITIATE_SEARCH,this.handleSearchInitiated);
         addContextListener(SearchEvent.SEARCH_RESULTS_UPDATED,this.handleSearchResultsUpdated);
         addContextListener(SearchEvent.SELECT_LEVEL,this.handleSelectLevel);
         this.view.userLevelTab.addEventListener(MouseEvent.CLICK,this.handleClickUserTab);
         this.view.metanetTab.addEventListener(MouseEvent.CLICK,this.handleClickMetaTab);
         this.view.myLevelTab.addEventListener(MouseEvent.CLICK,this.handleClickMyLevelsTab);
         this.view.favouritesTab.addEventListener(MouseEvent.CLICK,this.handleClickFavouritesTab);
         this.view.searching.visible = false;
         this._stage = this.view.stage;
         this._stage.addEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         addViewListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         if(!this.account.loggedIn && this.account.useDatabase)
         {
            this.view.myLevelTab.visible = false;
            this.view.favouritesTab.visible = false;
         }
         if(this.search.levelsDownloaded == 0)
         {
            this.launchMetanetTab();
         }
         else
         {
            this.restorePreviousSearch();
         }
         this._navigator = new KeyboardNavigator();
         this._navigator.useMapping(this.keyMapping);
         this._navigator.setReturnButton(this.view.returnButton);
      }
      
      public function handleSearchInitiated(param1:SearchEvent) : void
      {
         this.clearDisplay();
         this.view.searching.visible = true;
      }
      
      public function handleSearchResultsUpdated(param1:SearchEvent) : void
      {
         this.view.searching.visible = false;
         if(this.search.details.length > 0 && this.search.levelsDownloaded < this.search.details.length)
         {
            dispatch(new SearchEvent(SearchEvent.LOAD_NEXT_LEVEL));
         }
      }
      
      private function handleSelectLevel(param1:SearchEvent) : void
      {
         this.showBottomPane();
      }
      
      private function handleKeyDown(param1:KeyboardEvent) : void
      {
         this._navigator.navigate(param1.keyCode);
      }
      
      private function handleClickUserTab(param1:MouseEvent) : void
      {
         this.search.offset = 0;
         this.search.mode = Search.USER_LEVELS;
         this.clearDisplay();
         this.selectTab(this.view.userLevelTab);
         this.showView(this.view.userLevels);
         this.search.clearTerms();
         this.search.addSearchTerms(SearchCriteria.MIN_RATING,[0]);
         this.search.sort = SearchSort.NEWEST;
         dispatch(new SearchEvent(SearchEvent.INITIATE_SEARCH));
      }
      
      private function handleClickMetaTab(param1:MouseEvent) : void
      {
         this.launchMetanetTab();
      }
      
      private function handleClickMyLevelsTab(param1:MouseEvent) : void
      {
         this.search.clearTerms();
         this.search.mode = Search.MY_LEVELS;
         this.search.rowCount = this.COLUMNS * this.ROWS;
         this.search.offset = 0;
         this.clearDisplay();
         this.selectTab(this.view.myLevelTab);
         this.showView(this.view.myLevels);
         dispatch(new SearchEvent(SearchEvent.INITIATE_SEARCH));
      }
      
      private function handleClickFavouritesTab(param1:MouseEvent) : void
      {
         this.search.clearTerms();
         this.search.mode = Search.FAVOURITES;
         this.search.rowCount = this.COLUMNS * this.ROWS;
         this.search.offset = 0;
         this.clearDisplay();
         this.selectTab(this.view.favouritesTab);
         this.showView(this.view.favourites);
         dispatch(new SearchEvent(SearchEvent.INITIATE_SEARCH));
      }
      
      private function launchMetanetTab() : void
      {
         this.search.mode = Search.METANET;
         this.search.rowCount = this.COLUMNS * this.ROWS;
         this.search.offset = 0;
         this.clearDisplay();
         this.selectTab(this.view.metanetTab);
         this.showView(this.view.metanet);
         dispatch(new SearchEvent(SearchEvent.INITIATE_SEARCH));
      }
      
      private function restorePreviousSearch() : void
      {
         this.clearDisplay();
         switch(this.search.mode)
         {
            case Search.FAVOURITES:
               this.selectTab(this.view.favouritesTab);
               this.showView(this.view.favourites);
               break;
            case Search.METANET:
               this.selectTab(this.view.metanetTab);
               this.showView(this.view.metanet);
               break;
            case Search.MY_LEVELS:
               this.selectTab(this.view.myLevelTab);
               this.showView(this.view.myLevels);
               break;
            case Search.USER_LEVELS:
               this.selectTab(this.view.userLevelTab);
               this.showView(this.view.userLevels);
         }
         dispatch(new SearchEvent(SearchEvent.SEARCH_RESULTS_UPDATED));
      }
      
      private function clearDisplay() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._levelTiles.length)
         {
            this._levelTiles[_loc1_].visible = false;
            _loc1_++;
         }
         this.hideBottomPane();
      }
      
      private function hideBottomPane() : void
      {
         this.view.userLevels.browsePane.visible = false;
         this.view.myLevels.editorPane.visible = false;
         this.view.metanet.metanetPane.visible = false;
         this.view.favourites.browsePane.visible = false;
      }
      
      private function showBottomPane() : void
      {
         this.view.userLevels.browsePane.visible = true;
         this.view.myLevels.editorPane.visible = true;
         this.view.metanet.metanetPane.visible = true;
         this.view.favourites.browsePane.visible = true;
      }
      
      private function selectTab(param1:*) : void
      {
         this.view.userLevelTab.selected = false;
         this.view.metanetTab.selected = false;
         this.view.myLevelTab.selected = false;
         this.view.favouritesTab.selected = false;
         this.view.userLevelTab.mouseEnabled = true;
         this.view.metanetTab.mouseEnabled = true;
         this.view.myLevelTab.mouseEnabled = true;
         this.view.favouritesTab.mouseEnabled = true;
         param1.selected = true;
         param1.mouseEnabled = false;
      }
      
      private function showView(param1:*) : void
      {
         this.view.metanet.visible = false;
         this.view.userLevels.visible = false;
         this.view.myLevels.visible = false;
         this.view.favourites.visible = false;
         param1.visible = true;
      }
      
      override public function onRemove() : void
      {
         if(this._stage)
         {
            this._stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         }
         this._stage = null;
         GeneralUtils.smartDestroy(this.view);
         super.onRemove();
      }
      
      private function createLevelDisplays() : void
      {
         var _loc1_:UserLevelDisplay = null;
         var _loc5_:int = 0;
         this._levelTileContainer = new Sprite();
         this.view.addChild(this._levelTileContainer);
         this._levelTileContainer.x = 55;
         this._levelTileContainer.y = 85;
         this._levelTiles = new Vector.<UserLevelDisplay>();
         var _loc2_:Number = 245;
         var _loc3_:Number = 86;
         var _loc4_:int = 0;
         while(_loc4_ < this.COLUMNS)
         {
            _loc5_ = 0;
            while(_loc5_ < this.ROWS)
            {
               _loc1_ = new UserLevelDisplay();
               _loc1_.visible = false;
               _loc1_.x = _loc4_ * _loc2_;
               _loc1_.y = _loc5_ * _loc3_;
               this._levelTileContainer.addChild(_loc1_);
               this._levelTiles[this._levelTiles.length] = _loc1_;
               _loc5_++;
            }
            _loc4_++;
         }
      }
   }
}

