package com.metanet.ui
{
   import flash.text.TextField;
   
   public class DynamicButton extends BasicButton
   {
      
      private var _label:TextField;
      
      public function DynamicButton()
      {
         super();
         this._label = TextField(getChildByName("txtLabel"));
      }
      
      public function get text() : String
      {
         return this._label.text;
      }
      
      public function set text(param1:String) : void
      {
         if(param1 == null)
         {
            this._label.text = "";
            return;
         }
         this._label.text = param1;
      }
   }
}

