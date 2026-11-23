package editor
{
   import flash.events.Event;
   import flash.utils.ByteArray;
   
   public class EditorEvent extends Event
   {
      
      public static const EVENT_SAVE:String = "editor_save";
      
      public static const EVENT_QUIT:String = "editor_quit";
      
      public var leveldata:ByteArray;
      
      public var levelname:String;
      
      public function EditorEvent(param1:String, param2:Boolean = true, param3:Boolean = false)
      {
         super(param1,param2,param3);
         this.leveldata = null;
         this.levelname = null;
      }
      
      override public function clone() : Event
      {
         return new EditorEvent(type,bubbles,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("EditorEvent","type","bubbles","cancelable","eventPhase");
      }
   }
}

