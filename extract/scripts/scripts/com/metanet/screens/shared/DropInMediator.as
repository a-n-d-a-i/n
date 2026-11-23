package com.metanet.screens.shared
{
   import com.metanet.data.Options;
   import com.metanet.ui.InputRelay;
   import com.metanet.ui.KeyNames;
   import com.metanet.ui.PlayerKeys;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   import org.robotlegs.mvcs.Mediator;
   
   public class DropInMediator extends Mediator
   {
      
      [Inject]
      public var view:DropInIndicator;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var keyboardRelay:InputRelay;
      
      [Inject(named="coop")]
      public var mapping:PlayerKeys;
      
      private var _stage:IEventDispatcher;
      
      private var _keyNames:KeyNames = new KeyNames();
      
      public function DropInMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         this.updateText();
         this.view.text.selectable = false;
         this._stage = this.view.stage;
         this.keyboardRelay.defaultDispatcher.addEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
      }
      
      override public function onRemove() : void
      {
         this.keyboardRelay.defaultDispatcher.removeEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         this._stage = null;
      }
      
      private function handleKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.target is TextField)
         {
            return;
         }
         if(param1.keyCode == this.mapping.getActionKeyForPlayer(PlayerKeys.JUMP,1))
         {
            this.toggle();
         }
      }
      
      private function toggle() : void
      {
         this.options.coopMode = !this.options.coopMode;
         this.updateText();
      }
      
      private function updateText() : void
      {
         if(this.options.coopMode)
         {
            this.view.text.text = this.textForCoopEnabled();
         }
         else
         {
            this.view.text.text = this.textForCoopDisabled();
         }
      }
      
      private function textForCoopEnabled() : String
      {
         var _loc1_:String = this._keyNames.getName(this.mapping.getActionKeyForPlayer(PlayerKeys.JUMP,1));
         return "2 Player Mode. High scores will not be recorded. Press \'" + _loc1_ + "\' to return to 1 Player Mode";
      }
      
      private function textForCoopDisabled() : String
      {
         var _loc1_:String = this._keyNames.getName(this.mapping.getActionKeyForPlayer(PlayerKeys.JUMP,1));
         return "1 Player Mode. Press \'" + _loc1_ + "\' to switch to 2 Player Mode";
      }
   }
}

