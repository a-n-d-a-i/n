package com.metanet.ui
{
   import com.metanet.global.RootURLS;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.getTimer;
   
   public class NewsTicker extends MovieClip
   {
      
      public var background:MovieClip;
      
      public var container:MovieClip;
      
      private var _displayedObjects:Array = [];
      
      private var _displayedItemURLs:Array = [];
      
      private var _nextItem:int = 0;
      
      private var _numberOfItems:int;
      
      private var _loader:URLLoader;
      
      private var _data:XML;
      
      private var _items:XMLList;
      
      private const URL:String = RootURLS.newsRoot + "/news.xml";
      
      private const GAP:int = 40;
      
      private const SCROLL_SPEED:int = 1;
      
      public function NewsTicker()
      {
         super();
         var _loc1_:Date = new Date();
         this._loader = new URLLoader();
         this._loader.load(new URLRequest(this.URL + "?RND=" + getTimer() + _loc1_.time));
         this._loader.addEventListener(Event.COMPLETE,this.handleFeedLoaded);
         this._loader.addEventListener(IOErrorEvent.IO_ERROR,this.handleIOError);
      }
      
      private function handleFeedLoaded(param1:Event) : void
      {
         this._loader.removeEventListener(Event.COMPLETE,this.handleFeedLoaded);
         this._data = new XML(this._loader.data);
         this._items = this._data..item;
         this._numberOfItems = this._items.length();
         addEventListener(Event.ENTER_FRAME,this.handleEnterFrame);
      }
      
      private function handleIOError(param1:IOErrorEvent) : void
      {
         trace("Failed to load the news xml");
      }
      
      private function handleEnterFrame(param1:Event) : void
      {
         var _loc2_:int = int(this._displayedObjects.length - 1);
         while(_loc2_ >= 0)
         {
            this.scrollObject(this._displayedObjects[_loc2_]);
            _loc2_--;
         }
         if(this._displayedObjects.length == 0)
         {
            this.addItemToDisplay();
            return;
         }
         var _loc3_:DisplayObject = this._displayedObjects[this._displayedObjects.length - 1];
         if(_loc3_.x + _loc3_.width < this.background.width - this.GAP)
         {
            this.addItemToDisplay();
         }
      }
      
      private function scrollObject(param1:DisplayObject) : void
      {
         param1.x -= this.SCROLL_SPEED;
         if(param1.x + param1.width < 0)
         {
            this.removeOldestItem();
         }
      }
      
      private function addItemToDisplay() : void
      {
         this.createItem(this._nextItem);
         ++this._nextItem;
         if(this._nextItem >= this._numberOfItems)
         {
            this._nextItem = 0;
         }
      }
      
      private function createItem(param1:int) : void
      {
         var _loc2_:XML = this._items[param1];
         var _loc3_:MovieClip = new NewsTickerItem();
         var _loc4_:TextField = _loc3_.textfield;
         _loc4_.autoSize = TextFieldAutoSize.LEFT;
         _loc4_.text = _loc2_.description.text();
         _loc4_.selectable = false;
         var _loc5_:String = _loc2_.link.text();
         if(_loc5_.length != 0)
         {
            _loc3_.mouseEnabled = true;
            _loc3_.useHandCursor = true;
            _loc3_.mouseChildren = false;
            _loc3_.addEventListener(MouseEvent.CLICK,this.handleItemClick);
         }
         _loc3_.addChild(_loc4_);
         if(this._displayedObjects.length == 0)
         {
            _loc3_.x = this.background.width / 2;
         }
         else
         {
            _loc3_.x = this.background.width;
         }
         this.container.addChild(_loc3_);
         this._displayedObjects[this._displayedObjects.length] = _loc3_;
         this._displayedItemURLs[this._displayedItemURLs.length] = _loc5_;
      }
      
      private function removeOldestItem() : void
      {
         var _loc1_:DisplayObject = this._displayedObjects[0];
         this.container.removeChild(_loc1_);
         this._displayedObjects.shift();
         this._displayedItemURLs.shift();
         if(_loc1_.hasEventListener(MouseEvent.CLICK))
         {
            _loc1_.removeEventListener(MouseEvent.CLICK,this.handleItemClick);
         }
      }
      
      private function handleItemClick(param1:MouseEvent) : void
      {
         var _loc2_:int = int(this._displayedObjects.indexOf(param1.target));
         if(_loc2_ == -1)
         {
            return;
         }
         navigateToURL(new URLRequest(this._displayedItemURLs[_loc2_]));
      }
   }
}

