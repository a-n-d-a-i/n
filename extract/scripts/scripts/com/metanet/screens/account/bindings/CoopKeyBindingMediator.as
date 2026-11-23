package com.metanet.screens.account.bindings
{
   import com.metanet.global.SavedProperties;
   import com.metanet.ui.PlayerKeys;
   
   public class CoopKeyBindingMediator extends PlayerKeyBindingButtonMediator
   {
      
      [Inject(name="coop")]
      public var playerKeys:PlayerKeys;
      
      public function CoopKeyBindingMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         _playerKeys = this.playerKeys;
         _savedProperty = SavedProperties.KEY_CONFIG_COOP;
         super.onRegister();
      }
   }
}

