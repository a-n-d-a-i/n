package com.metanet.screens.account.bindings
{
   import com.metanet.ui.PlayerKeys;
   
   public class P1RightMediator extends CoopKeyBindingMediator
   {
      
      public function P1RightMediator()
      {
         super();
         _keyName = "right";
         _action = PlayerKeys.RIGHT;
         _player = 0;
      }
   }
}

