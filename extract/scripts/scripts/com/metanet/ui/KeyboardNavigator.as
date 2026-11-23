package com.metanet.ui
{
   import com.metanet.events.KeyboardFocusEvent;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class KeyboardNavigator
   {
      
      public static const UP:uint = 0;
      
      public static const LEFT:uint = 1;
      
      public static const RIGHT:uint = 2;
      
      public static const DOWN:uint = 4;
      
      private var _keymapping:GlobalKeys;
      
      private var _navigationMap:Dictionary;
      
      private var _currentFocus:DisplayObject;
      
      private var _directions:Array = [];
      
      private var _returnButton:DisplayObject;
      
      public function KeyboardNavigator()
      {
         super();
         this._navigationMap = new Dictionary();
      }
      
      public function useMapping(param1:GlobalKeys) : void
      {
         this._keymapping = param1;
         this._directions[UP] = param1.up;
         this._directions[LEFT] = param1.left;
         this._directions[RIGHT] = param1.right;
         this._directions[DOWN] = param1.down;
      }
      
      public function clearNavigation() : void
      {
         this._navigationMap = new Dictionary();
      }
      
      public function addEntryPoint(param1:uint, param2:DisplayObject) : void
      {
         this.addNavigationOption(param1,null,param2);
      }
      
      public function addHorizontalLoop(param1:Array) : void
      {
         var _loc2_:int = int(param1.length - 1);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            this.connectHorizontally(param1[_loc3_],param1[_loc3_ + 1]);
            _loc3_++;
         }
         this.connectHorizontally(param1[_loc2_],param1[0]);
      }
      
      public function addVerticalLoop(param1:Array) : void
      {
         var _loc2_:int = int(param1.length - 1);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            this.connectVertically(param1[_loc3_],param1[_loc3_ + 1]);
            _loc3_++;
         }
         this.connectVertically(param1[_loc2_],param1[0]);
      }
      
      public function connectHorizontally(param1:DisplayObject, param2:DisplayObject) : void
      {
         this.addNavigationOption(LEFT,param2,param1);
         this.addNavigationOption(RIGHT,param1,param2);
      }
      
      public function connectVertically(param1:DisplayObject, param2:DisplayObject) : void
      {
         this.addNavigationOption(DOWN,param1,param2);
         this.addNavigationOption(UP,param2,param1);
      }
      
      public function addNavigationOption(param1:uint, param2:DisplayObject, param3:DisplayObject) : void
      {
         if(!this._navigationMap[param2])
         {
            this._navigationMap[param2] = [];
         }
         this._navigationMap[param2][param1] = param3;
      }
      
      public function setReturnButton(param1:DisplayObject) : void
      {
         this._returnButton = param1;
      }
      
      public function navigate(param1:uint) : void
      {
         if(param1 == this._keymapping.select && Boolean(this._currentFocus))
         {
            this._currentFocus.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
            this._currentFocus.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
            this._currentFocus.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
            return;
         }
         if(param1 == this._keymapping.back && Boolean(this._returnButton))
         {
            this._returnButton.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
            this._returnButton.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
            this._returnButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
            return;
         }
         var _loc2_:int = int(this._directions.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         if(!this._navigationMap[this._currentFocus])
         {
            return;
         }
         var _loc3_:DisplayObject = this._navigationMap[this._currentFocus][_loc2_];
         if(!_loc3_)
         {
            return;
         }
         this.setFocus(_loc3_);
         if(!_loc3_.visible)
         {
            this.navigate(param1);
         }
      }
      
      public function setFocus(param1:DisplayObject) : void
      {
         if(this._currentFocus)
         {
            this._currentFocus.dispatchEvent(new KeyboardFocusEvent(KeyboardFocusEvent.FOCUS_OUT));
         }
         this._currentFocus = param1;
         if(this._currentFocus)
         {
            this._currentFocus.dispatchEvent(new KeyboardFocusEvent(KeyboardFocusEvent.FOCUS_IN));
         }
      }
   }
}

