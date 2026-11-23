package com.metanet.screens.account
{
   import com.metanet.data.EpisodeData;
   import com.metanet.data.Options;
   import com.metanet.global.Flavours;
   import com.metanet.global.SavedProperties;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.net.SharedObject;
   import org.robotlegs.mvcs.Mediator;
   
   public class FlavourSelectionMediator extends Mediator
   {
      
      [Inject]
      public var view:FlavourSelection;
      
      [Inject]
      public var episodes:EpisodeData;
      
      [Inject]
      public var options:Options;
      
      [Inject]
      public var sharedObject:SharedObject;
      
      private var _topMargin:int;
      
      private var _leftMargin:int;
      
      private var _gap:int;
      
      private var _buttons:Array = [];
      
      private var _swatches:Array = [];
      
      private var _swatchSize:int = 18;
      
      private const BORDER_SIZE:int = 2;
      
      public function FlavourSelectionMediator()
      {
         super();
      }
      
      override public function onRegister() : void
      {
         this.calculateLayout();
         var _loc1_:int = this.episodes.numberOfSets / 10;
         var _loc2_:int = 7;
         this.createSwatch(0,0,0);
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_)
         {
            if(this.episodes.isRangeBeaten(_loc3_ * 10,_loc3_ * 10 + 9))
            {
               this.createSwatch((_loc3_ + 1) % _loc2_,(_loc3_ + 1) / _loc2_,_loc3_ + 1);
            }
            _loc3_++;
         }
      }
      
      private function calculateLayout() : void
      {
         var _loc1_:int = 7;
         var _loc2_:int = Math.ceil(this.episodes.numberOfSets / 10 / _loc1_);
         var _loc3_:SwatchButton = new SwatchButton();
         this._swatchSize = _loc3_.width;
         var _loc4_:Number = this.view.width - _loc1_ * this._swatchSize - 2;
         var _loc5_:Number = this.view.height - _loc2_ * this._swatchSize - 2;
         this._gap = Math.min(_loc4_ / (_loc1_ + 1),_loc5_ / (_loc2_ + 1));
         this._topMargin = (_loc5_ - (_loc2_ - 1) * this._gap) / 2;
         this._leftMargin = (_loc4_ - (_loc1_ - 1) * this._gap) / 2;
      }
      
      private function createSwatch(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:SwatchButton = new SwatchButton();
         var _loc5_:BitmapData = new BitmapData(this._swatchSize,this._swatchSize,false);
         var _loc6_:Bitmap = new Bitmap(_loc5_);
         _loc4_.addChild(_loc6_);
         _loc6_.x = -this._swatchSize / 2;
         _loc6_.y = -this._swatchSize / 2;
         this.view.addChild(_loc4_);
         _loc4_.x = param1 * (this._swatchSize + this._gap) + this._leftMargin + this._swatchSize / 2;
         _loc4_.y = param2 * (this._swatchSize + this._gap) + this._topMargin + this._swatchSize / 2;
         this._buttons[param3] = _loc4_;
         this._swatches[param3] = _loc5_;
         this.drawSwatch(param3);
         _loc4_.addEventListener(MouseEvent.CLICK,this.handleClickSwatch);
      }
      
      private function handleClickSwatch(param1:*) : void
      {
         var _loc2_:int = int(this._buttons.indexOf(param1.target));
         var _loc3_:int = this.options.ninjaFlavour;
         if(_loc2_ == _loc3_)
         {
            return;
         }
         this.options.ninjaFlavour = _loc2_;
         this.options.p1Colour = Flavours.getP1Flavour(_loc2_);
         this.options.p2Colour = Flavours.getP2Flavour(_loc2_);
         this.drawSwatch(_loc2_);
         this.drawSwatch(_loc3_);
         this.sharedObject.setProperty(SavedProperties.FLAVOUR,_loc2_);
         try
         {
            this.sharedObject.flush();
         }
         catch(e:Error)
         {
         }
      }
      
      private function drawSwatch(param1:int) : void
      {
         var _loc2_:uint = 0;
         if(param1 == this.options.ninjaFlavour)
         {
            _loc2_ = 16777215;
         }
         var _loc3_:BitmapData = this._swatches[param1];
         _loc3_.fillRect(new Rectangle(0,0,this._swatchSize,this._swatchSize),_loc2_);
         _loc3_.fillRect(new Rectangle(this.BORDER_SIZE,this.BORDER_SIZE,this._swatchSize - this.BORDER_SIZE * 2,this._swatchSize - this.BORDER_SIZE * 2),Flavours.getP1Flavour(param1));
      }
   }
}

