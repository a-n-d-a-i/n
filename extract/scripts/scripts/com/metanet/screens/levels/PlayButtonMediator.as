package com.metanet.screens.levels
{
   import com.metanet.data.Options;
   import com.metanet.events.StartEvent;
   import flash.events.MouseEvent;
   import flash.utils.ByteArray;
   import org.robotlegs.mvcs.Mediator;
   
   public class PlayButtonMediator extends Mediator
   {
      
      [Inject]
      public var view:PlayButton;
      
      [Inject]
      public var options:Options;
      
      public function PlayButtonMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         addViewListener(MouseEvent.CLICK,this.handleClicked);
      }
      
      private function handleClicked(param1:MouseEvent) : void
      {
         var _loc2_:ByteArray = this.options.selectedLevel.data;
         var _loc3_:String = this.options.selectedLevel.id;
         var _loc4_:StartEvent = new StartEvent(StartEvent.START_LEVEL);
         _loc4_.levelID = _loc3_;
         _loc4_.levelData = _loc2_;
         dispatch(_loc4_);
      }
   }
}

