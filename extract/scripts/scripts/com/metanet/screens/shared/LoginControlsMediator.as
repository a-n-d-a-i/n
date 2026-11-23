package com.metanet.screens.shared
{
   import com.goldengear.utils.GeneralUtils;
   import com.metanet.data.AccountDetails;
   import com.metanet.events.MenuEvent;
   import com.metanet.events.NServerEvent;
   import com.metanet.global.Strings;
   import flash.display.DisplayObject;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.ui.Keyboard;
   import org.robotlegs.mvcs.Mediator;
   
   public class LoginControlsMediator extends Mediator
   {
      
      [Inject]
      public var view:LoginControls;
      
      [Inject]
      public var account:AccountDetails;
      
      private var _activePane:DisplayObject;
      
      public function LoginControlsMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addContextListener(NServerEvent.LOGIN_COMPLETE,this.handleLoginComplete);
         addContextListener(NServerEvent.LOGOUT_COMPLETE,this.handleLogoutComplete);
         addContextListener(NServerEvent.SIGNUP_COMPLETE,this.handleSignupComplete);
         addContextListener(NServerEvent.RESET_COMPLETE,this.handleResetComplete);
         addContextListener(MenuEvent.ACCOUNT_ERROR,this.handleAccountError);
         addViewListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         this.view.login.signupButton.addEventListener(MouseEvent.CLICK,this.handleClickSwitchToSignup);
         this.view.login.resetButton.addEventListener(MouseEvent.CLICK,this.handleClickSwitchToReset);
         this.view.signup.backButton.addEventListener(MouseEvent.CLICK,this.handleClickBack);
         this.view.reset.backButton.addEventListener(MouseEvent.CLICK,this.handleClickBack);
         if(this.account.loggedInUserName != "")
         {
            this.showPane(this.view.logout);
         }
         else
         {
            this.showPane(this.view.login);
            this.view.stage.focus = this.view.login.enterName.field;
         }
      }
      
      override public function onRemove() : void
      {
         this.view.login.signupButton.removeEventListener(MouseEvent.CLICK,this.handleClickSwitchToSignup);
         this.view.login.resetButton.removeEventListener(MouseEvent.CLICK,this.handleClickSwitchToReset);
         this.view.signup.backButton.removeEventListener(MouseEvent.CLICK,this.handleClickBack);
         this.view.reset.backButton.removeEventListener(MouseEvent.CLICK,this.handleClickBack);
         GeneralUtils.smartDestroy(this.view);
         super.onRemove();
      }
      
      private function handleKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ENTER)
         {
            this.takeDefaultAction();
         }
      }
      
      private function handleLoginComplete(param1:NServerEvent) : void
      {
         var _loc2_:XML = new XML(param1.data);
         if(_loc2_.success.length() > 0)
         {
            this.view.statusField.text = Strings.loginSuccessful;
            this.showPane(this.view.logout);
            return;
         }
         this.view.statusField.text = _loc2_..error[0];
      }
      
      private function handleLogoutComplete(param1:NServerEvent) : void
      {
         this.showStatus("Logged out.");
         this.showPane(this.view.login);
      }
      
      private function handleSignupComplete(param1:NServerEvent) : void
      {
         var _loc2_:XML = new XML(param1.data);
         if(_loc2_.success.length() > 0)
         {
            this.showStatus("Signup was successful, please check your email.");
            this.showPane(this.view.login);
            return;
         }
         this.view.statusField.text = _loc2_..error[0];
      }
      
      private function handleResetComplete(param1:NServerEvent) : void
      {
         var _loc2_:XML = new XML(param1.data);
         if(_loc2_.success.length() > 0)
         {
            this.showStatus("Password reset email sent.");
            if(!this.account.loggedIn)
            {
               this.showPane(this.view.login);
            }
         }
      }
      
      private function handleAccountError(param1:MenuEvent) : void
      {
         this.view.statusField.text = this.account.error;
      }
      
      private function handleClickSwitchToSignup(param1:MouseEvent) : void
      {
         this.showPane(this.view.signup);
      }
      
      private function handleClickSwitchToReset(param1:MouseEvent) : void
      {
         this.showPane(this.view.reset);
      }
      
      private function handleClickBack(param1:MouseEvent) : void
      {
         this.showPane(this.view.login);
      }
      
      private function takeDefaultAction() : void
      {
         switch(this._activePane)
         {
            case this.view.login:
               dispatch(new MenuEvent(MenuEvent.LOGIN));
         }
      }
      
      private function showPane(param1:DisplayObject) : void
      {
         this.hideAll();
         param1.visible = true;
         this._activePane = param1;
      }
      
      private function clearStatus() : void
      {
         this.view.statusField.text = "";
      }
      
      private function showStatus(param1:String) : void
      {
         this.view.statusField.text = param1;
      }
      
      private function hideAll() : void
      {
         this.view.login.visible = false;
         this.view.logout.visible = false;
         this.view.signup.visible = false;
         this.view.reset.visible = false;
      }
   }
}

