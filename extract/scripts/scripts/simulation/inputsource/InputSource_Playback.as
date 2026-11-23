package simulation.inputsource
{
   import flash.utils.ByteArray;
   import simpleFramework.SimpleInput;
   
   public class InputSource_Playback extends InputSource_Base
   {
      
      private var input:SimpleInput;
      
      private var is_finished:Boolean;
      
      public function InputSource_Playback(param1:ByteArray)
      {
         super(param1);
         this.is_finished = false;
      }
      
      override public function IsReplayFinished() : Boolean
      {
         return this.is_finished;
      }
      
      override public function Tick(param1:uint) : void
      {
         var _loc2_:int = 0;
         if(param1 >= frames.length)
         {
            current_J = false;
            current_L = false;
            current_R = false;
            this.is_finished = true;
         }
         else
         {
            frames.position = param1;
            _loc2_ = frames.readByte();
            current_J = (_loc2_ & bit_J) > 0;
            current_L = (_loc2_ & bit_L) > 0;
            current_R = (_loc2_ & bit_R) > 0;
         }
      }
   }
}

