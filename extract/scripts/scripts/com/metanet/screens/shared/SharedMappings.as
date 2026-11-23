package com.metanet.screens.shared
{
   import org.robotlegs.core.IMediatorMap;
   
   public class SharedMappings
   {
      
      public function SharedMappings()
      {
         super();
      }
      
      public static function mapMediators(param1:IMediatorMap) : void
      {
         param1.mapView(ResumeButton,ResumeButtonMediator);
         param1.mapView(ReturnToMenuButton,ReturnToMenuButtonMediator);
         param1.mapView(DropInIndicator,DropInMediator);
         param1.mapView(LoginControls,LoginControlsMediator);
         param1.mapView(LoginButton,LoginButtonMediator);
         param1.mapView(LogoutButton,LogoutButtonMediator);
         param1.mapView(SignupButton,SignupButtonMediator);
         param1.mapView(UsernameDisplay,UsernameDisplayMediator);
         param1.mapView(ResetPassword,ResetPasswordMediator);
         param1.mapView(DynamicPrompt,DynamicDialogMediator);
      }
   }
}

