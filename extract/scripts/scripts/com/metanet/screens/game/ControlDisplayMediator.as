package com.metanet.screens.game
{
   import com.metanet.ui.GlobalKeys;
   import com.metanet.ui.InputRelay;
   import com.metanet.ui.KeyNames;
   import com.metanet.ui.PlayerKeys;
   import flash.events.KeyboardEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class ControlDisplayMediator extends Mediator
   {
      
      [Inject]
      public var view:ControlDisplay;
      
      [Inject]
      public var inputRelay:InputRelay;
      
      [Inject]
      public var globalKeys:GlobalKeys;
      
      [Inject(name="solo")]
      public var soloKeys:PlayerKeys;
      
      private var _keyNames:KeyNames;
      
      public function ControlDisplayMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         this._keyNames = new KeyNames();
         this.view.jump.text = this._keyNames.getName(this.soloKeys.getActionKeyForPlayer(PlayerKeys.JUMP,0));
         this.view.left.text = this._keyNames.getName(this.soloKeys.getActionKeyForPlayer(PlayerKeys.LEFT,0));
         this.view.right.text = this._keyNames.getName(this.soloKeys.getActionKeyForPlayer(PlayerKeys.RIGHT,0));
         this.view.suicide.text = this._keyNames.getName(this.soloKeys.getActionKeyForPlayer(PlayerKeys.SUICIDE,0));
         this.view.exit.text = this._keyNames.getName(this.globalKeys.quit);
         this.inputRelay.defaultDispatcher.addEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
      }
      
      override public function onRemove() : void
      {
         this.inputRelay.defaultDispatcher.removeEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
      }
      
      private function handleKeyDown(param1:KeyboardEvent) : void
      {
         this.view.parent.removeChild(this.view);
      }
   }
}

