package simulation.inputsource
{
   import flash.utils.ByteArray;
   import simpleFramework.SimpleInput;
   
   public class InputSource_Recorder extends InputSource_Base
   {
      
      private var input:SimpleInput;
      
      private var keycode_J:uint;
      
      private var keycode_L:uint;
      
      private var keycode_R:uint;
      
      public function InputSource_Recorder(param1:SimpleInput, param2:uint, param3:uint, param4:uint)
      {
         this.input = param1;
         this.keycode_J = param2;
         this.keycode_L = param3;
         this.keycode_R = param4;
         var _loc5_:ByteArray = new ByteArray();
         _loc5_.length = 4096;
         super(_loc5_);
      }
      
      override public function Tick(param1:uint) : void
      {
         current_J = this.input.IsKeyDown(this.keycode_J);
         current_L = this.input.IsKeyDown(this.keycode_L);
         current_R = this.input.IsKeyDown(this.keycode_R);
         if(param1 >= frames.length)
         {
            frames.length = param1 * 2;
         }
         var _loc2_:* = 0;
         if(current_J)
         {
            _loc2_ |= bit_J;
         }
         if(current_L)
         {
            _loc2_ |= bit_L;
         }
         if(current_R)
         {
            _loc2_ |= bit_R;
         }
         frames.position = param1;
         frames.writeByte(_loc2_);
      }
   }
}

