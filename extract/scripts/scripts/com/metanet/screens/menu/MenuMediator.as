package com.metanet.screens.menu
{
   import com.goldengear.utils.GeneralUtils;
   import com.metanet.data.AccountDetails;
   import com.metanet.events.NServerEvent;
   import com.metanet.ui.GlobalKeys;
   import com.metanet.ui.KeyboardNavigator;
   import flash.display.DisplayObject;
   import flash.events.KeyboardEvent;
   import org.robotlegs.mvcs.Mediator;
   
   public class MenuMediator extends Mediator
   {
      
      [Inject]
      public var view:MenuScreen;
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var keyMapping:GlobalKeys;
      
      private var _navigator:KeyboardNavigator;
      
      private var _stage:DisplayObject;
      
      public function MenuMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         if(this.account.loggedIn || !this.account.useDatabase)
         {
            this.view.loginPrompt.visible = false;
         }
         this.view.logo.web.visible = this.account.isWeb;
         this.view.kong_logo.visible = this.account.isWeb;
         this.mapKeyboardNavigation();
         addContextListener(NServerEvent.LOGIN_COMPLETE,this.handleLoginComplete);
         this._stage = this.view.stage;
         this._stage.addEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
      }
      
      override public function onRemove() : void
      {
         GeneralUtils.smartDestroy(this.view);
         this._navigator.clearNavigation();
         this._stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         this._stage = null;
         super.onRemove();
      }
      
      private function mapKeyboardNavigation() : void
      {
         var _loc1_:Array = [this.view.resume,this.view.episodes,this.view.userLevels,this.view.help,this.view.settings,this.view.credits,this.view.story];
         this._navigator = new KeyboardNavigator();
         this._navigator.useMapping(this.keyMapping);
         this._navigator.addEntryPoint(KeyboardNavigator.DOWN,_loc1_[0]);
         this._navigator.addEntryPoint(KeyboardNavigator.UP,_loc1_[_loc1_.length - 1]);
         this._navigator.addEntryPoint(KeyboardNavigator.LEFT,_loc1_[0]);
         this._navigator.addEntryPoint(KeyboardNavigator.RIGHT,_loc1_[_loc1_.length - 1]);
         this._navigator.addVerticalLoop(_loc1_);
         this._navigator.addHorizontalLoop(_loc1_);
      }
      
      private function handleLoginComplete(param1:NServerEvent) : void
      {
         var _loc2_:XML = new XML(param1.data);
         if(!_loc2_.success.length() > 0)
         {
            return;
         }
         this.view.loginPrompt.visible = false;
      }
      
      private function handleKeyDown(param1:KeyboardEvent) : void
      {
         this._navigator.navigate(param1.keyCode);
      }
   }
}

