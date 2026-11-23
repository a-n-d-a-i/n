package com.metanet.ui
{
   import com.metanet.events.KeyboardFocusEvent;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class BasicButton extends MovieClip
   {
      
      private var _selected:Boolean;
      
      private var _mouseOver:Boolean;
      
      private var _mouseDown:Boolean;
      
      public function BasicButton()
      {
         super();
         mouseChildren = false;
         buttonMode = true;
         useHandCursor = true;
         this.updateVisualState();
         addEventListener(MouseEvent.MOUSE_OVER,this.handleMouseOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.handleMouseOut);
         addEventListener(MouseEvent.MOUSE_DOWN,this.handleMouseDown);
         addEventListener(MouseEvent.MOUSE_UP,this.handleMouseUp);
         addEventListener(KeyboardFocusEvent.FOCUS_IN,this.handleFocusIn);
         addEventListener(KeyboardFocusEvent.FOCUS_OUT,this.handleFocusOut);
      }
      
      public function destroy() : void
      {
         if(parent)
         {
            parent.removeChild(this);
            removeEventListener(MouseEvent.MOUSE_OVER,this.handleMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT,this.handleMouseOut);
            removeEventListener(MouseEvent.MOUSE_DOWN,this.handleMouseDown);
            removeEventListener(MouseEvent.MOUSE_UP,this.handleMouseUp);
            removeEventListener(KeyboardFocusEvent.FOCUS_IN,this.handleFocusIn);
            removeEventListener(KeyboardFocusEvent.FOCUS_OUT,this.handleFocusOut);
         }
      }
      
      private function handleMouseOver(param1:MouseEvent) : void
      {
         this._mouseOver = true;
         this.updateVisualState();
      }
      
      private function handleMouseOut(param1:MouseEvent) : void
      {
         this._mouseOver = false;
         this.updateVisualState();
      }
      
      private function handleMouseDown(param1:MouseEvent) : void
      {
         this._mouseDown = true;
         this.updateVisualState();
      }
      
      private function handleMouseUp(param1:MouseEvent) : void
      {
         this._mouseDown = false;
         this.updateVisualState();
      }
      
      private function handleFocusIn(param1:KeyboardFocusEvent) : void
      {
         this._selected = true;
         this.updateVisualState();
      }
      
      private function handleFocusOut(param1:KeyboardFocusEvent) : void
      {
         this._selected = false;
         this.updateVisualState();
      }
      
      private function updateVisualState() : void
      {
         if(this._mouseDown)
         {
            gotoAndStop(1);
         }
         if(this._mouseOver || this._selected)
         {
            gotoAndStop(2);
         }
         else
         {
            gotoAndStop(1);
         }
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
         this.updateVisualState();
      }
   }
}

