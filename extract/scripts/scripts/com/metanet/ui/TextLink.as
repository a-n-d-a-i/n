package com.metanet.ui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class TextLink extends MovieClip
   {
      
      private var _label:TextField;
      
      public function TextLink()
      {
         super();
         buttonMode = true;
         useHandCursor = true;
         this._label = getChildByName("txtLabel") as TextField;
         addEventListener(MouseEvent.MOUSE_OVER,this.mouseOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.mouseOut);
      }
      
      public function destroy() : void
      {
         if(parent)
         {
            parent.removeChild(this);
            removeEventListener(MouseEvent.MOUSE_OVER,this.mouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT,this.mouseOut);
         }
         this._label = null;
      }
      
      private function mouseOver(param1:MouseEvent) : void
      {
         var _loc2_:TextFormat = this._label.getTextFormat();
         _loc2_.color = 10027008;
         this._label.setTextFormat(_loc2_);
      }
      
      private function mouseOut(param1:MouseEvent) : void
      {
         var _loc2_:TextFormat = this._label.getTextFormat();
         _loc2_.color = 0;
         this._label.setTextFormat(_loc2_);
      }
   }
}

