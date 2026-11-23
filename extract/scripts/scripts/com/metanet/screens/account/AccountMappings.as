package com.metanet.screens.account
{
   import com.metanet.screens.account.bindings.BindingMappings;
   import com.metanet.screens.shared.InputEmailMediator;
   import com.metanet.screens.shared.InputNameMediator;
   import com.metanet.screens.shared.InputPasswordMediator;
   import com.metanet.screens.shared.InputPasswordRetypeMediator;
   import org.robotlegs.core.IMediatorMap;
   
   public class AccountMappings
   {
      
      public function AccountMappings()
      {
         super();
      }
      
      public static function mapMediators(param1:IMediatorMap) : void
      {
         param1.mapView(AccountScreen,AccountMediator);
         param1.mapView(VolumeSlider,VolumeSliderMediator);
         param1.mapView(InputName,InputNameMediator);
         param1.mapView(InputPassword,InputPasswordMediator);
         param1.mapView(InputPasswordRetype,InputPasswordRetypeMediator);
         param1.mapView(InputEmail,InputEmailMediator);
         param1.mapView(ClearLocalDataButton,ClearLocalDataMediator);
         param1.mapView(FlavourSelection,FlavourSelectionMediator);
         BindingMappings.mapMediators(param1);
      }
   }
}

