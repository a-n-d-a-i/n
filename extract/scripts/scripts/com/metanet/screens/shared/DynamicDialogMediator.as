package com.metanet.screens.shared
{
   import com.metanet.events.ConfirmationEvent;
   import com.metanet.events.InitializeEvent;
   import com.metanet.events.MenuEvent;
   import com.metanet.events.NServerEvent;
   import com.metanet.events.ReplayEvent;
   import com.metanet.ui.InputRelay;
   import editor.EditorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.text.TextFieldAutoSize;
   import flash.ui.Keyboard;
   import org.robotlegs.mvcs.Mediator;
   import simpleFramework.SimpleInput;
   
   public class DynamicDialogMediator extends Mediator
   {
      
      [Inject]
      public var view:DynamicPrompt;
      
      [Inject]
      public var keyboardRelay:InputRelay;
      
      private var _dialogInput:SimpleInput;
      
      private var _dialogOnlyDispatcher:IEventDispatcher;
      
      private var _defaultWidth:Number;
      
      private var _simpleStates:Object = {};
      
      private var _simpleMessages:Object = {};
      
      private var _alreadyLoadedReplay:Boolean;
      
      private const SLIDE_OUT:String = "slideOut";
      
      private const SLIDE_IN:String = "slideIn";
      
      private const JUST_SHOW:String = "show";
      
      private const JUST_HIDE:String = "hide";
      
      private const SHOW_BRIEFLY:String = "showForAMoment";
      
      private var _replaysLoaded:int;
      
      private var _replaysWatched:int;
      
      private var _yesEvent:Event;
      
      private var _noEvent:Event;
      
      public function DynamicDialogMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         this.addSimpleMessage(NServerEvent.SIGNUP_COMPLETE,this.SHOW_BRIEFLY,"email sent");
         this.addSimpleMessage(NServerEvent.TOKEN_EXPIRED,this.JUST_SHOW,"reauthenticating");
         this.addSimpleMessage(MenuEvent.LOGIN,this.JUST_SHOW,"logging in...");
         addContextListener(NServerEvent.LOGIN_COMPLETE,this.handleLoginComplete);
         this.addSimpleMessage(NServerEvent.READY_TO_SYNC,this.JUST_SHOW,"synchronizing...");
         this.addSimpleMessage(NServerEvent.LOGOUT_COMPLETE,this.SHOW_BRIEFLY,"logged out");
         this.addSimpleMessage(NServerEvent.EPISODE_DATA_COMPLETE,this.SLIDE_OUT,"logged in!");
         this.addSimpleMessage(NServerEvent.EPISODE_DATA_FAILED,this.SLIDE_OUT,"cannot reach server");
         this.addSimpleMessage(EditorEvent.EVENT_SAVE,this.JUST_SHOW,"saving level...");
         this.addSimpleMessage(InitializeEvent.REUPLOAD_CACHED_LEVEL,this.JUST_SHOW,"saving cached level...");
         this.addSimpleMessage(NServerEvent.LEVEL_CREDENTIALS_OBTAINED,null,"uploading data...");
         this.addSimpleMessage(NServerEvent.LEVEL_CREDENTIALS_DENIED,this.SLIDE_OUT,"save failed. will retry later");
         addContextListener(NServerEvent.FAVOURITE_COMPLETE,this.handleFavouriteComplete);
         this.addSimpleMessage(NServerEvent.FAVOURITE_FAILED,this.SHOW_BRIEFLY,"failed to add favourite");
         this.addSimpleMessage(NServerEvent.LEVEL_UPLOAD_COMPLETE,this.SLIDE_OUT,"save successful!");
         this.addSimpleMessage(NServerEvent.LEVEL_UPLOAD_FAILED,this.SLIDE_OUT,"save failed. will retry later");
         this.addSimpleMessage(NServerEvent.FLAG_COMPLETE,this.SHOW_BRIEFLY,"flagged");
         addContextListener(ReplayEvent.WATCH,this.handleWatchReplay);
         addContextListener(NServerEvent.REPLAY_DATA_LOADED,this.handleReplayDataLoaded);
         this.addSimpleMessage(NServerEvent.REPLAY_DATA_FAILED,this.JUST_HIDE,"replay download failed");
         this.addSimpleMessage(MenuEvent.PUBLISH_LEVEL,this.JUST_SHOW,"publishing level");
         this.addSimpleMessage(NServerEvent.COMMIT_LEVEL_COMPLETE,this.SLIDE_OUT,"level published");
         this.addSimpleMessage(MenuEvent.DELETE_LEVEL,this.JUST_SHOW,"deleting level");
         this.addSimpleMessage(NServerEvent.DELETE_LEVEL_COMPLETE,this.SLIDE_OUT,"level deleted");
         this.addSimpleMessage(InitializeEvent.SHARED_OBJECT_FAILED,this.SLIDE_OUT,"WARNING! Flash Player storage settings prevent saving progress");
         addContextListener(ConfirmationEvent.CONFIRM_ACTION,this.handleConfirmAction);
         this.view.message.field.autoSize = TextFieldAutoSize.CENTER;
         this._defaultWidth = this.view.message.bg.width;
         this._dialogOnlyDispatcher = new EventDispatcher();
      }
      
      private function handleLoginComplete(param1:NServerEvent) : void
      {
         var _loc2_:XML = new XML(param1.data);
         if(!_loc2_.success.length() > 0)
         {
            this.view.gotoAndPlay(this.SLIDE_OUT);
            this.showMessage("login failed");
         }
         else
         {
            this.showMessage("synchronizing...");
         }
      }
      
      private function handleReplayDataLoaded(param1:NServerEvent) : void
      {
         ++this._replaysLoaded;
         this.view.gotoAndPlay(this.JUST_HIDE);
      }
      
      private function handleWatchReplay(param1:ReplayEvent) : void
      {
         if(this._replaysLoaded >= this._replaysWatched)
         {
            ++this._replaysWatched;
            return;
         }
         ++this._replaysWatched;
         this.view.gotoAndPlay(this.JUST_SHOW);
         this.showMessage("downloading replay...");
      }
      
      private function handleFavouriteComplete(param1:NServerEvent) : void
      {
         var _loc2_:XML = new XML(param1.data);
         this.view.gotoAndPlay("showForAMoment");
         if(String(_loc2_..success.text()[0]) == "MAXIMUM REACHED")
         {
            this.showMessage("maximum favourites (50)");
         }
         else
         {
            this.showMessage("added to favourites");
         }
      }
      
      private function addSimpleMessage(param1:String, param2:String, param3:String) : void
      {
         addContextListener(param1,this.handleSimpleCase);
         this._simpleStates[param1] = param2;
         this._simpleMessages[param1] = param3;
      }
      
      private function handleSimpleCase(param1:Event) : void
      {
         if(this._simpleStates[param1.type])
         {
            this.showState(this._simpleStates[param1.type]);
         }
         this.showMessage(this._simpleMessages[param1.type]);
      }
      
      private function handleConfirmAction(param1:ConfirmationEvent) : void
      {
         contextView.mouseChildren = false;
         this.keyboardRelay.activeDispatcher = this._dialogOnlyDispatcher;
         this._dialogInput = new SimpleInput(this._dialogOnlyDispatcher);
         this.showState(this.SLIDE_IN);
         this.showMessage(param1.message);
         this._yesEvent = param1.yesEvent;
         this._noEvent = param1.noEvent;
         addViewListener(Event.ENTER_FRAME,this.checkForPlayerChoice);
      }
      
      private function checkForPlayerChoice(param1:Event) : void
      {
         this._dialogInput.Tick();
         if(this._dialogInput.IsKeyPressed(Keyboard.Y))
         {
            this.makeDecision(this._yesEvent);
         }
         else if(this._dialogInput.IsKeyPressed(Keyboard.N))
         {
            this.makeDecision(this._noEvent);
         }
      }
      
      private function makeDecision(param1:Event) : void
      {
         contextView.mouseChildren = true;
         removeViewListener(Event.ENTER_FRAME,this.checkForPlayerChoice);
         this.keyboardRelay.reset();
         this._dialogInput = null;
         this._yesEvent = null;
         this._noEvent = null;
         if(param1)
         {
            dispatch(param1);
         }
         else
         {
            this.showState(this.JUST_HIDE);
         }
      }
      
      private function showMessage(param1:String) : void
      {
         this.view.message.field.text = param1;
         this.resizeField();
      }
      
      private function showState(param1:String) : void
      {
         this.view.gotoAndPlay(param1);
         this.resizeField();
      }
      
      private function resizeField() : void
      {
         this.view.message.bg.width = this.view.message.field.width + 10;
         if(this.view.message.bg.width < this._defaultWidth)
         {
            this.view.message.bg.width = this._defaultWidth;
         }
      }
   }
}

