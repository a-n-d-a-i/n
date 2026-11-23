package com.metanet.ui
{
   import flash.ui.Keyboard;
   
   public class KeyNames
   {
      
      private var _keyNames:Array = [];
      
      public function KeyNames()
      {
         super();
         this.mapLetters();
      }
      
      public function getName(param1:uint) : String
      {
         return this._keyNames[param1];
      }
      
      private function mapLetters() : void
      {
         this.mapLettersFromCharCodeInRange(48,90);
         this.mapLettersFromCharCodeInRange(96,111,-48,"Num ");
         this.mapLettersFromCharCodeInRange(219,222);
         this._keyNames[188] = "<";
         this._keyNames[190] = ">";
         this._keyNames[Keyboard.SPACE] = "space";
         this._keyNames[Keyboard.LEFT] = "left";
         this._keyNames[Keyboard.RIGHT] = "right";
         this._keyNames[Keyboard.UP] = "up";
         this._keyNames[Keyboard.DOWN] = "down";
         this._keyNames[Keyboard.SHIFT] = "shift";
         this._keyNames[Keyboard.ESCAPE] = "escape";
         this._keyNames[Keyboard.CONTROL] = "control";
         this._keyNames[Keyboard.BACKSPACE] = "backspace";
         this._keyNames[Keyboard.DELETE] = "delete";
         this._keyNames[Keyboard.BACKQUOTE] = "`";
         this._keyNames[Keyboard.BACKSLASH] = "\\";
         this._keyNames[Keyboard.COMMA] = ",";
         this._keyNames[Keyboard.PERIOD] = ".";
         this._keyNames[Keyboard.SLASH] = "/";
         this._keyNames[Keyboard.SEMICOLON] = ";";
         this._keyNames[Keyboard.QUOTE] = "\'";
         this._keyNames[Keyboard.ENTER] = "enter";
         this._keyNames[Keyboard.MINUS] = "-";
         this._keyNames[Keyboard.EQUAL] = "=";
         this._keyNames[Keyboard.HOME] = "home";
         this._keyNames[Keyboard.END] = "end";
         this._keyNames[Keyboard.PAGE_DOWN] = "pgdn";
         this._keyNames[Keyboard.PAGE_UP] = "pgup";
         this._keyNames[Keyboard.LEFTBRACKET] = "[";
         this._keyNames[Keyboard.RIGHTBRACKET] = "]";
      }
      
      private function mapLettersFromCharCodeInRange(param1:int, param2:int, param3:int = 0, param4:String = "") : void
      {
         var _loc5_:int = param1;
         while(_loc5_ <= param2)
         {
            this._keyNames[_loc5_] = param4 + String.fromCharCode(_loc5_ + param3).toLowerCase();
            _loc5_++;
         }
      }
      
      public function overrideKeyName(param1:uint, param2:String) : void
      {
         this._keyNames[param1] = param2;
      }
   }
}

