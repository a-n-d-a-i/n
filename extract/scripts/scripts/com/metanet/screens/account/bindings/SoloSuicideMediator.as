package com.metanet.screens.account.bindings
{
   import com.metanet.ui.PlayerKeys;
   
   public class SoloSuicideMediator extends SoloKeyBindingMediator
   {
      
      public function SoloSuicideMediator()
      {
         super();
         _keyName = "suicide";
         _action = PlayerKeys.SUICIDE;
         _player = 0;
      }
   }
}

