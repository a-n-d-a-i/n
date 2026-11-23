package com.metanet.screens.account.bindings
{
   import com.metanet.ui.KeyNames;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Mediator;
   
   public class MenuKeyBindingMediator extends Mediator
   {
      
      private static const SETTING_KEY:int = 0;
      
      private static const INACTIVE:int = 1;
      
      [Inject]
      public var keyNames:KeyNames;
      
      [Inject]
      public var sharedObject:SharedObject;
      
      protected var _keySaveName:String;
      
      protected var _keyCode:uint;
      
      protected var _stage:IEventDispatcher;
      
      private var _mode:int = 1;
      
      public function MenuKeyBindingMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
         this.setLabel(this.keyNames.getName(this._keyCode));
      }
      
      protected function handleKeyDown(param1:KeyboardEvent) : void
      {
         this._keyCode = param1.keyCode;
         this.setLabel(this.keyNames.getName(this._keyCode));
         this.sharedObject.setProperty(this._keySaveName,param1.keyCode);
         this.stopListeningForKey();
      }
      
      protected function setLabel(param1:String) : void
      {
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         switch(this._mode)
         {
            case INACTIVE:
               this.startListeningForKey();
               break;
            case SETTING_KEY:
               this.stopListeningForKey();
         }
      }
      
      private function startListeningForKey() : void
      {
         this._mode = SETTING_KEY;
         this._stage.addEventListener(MouseEvent.MOUSE_DOWN,this.handleClick);
         this._stage.addEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
      }
      
      private function stopListeningForKey() : void
      {
         this._mode = INACTIVE;
         this._stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.handleClick);
         this._stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
      }
   }
}

