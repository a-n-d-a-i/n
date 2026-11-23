package simpleFramework
{
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.ui.Keyboard;
   import math.vec2;
   
   public class SimpleInput
   {
      
      private var localroot:IEventDispatcher;
      
      private var xmouse:Number;
      
      private var ymouse:Number;
      
      private var mouseWasDown:Boolean;
      
      private var mouseIsDown:Boolean;
      
      private var stateDown:Boolean;
      
      private var statePressed:Boolean;
      
      private var stateReleased:Boolean;
      
      private var posx:Number;
      
      private var posy:Number;
      
      private var oldx:Number;
      
      private var oldy:Number;
      
      private var downposx:Number;
      
      private var downposy:Number;
      
      private var upposx:Number;
      
      private var upposy:Number;
      
      private var keys:Array;
      
      private var oldkeys:Array;
      
      private var keytriggers:Array;
      
      public function SimpleInput(param1:IEventDispatcher)
      {
         super();
         this.localroot = param1;
         this.localroot.addEventListener(MouseEvent.MOUSE_MOVE,this.PRIVATE_EVENT_MouseMoved);
         this.localroot.addEventListener(MouseEvent.MOUSE_DOWN,this.PRIVATE_EVENT_MouseDown);
         this.localroot.addEventListener(MouseEvent.MOUSE_UP,this.PRIVATE_EVENT_MouseUp);
         this.localroot.addEventListener(KeyboardEvent.KEY_DOWN,this.PRIVATE_EVENT_KeyDown);
         this.localroot.addEventListener(KeyboardEvent.KEY_UP,this.PRIVATE_EVENT_KeyUp);
         this.Init();
      }
      
      private function Init() : void
      {
         this.mouseIsDown = false;
         this.mouseWasDown = false;
         this.posx = 0;
         this.posy = 0;
         this.oldx = 0;
         this.oldy = 0;
         this.downposx = 0;
         this.downposy = 0;
         this.upposx = 0;
         this.upposy = 0;
         this.stateDown = false;
         this.statePressed = false;
         this.stateReleased = false;
         this.keys = new Array(256);
         this.oldkeys = new Array(256);
         this.keytriggers = new Array(256);
         this.Tick();
         this.Tick();
      }
      
      public function Tick() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         while(_loc1_ < this.keytriggers.length)
         {
            this.keytriggers[_loc1_] = 0;
            _loc1_++;
         }
         this.oldx = this.posx;
         this.oldy = this.posy;
         this.stateDown = false;
         this.statePressed = false;
         this.stateReleased = false;
         if(this.mouseIsDown)
         {
            this.stateDown = true;
            if(!this.mouseWasDown)
            {
               this.statePressed = true;
               this.downposx = this.xmouse;
               this.downposy = this.ymouse;
            }
         }
         else if(this.mouseWasDown)
         {
            this.stateReleased = true;
            this.upposx = this.xmouse;
            this.upposy = this.ymouse;
         }
         this.mouseWasDown = this.mouseIsDown;
         this.posx = this.xmouse;
         this.posy = this.ymouse;
         while(_loc2_ < this.keys.length)
         {
            if(this.IsKeyDown(_loc2_))
            {
               if(!this.oldkeys[_loc2_])
               {
                  this.keytriggers[_loc2_] = 1;
               }
            }
            else if(this.oldkeys[_loc2_])
            {
               this.keytriggers[_loc2_] = -1;
            }
            _loc2_++;
         }
         while(_loc3_ < this.oldkeys.length)
         {
            this.oldkeys[_loc3_] = this.keys[_loc3_];
            _loc3_++;
         }
      }
      
      public function GetMousePos() : vec2
      {
         return new vec2(this.xmouse,this.ymouse);
      }
      
      public function GetMousePos_Down() : vec2
      {
         return new vec2(this.downposx,this.downposy);
      }
      
      public function GetMousePos_Up() : vec2
      {
         return new vec2(this.upposx,this.upposy);
      }
      
      public function GetMouseVel() : vec2
      {
         return new vec2(this.posx - this.oldx,this.posy - this.oldy);
      }
      
      public function PRIVATE_EVENT_MouseMoved(param1:MouseEvent) : void
      {
         this.xmouse = param1.stageX;
         this.ymouse = param1.stageY;
      }
      
      public function PRIVATE_EVENT_MouseDown(param1:MouseEvent) : void
      {
         this.mouseIsDown = true;
      }
      
      public function PRIVATE_EVENT_MouseUp(param1:MouseEvent) : void
      {
         this.mouseIsDown = false;
      }
      
      public function IsMouseDown() : Boolean
      {
         return this.stateDown;
      }
      
      public function IsMousePressed() : Boolean
      {
         return this.statePressed;
      }
      
      public function IsMouseReleased() : Boolean
      {
         return this.stateReleased;
      }
      
      public function PRIVATE_EVENT_KeyDown(param1:KeyboardEvent) : void
      {
         this.keys[param1.keyCode] = true;
         this.keys[Keyboard.CONTROL] = param1.ctrlKey;
      }
      
      public function PRIVATE_EVENT_KeyUp(param1:KeyboardEvent) : void
      {
         this.keys[param1.keyCode] = false;
      }
      
      public function IsKeyDown(param1:uint) : Boolean
      {
         return this.keys[param1];
      }
      
      public function IsOnePressed(param1:Vector.<int>) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            if(this.keytriggers[param1[_loc2_]] > 0)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function IsKeyPressed(param1:uint) : Boolean
      {
         return this.keytriggers[param1] > 0;
      }
      
      public function IsKeyReleased(param1:uint) : Boolean
      {
         return this.keytriggers[param1] < 0;
      }
      
      public function IsAnyKeyPressed() : Boolean
      {
         return this.keytriggers.indexOf(1) != -1;
      }
      
      public function CapsLock() : Boolean
      {
         return Keyboard.capsLock;
      }
   }
}

