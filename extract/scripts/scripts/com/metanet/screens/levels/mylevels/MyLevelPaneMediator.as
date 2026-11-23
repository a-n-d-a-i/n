package com.metanet.screens.levels.mylevels
{
   import com.metanet.data.Level;
   import com.metanet.data.Options;
   import com.metanet.events.SearchEvent;
   import com.metanet.global.RootURLS;
   import flash.events.Event;
   import org.robotlegs.mvcs.Mediator;
   
   public class MyLevelPaneMediator extends Mediator
   {
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var view:SelectedEditorLevelPane;
      
      private var _level:Level;
      
      public function MyLevelPaneMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addContextListener(SearchEvent.SELECT_LEVEL,this.handleSelectLevel);
         addViewListener(Event.ENTER_FRAME,this.handleEnterFrame);
      }
      
      private function handleSelectLevel(param1:SearchEvent) : void
      {
         this._level = this.options.selectedLevel;
         this.view.levelName.text = this._level.name;
         this.view.autoLaunch.text = RootURLS.mainLocation + "?l=" + this._level.id;
         this.view.autoLaunch.selectable = true;
      }
      
      private function handleEnterFrame(param1:Event) : void
      {
         if(!this._level)
         {
            return;
         }
         this._level.name = this.view.levelName.text;
      }
   }
}

