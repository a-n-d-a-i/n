package com.metanet.screens.levels
{
   import com.metanet.data.Level;
   import com.metanet.data.Options;
   import com.metanet.data.Search;
   import com.metanet.events.SearchEvent;
   import editor.EditorEvent;
   import editor.Editor_State;
   import editor.ThumbnailGenerator;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.ByteArray;
   import org.robotlegs.mvcs.Mediator;
   
   public class LevelDisplayMediator extends Mediator
   {
      
      [Inject]
      public var view:UserLevelDisplay;
      
      [Inject]
      public var search:Search;
      
      [Inject]
      public var options:Options;
      
      private var _selected:Boolean = false;
      
      private var _index:int;
      
      private var _thumbnail:Sprite;
      
      private var _level:Level;
      
      public function LevelDisplayMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
         addContextListener(SearchEvent.SEARCH_RESULTS_UPDATED,this.handleSearchResultsUpdated);
         addContextListener(EditorEvent.EVENT_SAVE,this.handleSave);
         this._index = this.view.parent.getChildIndex(this.view);
         this.view.mouseEnabled = true;
         this.view.mouseChildren = false;
         this.view.buttonMode = true;
         this.view.useHandCursor = true;
         this.view.loading.visible = false;
         this.view.dataNotFound.visible = false;
         this.view.gotoAndStop(1);
      }
      
      private function handleSearchResultsUpdated(param1:SearchEvent) : void
      {
         var _loc2_:UserLevelDisplay = null;
         this.view.loading.visible = true;
         this.view.mouseEnabled = false;
         this.view.dataNotFound.visible = false;
         this.view.alpha = 1;
         if(this.search.details.length <= this._index)
         {
            this.view.visible = false;
            return;
         }
         this._level = this.search.details[this._index];
         this.view.levelName.text = this._level.name;
         this.view.userName.text = this._level.creatorName;
         if(Boolean(this._thumbnail) && this._thumbnail.parent == this.view)
         {
            this.view.removeChild(this._thumbnail);
         }
         this.updateRating();
         this.updatePersonalBest();
         if(this._level.isMetanetLevel)
         {
            this.showMetanetFields();
         }
         else if(this._level.published)
         {
            this.showUserLevelFields();
         }
         else
         {
            this.showEditorFields();
         }
         this.view.visible = true;
         this.startWaitingForLevelData();
         this.view.gotoAndStop(1);
         this._selected = false;
      }
      
      private function handleSave(param1:EditorEvent) : void
      {
         if(this._selected)
         {
            this.view.levelName.text = this._level.name;
         }
      }
      
      private function startWaitingForLevelData() : void
      {
         addViewListener(Event.ENTER_FRAME,this.handleEnterFrame);
      }
      
      private function handleEnterFrame(param1:Event) : void
      {
         var in_event:Event = param1;
         if(this.search.levelsDownloaded <= this._index)
         {
            return;
         }
         this.view.loading.visible = false;
         this.view.mouseEnabled = true;
         try
         {
            this._thumbnail = this.thumbnailFromData(this._level.data);
            this._thumbnail.x = 4;
            this._thumbnail.y = 4;
            this.view.addChild(this._thumbnail);
         }
         catch(in_error:Error)
         {
            view.dataNotFound.visible = true;
            if(_level.published)
            {
               view.mouseEnabled = false;
               view.alpha = 0.5;
            }
            trace(in_error);
         }
         if(this.options.selectedLevel == this._level)
         {
            this.selectThisLevel();
         }
         removeViewListener(Event.ENTER_FRAME,this.handleEnterFrame);
      }
      
      private function updateRating() : void
      {
         if(this._level.meanRating == 0)
         {
            this.view.numericRating.text = "Unrated";
         }
         else
         {
            this.view.numericRating.text = "(" + String(this._level.meanRating) + ")";
         }
         var _loc1_:int = 1;
         while(_loc1_ <= 5)
         {
            if(Math.round(this._level.meanRating) >= _loc1_)
            {
               this.view.rating["rating_" + _loc1_].visible = true;
            }
            else
            {
               this.view.rating["rating_" + _loc1_].visible = false;
            }
            _loc1_++;
         }
      }
      
      private function updatePersonalBest() : void
      {
         if(this._level.personalBest != 0)
         {
            this.view.personalBest.text = "Personal best: " + this._level.personalBest;
         }
         else
         {
            this.view.personalBest.text = "You have not beaten this level";
         }
      }
      
      private function showUserLevelFields() : void
      {
         this.view.rating.visible = true;
         this.view.numericRating.visible = true;
         this.view.userName.visible = true;
         this.view.personalBest.visible = true;
      }
      
      private function showMetanetFields() : void
      {
         this.view.rating.visible = false;
         this.view.numericRating.visible = false;
         this.view.userName.visible = false;
         this.view.personalBest.visible = true;
      }
      
      private function showEditorFields() : void
      {
         this.view.rating.visible = false;
         this.view.numericRating.visible = false;
         this.view.userName.visible = false;
         this.view.personalBest.visible = false;
      }
      
      private function thumbnailFromData(param1:ByteArray) : Sprite
      {
         var _loc2_:ByteArray = null;
         var _loc3_:Editor_State = null;
         var _loc4_:Sprite = null;
         param1.position = 0;
         param1.readUTF();
         _loc2_ = new ByteArray();
         param1.readBytes(_loc2_);
         param1.position = 0;
         _loc3_ = Editor_State.Load_From_Bytes(_loc2_);
         _loc4_ = ThumbnailGenerator.Generate(_loc3_);
         _loc4_.scaleX = 0.125;
         _loc4_.scaleY = 0.125;
         return _loc4_;
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         if(this._selected)
         {
            return;
         }
         this.selectThisLevel();
      }
      
      private function selectThisLevel() : void
      {
         this.options.selectedLevelIndexInSearch = this._index;
         this.options.selectedLevel = this._level;
         this._selected = true;
         dispatch(new SearchEvent(SearchEvent.SELECT_LEVEL));
         addContextListener(SearchEvent.SELECT_LEVEL,this.handleSelectOtherLevel);
         this.view.gotoAndStop(2);
      }
      
      private function handleSelectOtherLevel(param1:SearchEvent) : void
      {
         removeContextListener(SearchEvent.SELECT_LEVEL,this.handleSelectOtherLevel);
         this._selected = false;
         this.view.gotoAndStop(1);
      }
   }
}

