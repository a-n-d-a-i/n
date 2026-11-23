package com.metanet.screens.editor
{
   import com.metanet.data.Level;
   import com.metanet.events.MenuEvent;
   import com.metanet.remote.AmazonServerConnector;
   import editor.Editor;
   import editor.EditorEvent;
   import editor.Editor_State;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import org.robotlegs.mvcs.Actor;
   import simpleFramework.SimpleInput;
   import simpleFramework.SimpleRenderer;
   
   public class EditorApp extends Actor
   {
      
      [Inject]
      public var input:SimpleInput;
      
      [Inject]
      public var debugRenderer:SimpleRenderer;
      
      [Inject]
      public var amazon:AmazonServerConnector;
      
      [Inject(name="gameStage")]
      public var gameStage:Sprite;
      
      [Inject(name="uiStage")]
      public var uiStage:Sprite;
      
      private var _editor:Editor;
      
      private var _level:Level;
      
      public function EditorApp()
      {
         super();
      }
      
      public function init() : void
      {
         this._editor = new Editor(this.input,this.debugRenderer,this.gameStage);
         this._editor.event_dispatcher.addEventListener(EditorEvent.EVENT_QUIT,this.handleQuit);
         this._editor.event_dispatcher.addEventListener(EditorEvent.EVENT_SAVE,this.handleSave);
         this.gameStage.addEventListener(Event.ENTER_FRAME,this.handleEnterFrame);
      }
      
      private function handleQuit(param1:Event) : void
      {
         this._editor.event_dispatcher.removeEventListener(EditorEvent.EVENT_QUIT,this.handleQuit);
         this._editor.event_dispatcher.removeEventListener(EditorEvent.EVENT_SAVE,this.handleSave);
         this.gameStage.removeEventListener(Event.ENTER_FRAME,this.handleEnterFrame);
         dispatch(new MenuEvent(MenuEvent.SHOW_USER_LEVELS));
      }
      
      private function handleSave(param1:EditorEvent) : void
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTF(this._level.name);
         _loc2_.writeBytes(param1.leveldata,0,param1.leveldata.length);
         this._level.data = _loc2_;
         this._level.name = param1.levelname;
         dispatch(new EditorEvent(EditorEvent.EVENT_SAVE));
         this._level.isNew = false;
      }
      
      public function newLevel(param1:Level) : void
      {
         this._level = param1;
         this._level.isNew = true;
         var _loc2_:ByteArray = Editor_State.Save_To_Bytes(new Editor_State());
         this._editor.APP_LoadLevel_Bytes(this._level.name,_loc2_);
      }
      
      public function loadLevel(param1:Level) : void
      {
         this._level = param1;
         var _loc2_:ByteArray = new ByteArray();
         this._level.data.readUTF();
         _loc2_.writeBytes(this._level.data,this._level.data.position,this._level.data.bytesAvailable);
         this._editor.APP_LoadLevel_Bytes(this._level.name,_loc2_);
      }
      
      private function handleEnterFrame(param1:Event) : void
      {
         this._editor.Tick();
      }
   }
}

