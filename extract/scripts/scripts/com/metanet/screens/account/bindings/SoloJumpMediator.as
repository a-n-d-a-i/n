package com.metanet.screens.account.bindings
{
   import com.metanet.ui.PlayerKeys;
   
   public class SoloJumpMediator extends SoloKeyBindingMediator
   {
      
      public function SoloJumpMediator()
      {
         super();
         _keyName = "jump";
         _action = PlayerKeys.JUMP;
         _player = 0;
      }
   }
}

