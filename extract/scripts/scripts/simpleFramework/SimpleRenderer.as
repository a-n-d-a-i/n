package simpleFramework
{
   import flash.display.*;
   import flash.geom.*;
   import flash.text.TextField;
   import math.vec2;
   
   public class SimpleRenderer extends Sprite
   {
      
      private var localroot:Stage;
      
      private var gbuffer:Shape;
      
      private var txtbox:TextField;
      
      private var size:uint = 80;
      
      private var borderColor:uint = 0;
      
      private var borderSize:uint = 0;
      
      private var cornerRadius:uint = 9;
      
      private var gutter:uint = 5;
      
      private var alph:Number = 1;
      
      private var textboxes:Vector.<TextField>;
      
      public function SimpleRenderer(param1:Stage)
      {
         super();
         this.localroot = param1;
         this.Init();
      }
      
      private function Init() : void
      {
         this.gbuffer = new Shape();
         this.localroot.addChild(this.gbuffer);
         this.txtbox = new TextField();
         this.txtbox.text = "";
         this.txtbox.x = 2;
         this.txtbox.y = 2;
         this.txtbox.width = 800;
         this.txtbox.selectable = false;
         this.txtbox.mouseEnabled = false;
         this.localroot.addChild(this.txtbox);
         this.txtbox.visible = false;
         this.textboxes = new Vector.<TextField>();
      }
      
      public function GetBuffer() : Shape
      {
         return this.gbuffer;
      }
      
      public function TranslateBuffer(param1:Number, param2:Number) : void
      {
         this.gbuffer.x += param1;
         this.gbuffer.y += param2;
      }
      
      public function SetBufferPos(param1:Number, param2:Number) : void
      {
         this.gbuffer.x = param1;
         this.gbuffer.y = param2;
      }
      
      public function GetBufferPos() : vec2
      {
         return new vec2(this.gbuffer.x,this.gbuffer.y);
      }
      
      public function ScaleBuffer(param1:Number) : void
      {
         this.gbuffer.scaleX *= param1;
         this.gbuffer.scaleY *= param1;
      }
      
      public function SetBufferScale(param1:Number) : void
      {
         this.gbuffer.scaleX = param1;
         this.gbuffer.scaleY = param1;
      }
      
      public function GetBufferScale() : vec2
      {
         return new vec2(this.gbuffer.scaleX,this.gbuffer.scaleY);
      }
      
      public function SetStyle(param1:Number, param2:Number, param3:Number) : void
      {
         this.borderColor = param2;
         this.borderSize = param1;
         this.alph = param3 / 100;
         this.gbuffer.graphics.lineStyle(this.borderSize,this.borderColor,this.alph);
      }
      
      public function Clear() : void
      {
         this.gbuffer.graphics.clear();
         while(this.textboxes.length > 0)
         {
            this.localroot.removeChild(this.textboxes.pop());
         }
         this.txtbox.text = "";
         this.txtbox.visible = false;
      }
      
      public function DrawFrame(param1:Number, param2:Number, param3:Number, param4:Number = 2) : void
      {
         var _loc5_:Object = new Object();
         _loc5_.a = Math.cos(param3);
         _loc5_.c = Math.sin(param3);
         _loc5_.b = -_loc5_.c;
         _loc5_.d = _loc5_.a;
         var _loc6_:Object = new Object();
         _loc6_.x = param4 * _loc5_.a + 0 * _loc5_.b;
         _loc6_.y = param4 * _loc5_.c + 0 * _loc5_.d;
         this.gbuffer.graphics.moveTo(param1,param2);
         this.gbuffer.graphics.lineTo(param1 + _loc6_.x,param2 + _loc6_.y);
         this.gbuffer.graphics.moveTo(param1,param2);
         this.gbuffer.graphics.lineTo(param1 - _loc6_.y,param2 + _loc6_.x);
      }
      
      public function DrawSquare(param1:Number, param2:Number, param3:Number = 2) : void
      {
         this.DrawAABB(param1 - param3,param1 + param3,param2 - param3,param2 + param3);
      }
      
      public function DrawArrow(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         this.DrawLine(param1,param2,param3,param4);
         var _loc6_:Number = param1 - param3;
         var _loc7_:Number = param2 - param4;
         var _loc8_:Number = Math.sqrt(_loc6_ * _loc6_ + _loc7_ * _loc7_);
         if(_loc8_ != 0)
         {
            _loc6_ /= _loc8_;
            _loc7_ /= _loc8_;
            this.DrawLine(param3,param4,param3 + param5 * _loc6_ + param5 * _loc7_,param4 + param5 * _loc7_ - param5 * _loc6_);
         }
      }
      
      public function DrawPlus(param1:Number, param2:Number, param3:Number = 2) : void
      {
         this.gbuffer.graphics.moveTo(param1 - param3,param2);
         this.gbuffer.graphics.lineTo(param1 + param3,param2);
         this.gbuffer.graphics.moveTo(param1,param2 - param3);
         this.gbuffer.graphics.lineTo(param1,param2 + param3);
      }
      
      public function DrawCross(param1:Number, param2:Number, param3:Number = 2) : void
      {
         this.gbuffer.graphics.moveTo(param1 - param3,param2 - param3);
         this.gbuffer.graphics.lineTo(param1 + param3,param2 + param3);
         this.gbuffer.graphics.moveTo(param1 + param3,param2 - param3);
         this.gbuffer.graphics.lineTo(param1 - param3,param2 + param3);
      }
      
      public function DrawLine(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         this.gbuffer.graphics.moveTo(param1,param2);
         this.gbuffer.graphics.lineTo(param3,param4);
      }
      
      public function DrawLine_Gradient(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : void
      {
         var _loc7_:Matrix = new Matrix();
         _loc7_.createGradientBox(param3 - param1,param4 - param2,Math.atan2(param4 - param2,param3 - param1),param1,param2);
         this.gbuffer.graphics.lineGradientStyle(GradientType.LINEAR,[param5,param6],[1,1],[100,155],_loc7_);
         this.gbuffer.graphics.moveTo(param1,param2);
         this.gbuffer.graphics.lineTo(param3,param4);
         this.gbuffer.graphics.lineStyle(this.borderSize,this.borderColor,this.alph);
      }
      
      public function DrawCircle(param1:Number, param2:Number, param3:Number) : void
      {
         this.gbuffer.graphics.drawCircle(param1,param2,param3);
      }
      
      public function DrawBox(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : void
      {
         this.gbuffer.graphics.moveTo(param1 + param3 + param5,param2 + param4 + param6);
         this.gbuffer.graphics.lineTo(param1 + param3 - param5,param2 + param4 - param6);
         this.gbuffer.graphics.lineTo(param1 - param3 - param5,param2 - param4 - param6);
         this.gbuffer.graphics.lineTo(param1 - param3 + param5,param2 - param4 + param6);
         this.gbuffer.graphics.lineTo(param1 + param3 + param5,param2 + param4 + param6);
      }
      
      public function DrawAABB(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         this.gbuffer.graphics.moveTo(param1,param3);
         this.gbuffer.graphics.lineTo(param1,param4);
         this.gbuffer.graphics.lineTo(param2,param4);
         this.gbuffer.graphics.lineTo(param2,param3);
         this.gbuffer.graphics.lineTo(param1,param3);
      }
      
      public function DrawRectangle(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         this.gbuffer.graphics.drawRect(param1,param2,param3,param4);
      }
      
      public function DrawRoundRectangle(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : void
      {
         this.gbuffer.graphics.drawRoundRect(param1,param2,param3,param4,param5,param6);
      }
      
      public function DrawCircularArc(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number) : void
      {
         var _loc8_:Number = -1;
         var _loc9_:Number = param3;
         var _loc10_:Number = param4;
         var _loc11_:Number = param5;
         var _loc12_:Number = param6;
         var _loc13_:Number = param7;
         if(param7 < 0)
         {
            _loc9_ = param5;
            _loc10_ = param6;
            _loc11_ = param3;
            _loc12_ = param4;
            _loc13_ = -param7;
         }
         var _loc14_:Number = Math.atan2(_loc10_ - param2,_loc9_ - param1);
         var _loc15_:Number = Math.atan2(_loc12_ - param2,_loc11_ - param1);
         var _loc16_:Number = Math.abs(_loc15_ - _loc14_);
         if(Math.PI < _loc16_)
         {
            _loc16_ = 2 * Math.PI - _loc16_;
         }
         var _loc17_:Number = Math.floor(_loc16_ / (Math.PI / 4)) + 1;
         var _loc18_:Number = _loc8_ * _loc16_ / (2 * _loc17_);
         var _loc19_:Number = _loc13_ / Math.cos(_loc18_);
         this.gbuffer.graphics.moveTo(param1 + Math.cos(_loc14_) * _loc13_,param2 + Math.sin(_loc14_) * _loc13_);
         var _loc20_:Number = 0;
         while(_loc20_ < _loc17_)
         {
            _loc15_ = _loc14_ + _loc18_;
            _loc14_ = _loc15_ + _loc18_;
            this.gbuffer.graphics.curveTo(param1 + Math.cos(_loc15_) * _loc19_,param2 + Math.sin(_loc15_) * _loc19_,param1 + Math.cos(_loc14_) * _loc13_,param2 + Math.sin(_loc14_) * _loc13_);
            _loc20_++;
         }
      }
      
      public function DrawCircularArc_Convex(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number) : void
      {
         var _loc8_:Number = (param4 - param2) * (param5 - param1) - (param3 - param1) * (param6 - param2);
         if(_loc8_ <= 0)
         {
            this.DrawCircularArc(param1,param2,param3,param4,param5,param6,-param7);
         }
         else
         {
            this.DrawCircularArc(param1,param2,param3,param4,param5,param6,param7);
         }
      }
      
      public function DrawString(param1:String) : void
      {
         this.txtbox.text = param1;
         this.txtbox.visible = true;
      }
      
      public function DrawStringAtPosition(param1:String, param2:Number, param3:Number) : void
      {
         var _loc4_:TextField = new TextField();
         _loc4_.selectable = false;
         _loc4_.width = 800;
         _loc4_.text = param1;
         _loc4_.x = param2;
         _loc4_.y = param3;
         _loc4_.mouseEnabled = false;
         this.localroot.addChild(_loc4_);
         this.textboxes.push(_loc4_);
      }
   }
}

