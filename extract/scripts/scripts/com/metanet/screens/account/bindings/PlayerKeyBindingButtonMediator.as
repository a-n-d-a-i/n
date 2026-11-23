package com.metanet.screens.account.bindings
{
   import com.metanet.ui.DynamicButton;
   import com.metanet.ui.KeyNames;
   import com.metanet.ui.PlayerKeys;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Mediator;
   
   public class PlayerKeyBindingButtonMediator extends Mediator
   {
      
      private static const SETTING_KEY:int = 0;
      
      private static const INACTIVE:int = 1;
      
      [Inject]
      public var keyNames:KeyNames;
      
      [Inject]
      public var so:SharedObject;
      
      [Inject]
      public var view:DynamicButton;
      
      protected var _keyName:String;
      
      protected var _action:int;
      
      protected var _keyCode:uint;
      
      protected var _player:int;
      
      protected var _playerKeys:PlayerKeys;
      
      protected var _savedProperty:String;
      
      private var _stage:IEventDispatcher;
      
      private var _mode:int = 1;
      
      public function PlayerKeyBindingButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClick);
         this._keyCode = this._playerKeys.getActionKeyForPlayer(this._action,this._player);
         this.view.text = this.keyNames.getName(this._keyCode);
         this._stage = this.view.stage;
         super.onRegister();
      }
      
      override public function onRemove() : void
      {
         if(this._mode == SETTING_KEY)
         {
            this.stopListeningForKey();
         }
         super.onRemove();
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
      
      protected function handleKeyDown(param1:KeyboardEvent) : void
      {
         this._keyCode = param1.keyCode;
         this.view.text = this.keyNames.getName(this._keyCode);
         this._playerKeys.bindActionKeyForPlayer(this._action,this._keyCode,this._player);
         this.so.setProperty(this._savedProperty,this._playerKeys.keyConfigString);
         this.stopListeningForKey();
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

