package com.metanet.screens.levels.metanet
{
   import com.metanet.data.Level;
   import com.metanet.data.Options;
   import com.metanet.events.NServerEvent;
   import com.metanet.events.SearchEvent;
   import com.metanet.global.RootURLS;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class MetanetLevelDisplayMediator extends Mediator
   {
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var view:MetanetLevelDisplay;
      
      private var _level:Level;
      
      public function MetanetLevelDisplayMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addContextListener(SearchEvent.SELECT_LEVEL,this.handleSelectLevel);
         addContextListener(NServerEvent.HIGHSCORES_LOADED,this.handleScoresLoaded);
         this.view.favourite.addEventListener(MouseEvent.CLICK,this.handleClickFavourite);
         this.view.unfavourite.addEventListener(MouseEvent.CLICK,this.handleClickUnfavourite);
         this.view.favourite.visible = false;
         this.view.unfavourite.visible = false;
      }
      
      private function handleClickFavourite(param1:MouseEvent) : void
      {
         this.view.favourite.visible = false;
         this.view.unfavourite.visible = true;
      }
      
      private function handleClickUnfavourite(param1:MouseEvent) : void
      {
         this.view.favourite.visible = false;
         this.view.unfavourite.visible = true;
      }
      
      private function handleSelectLevel(param1:SearchEvent) : void
      {
         this._level = this.options.selectedLevel;
         this.displayLevelDetails();
      }
      
      private function displayLevelDetails() : void
      {
         this.view.levelName.text = this._level.name;
         this.view.favourite.visible = !this._level.favourite;
         this.view.unfavourite.visible = this._level.favourite;
         this.view.autoLaunch.text = RootURLS.mainLocation + "?l=" + this._level.id;
         this.view.autoLaunch.selectable = true;
      }
      
      private function handleScoresLoaded(param1:NServerEvent) : void
      {
         this.view.loadingHighscores.visible = false;
      }
   }
}

