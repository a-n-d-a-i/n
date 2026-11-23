package com.metanet.ui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class BasicComboBox extends MovieClip
   {
      
      public var values:Array;
      
      public var selectedIndex:int = -1;
      
      private var _items:Array = [];
      
      private var _button:DynamicButton;
      
      private var _dropdown:Sprite;
      
      private var _labels:Array;
      
      public function BasicComboBox()
      {
         super();
         this._button = DynamicButton(getChildByName("button"));
         this._dropdown = new Sprite();
         addChild(this._dropdown);
         this._dropdown.y = this._button.height;
         this._dropdown.visible = false;
         this._button.addEventListener(MouseEvent.CLICK,this.handleClicked);
      }
      
      public function destroy() : void
      {
         this._button.removeEventListener(MouseEvent.CLICK,this.handleClicked);
         if(this._dropdown.visible)
         {
            this.close();
         }
      }
      
      private function handleClicked(param1:MouseEvent) : void
      {
         stage.addEventListener(MouseEvent.CLICK,this.handleClickedOutside);
         if(this._dropdown.visible)
         {
            this.close();
         }
         else
         {
            this.open();
         }
      }
      
      private function handleItemClicked(param1:MouseEvent) : void
      {
         this.close();
         param1.stopImmediatePropagation();
         var _loc2_:int = int(this._items.indexOf(param1.target));
         this.selectIndex(_loc2_);
      }
      
      private function handleClickedOutside(param1:MouseEvent) : void
      {
         if(param1.target == this._button)
         {
            return;
         }
         this.close();
      }
      
      private function close() : void
      {
         this._dropdown.visible = false;
         stage.removeEventListener(MouseEvent.CLICK,this.handleClickedOutside);
      }
      
      private function open() : void
      {
         this._dropdown.visible = true;
      }
      
      private function selectIndex(param1:int) : void
      {
         if(param1 == this.selectedIndex)
         {
            return;
         }
         this.selectedIndex = param1;
         this._button.text = this._labels[this.selectedIndex];
         dispatchEvent(new BasicComboBoxEvent(BasicComboBoxEvent.CHANGED));
      }
      
      public function get labels() : Array
      {
         return this._labels;
      }
      
      public function set labels(param1:Array) : void
      {
         var _loc2_:DropDownItem = null;
         this._labels = param1;
         var _loc3_:int = 0;
         while(_loc3_ < this._labels.length)
         {
            _loc2_ = new DropDownItem();
            _loc2_.text = this._labels[_loc3_];
            _loc2_.addEventListener(MouseEvent.CLICK,this.handleItemClicked);
            _loc2_.y = _loc2_.height * _loc3_;
            this._dropdown.addChild(_loc2_);
            this._items[_loc3_] = _loc2_;
            _loc3_++;
         }
      }
      
      public function get selectedValue() : String
      {
         if(this.selectedIndex == -1)
         {
            return null;
         }
         return this.values[this.selectedIndex];
      }
      
      public function set selectedValue(param1:String) : void
      {
         if(!this.values || this.values.indexOf(param1) == -1)
         {
            return;
         }
         this.selectIndex(this.values.indexOf(param1));
      }
   }
}

