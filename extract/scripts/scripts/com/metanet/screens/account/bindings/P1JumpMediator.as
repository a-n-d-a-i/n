package com.metanet.screens.account.bindings
{
   import com.metanet.ui.PlayerKeys;
   
   public class P1JumpMediator extends CoopKeyBindingMediator
   {
      
      public function P1JumpMediator()
      {
         super();
         _keyName = "jump";
         _action = PlayerKeys.JUMP;
         _player = 0;
      }
   }
}

