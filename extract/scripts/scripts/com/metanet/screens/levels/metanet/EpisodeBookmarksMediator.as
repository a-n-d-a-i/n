package com.metanet.screens.levels.metanet
{
   import com.metanet.data.EpisodeData;
   import com.metanet.data.Search;
   import com.metanet.events.SearchEvent;
   import flash.events.MouseEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class EpisodeBookmarksMediator extends Mediator
   {
      
      [Inject]
      public var episodes:EpisodeData;
      
      [Inject]
      public var view:EpisodeBookmarks;
      
      [Inject]
      public var search:Search;
      
      private var _horizontalMargin:int;
      
      private var _verticalMargin:int;
      
      private var _buttons:Array = [];
      
      private var _columns:int = 6;
      
      private var _rows:int = 2;
      
      private var _hGap:int = 12;
      
      private var _vGap:int = 18;
      
      public function EpisodeBookmarksMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         this.calculateMargins();
         this.createButtonsForRegularEpisodes();
         if(this.episodes.isRangeBeaten(0,99))
         {
            this.createButtonsForSecretEpisodes();
         }
      }
      
      private function calculateMargins() : void
      {
         var _loc1_:EpisodeButton = new EpisodeButton();
         var _loc2_:int = _loc1_.width * this._columns;
         var _loc3_:int = this._hGap * (this._columns - 1);
         var _loc4_:int = _loc1_.height * this._rows;
         var _loc5_:int = this._vGap * (this._rows - 1);
         this._horizontalMargin = _loc1_.width / 2 + (this.view.width - _loc2_ - _loc3_) / 2;
         this._verticalMargin = _loc1_.height / 2 + (this.view.height - _loc4_ - _loc5_) / 2;
      }
      
      private function createButtonsForRegularEpisodes() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < 10)
         {
            this.createButtonForDecade(_loc1_);
            _loc1_++;
         }
      }
      
      private function createButtonsForSecretEpisodes() : void
      {
         this.createButtonForDecade(10);
         this.createButtonForDecade(11);
      }
      
      private function createButtonForDecade(param1:int) : void
      {
         var _loc2_:EpisodeButton = new EpisodeButton();
         var _loc3_:int = param1 % this._columns;
         var _loc4_:int = param1 / this._columns;
         if(param1 == 10)
         {
            _loc2_.text = "a0";
         }
         else if(param1 == 11)
         {
            _loc2_.text = "b0";
         }
         else
         {
            _loc2_.text = "0" + String(param1);
         }
         _loc2_.x = this._horizontalMargin + int((_loc2_.width + this._hGap) * _loc3_);
         _loc2_.y = this._verticalMargin + int((_loc2_.height + this._vGap) * _loc4_);
         _loc2_.addEventListener(MouseEvent.CLICK,this.handleButtonClicked);
         this.view.addChild(_loc2_);
         this._buttons[this._buttons.length] = _loc2_;
      }
      
      private function handleButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(this._buttons.indexOf(param1.target));
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(this.episodes.lastBeatenByColumn[_loc4_] != -1)
            {
               _loc2_ += (this.episodes.lastBeatenByColumn[_loc4_] + 1) * 5;
            }
            _loc4_++;
         }
         this.search.offset = _loc2_;
         dispatch(new SearchEvent(SearchEvent.INITIATE_SEARCH));
      }
   }
}

