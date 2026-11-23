package com.metanet.screens.account
{
   import com.metanet.data.Options;
   import com.metanet.global.SavedProperties;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.media.SoundMixer;
   import flash.media.SoundTransform;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Mediator;
   
   public class VolumeSliderMediator extends Mediator
   {
      
      [Inject]
      public var view:VolumeSlider;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var so:SharedObject;
      
      private var _stage:DisplayObject;
      
      private var _dragging:Boolean;
      
      public function VolumeSliderMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         this.view.slider.addEventListener(MouseEvent.MOUSE_DOWN,this.handleMouseDown);
         this._stage = this.view.stage;
         var _loc1_:Number = this.options.volume * this.view.bar.width;
         var _loc2_:int = 100 * this.options.volume;
         this.view.slider.x = _loc1_;
         this.view.slider.text = String(_loc2_);
      }
      
      override public function onRemove() : void
      {
         super.onRemove();
         this.view.slider.removeEventListener(MouseEvent.MOUSE_DOWN,this.handleMouseDown);
         if(this._dragging)
         {
            this.removeStageListeners();
         }
      }
      
      private function handleMouseDown(param1:MouseEvent) : void
      {
         this._stage.addEventListener(MouseEvent.MOUSE_MOVE,this.handleMouseMove);
         this._stage.addEventListener(MouseEvent.MOUSE_UP,this.handleMouseUp);
         this._dragging = true;
         this.moveSlider();
      }
      
      private function handleMouseMove(param1:MouseEvent) : void
      {
         this.moveSlider();
      }
      
      private function handleMouseUp(param1:MouseEvent) : void
      {
         this.removeStageListeners();
      }
      
      private function moveSlider() : void
      {
         var _loc1_:Number = Math.min(this.view.bar.width,Math.max(0,this.view.bar.mouseX));
         var _loc2_:Number = _loc1_ / this.view.bar.width;
         var _loc3_:int = 100 * _loc2_;
         this.view.slider.x = _loc1_;
         this.view.slider.text = String(_loc3_);
         this.options.volume = _loc2_;
         SoundMixer.soundTransform = new SoundTransform(_loc2_);
         this.so.setProperty(SavedProperties.VOLUME,_loc2_);
         try
         {
            this.so.flush();
         }
         catch(e:Error)
         {
         }
      }
      
      private function removeStageListeners() : void
      {
         this._stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.handleMouseMove);
         this._stage.removeEventListener(MouseEvent.MOUSE_UP,this.handleMouseUp);
         this._dragging = false;
      }
   }
}

