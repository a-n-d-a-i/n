package com.metanet.screens.account.bindings
{
   import com.metanet.ui.PlayerKeys;
   
   public class SoloRightMediator extends SoloKeyBindingMediator
   {
      
      public function SoloRightMediator()
      {
         super();
         _keyName = "right";
         _action = PlayerKeys.RIGHT;
         _player = 0;
      }
   }
}

