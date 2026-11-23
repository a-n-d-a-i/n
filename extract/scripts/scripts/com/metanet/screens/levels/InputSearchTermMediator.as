package com.metanet.screens.levels
{
   import com.metanet.data.Options;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import org.robotlegs.mvcs.Mediator;
   
   public class InputSearchTermMediator extends Mediator
   {
      
      [Inject]
      public var view:InputSearchTerm;
      
      [Inject]
      public var search:Options;
      
      private var _pushChanges:Boolean;
      
      public function InputSearchTermMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         addViewListener(TextEvent.TEXT_INPUT,this.handleTextInput);
         addViewListener(Event.ENTER_FRAME,this.handleEnterFrame);
      }
      
      protected function handleTextInput(param1:TextEvent) : void
      {
         var _loc2_:TextField = TextField(param1.target);
         var _loc3_:String = _loc2_.text.substr(0,_loc2_.selectionBeginIndex);
         var _loc4_:String = _loc2_.text.substr(_loc2_.selectionEndIndex);
         this.search.enteredTerm = _loc3_ + param1.text + _loc4_;
      }
      
      private function handleKeyDown(param1:KeyboardEvent) : void
      {
         this._pushChanges = true;
      }
      
      private function handleEnterFrame(param1:Event) : void
      {
         if(this.view.field.text != this.search.enteredTerm)
         {
            if(this._pushChanges)
            {
               this.search.enteredTerm = this.view.field.text;
            }
            else
            {
               this.view.field.text = this.search.enteredTerm;
            }
         }
         this._pushChanges = false;
      }
   }
}

