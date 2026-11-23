package com.metanet.ui
{
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class InputRelay
   {
      
      public var activeDispatcher:IEventDispatcher;
      
      private var _defaultDispatcher:IEventDispatcher;
      
      private var _keyStates:Array = [];
      
      public function InputRelay(param1:IEventDispatcher)
      {
         super();
         this._defaultDispatcher = new EventDispatcher();
         param1.addEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         param1.addEventListener(KeyboardEvent.KEY_UP,this.handleKeyUp);
         param1.addEventListener(MouseEvent.MOUSE_DOWN,this.handleAnyMouseEvent);
         param1.addEventListener(MouseEvent.MOUSE_UP,this.handleAnyMouseEvent);
         param1.addEventListener(MouseEvent.MOUSE_MOVE,this.handleAnyMouseEvent);
         this.reset();
      }
      
      public function reset() : void
      {
         this.activeDispatcher = this.defaultDispatcher;
      }
      
      private function handleKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.target is TextField)
         {
            return;
         }
         if(this._keyStates[param1.keyCode])
         {
            return;
         }
         this._keyStates[param1.keyCode] = true;
         this.activeDispatcher.dispatchEvent(param1);
      }
      
      private function handleKeyUp(param1:KeyboardEvent) : void
      {
         if(param1.target is TextField)
         {
            return;
         }
         this._keyStates[param1.keyCode] = false;
         this.activeDispatcher.dispatchEvent(param1);
      }
      
      private function handleAnyMouseEvent(param1:MouseEvent) : void
      {
         var _loc2_:FixedMouseEvent = new FixedMouseEvent(param1);
         this.activeDispatcher.dispatchEvent(_loc2_);
      }
      
      public function get defaultDispatcher() : IEventDispatcher
      {
         return this._defaultDispatcher;
      }
   }
}

import flash.events.Event;
import flash.events.MouseEvent;

class FixedMouseEvent extends MouseEvent
{
   
   private var _originalStageX:Number;
   
   private var _originalStageY:Number;
   
   private var _originalTarget:Object;
   
   public function FixedMouseEvent(param1:MouseEvent)
   {
      super(param1.type);
      this._originalTarget = param1.target;
      localX = param1.localX;
      localY = param1.localY;
      ctrlKey = param1.ctrlKey;
      altKey = param1.altKey;
      shiftKey = param1.shiftKey;
      this._originalStageX = param1.stageX;
      this._originalStageY = param1.stageY;
   }
   
   override public function get target() : Object
   {
      return this._originalTarget;
   }
   
   override public function get stageX() : Number
   {
      return this._originalStageX;
   }
   
   override public function get stageY() : Number
   {
      return this._originalStageY;
   }
   
   override public function clone() : Event
   {
      return new FixedMouseEvent(this);
   }
}
