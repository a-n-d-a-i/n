package simulation.inputsource
{
   import flash.utils.ByteArray;
   import simulation.sim_globals;
   
   public class InputSource_Base
   {
      
      protected static const bit_J:int = 1;
      
      protected static const bit_L:int = 2;
      
      protected static const bit_R:int = 4;
      
      protected var frames:ByteArray;
      
      protected var current_J:Boolean;
      
      protected var current_L:Boolean;
      
      protected var current_R:Boolean;
      
      public function InputSource_Base(param1:ByteArray)
      {
         super();
         this.frames = param1;
         this.current_J = false;
         this.current_L = false;
         this.current_R = false;
      }
      
      public function DumpFrames() : ByteArray
      {
         this.frames.position = this.frames.length - 1;
         while(this.frames.position >= 0)
         {
            if(this.frames.readByte() != 0)
            {
               break;
            }
            this.frames.position -= 2;
         }
         var _loc1_:uint = this.frames.position;
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.position = 0;
         this.frames.position = 0;
         var _loc3_:int = 0;
         while(_loc3_ <= _loc1_)
         {
            _loc2_.writeByte(this.frames.readByte());
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function DumpString() : String
      {
         var _loc1_:String = sim_globals.BAtoString(this.frames);
         var _loc2_:int = _loc1_.length - 1;
         while(_loc1_.charAt(_loc2_) == "0" && _loc2_ > 0)
         {
            _loc2_--;
         }
         return _loc1_.substring(0,_loc2_);
      }
      
      public function IsReplayFinished() : Boolean
      {
         return false;
      }
      
      public function Tick(param1:uint) : void
      {
      }
      
      final public function IsButtonDown_Jump() : Boolean
      {
         return this.current_J;
      }
      
      final public function IsButtonDown_Left() : Boolean
      {
         return this.current_L;
      }
      
      final public function IsButtonDown_Right() : Boolean
      {
         return this.current_R;
      }
   }
}

