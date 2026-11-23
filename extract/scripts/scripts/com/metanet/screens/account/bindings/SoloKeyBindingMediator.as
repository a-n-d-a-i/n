package com.metanet.screens.account.bindings
{
   import com.metanet.global.SavedProperties;
   import com.metanet.ui.PlayerKeys;
   
   public class SoloKeyBindingMediator extends PlayerKeyBindingButtonMediator
   {
      
      [Inject(name="solo")]
      public var playerKeys:PlayerKeys;
      
      public function SoloKeyBindingMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         _playerKeys = this.playerKeys;
         _savedProperty = SavedProperties.KEY_CONFIG_SOLO;
         super.onRegister();
      }
   }
}

