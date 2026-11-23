package com.metanet.ui
{
   import flash.events.Event;
   
   public class BasicComboBoxEvent extends Event
   {
      
      public static var CHANGED:String = "selectionChanged";
      
      public function BasicComboBoxEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      override public function clone() : Event
      {
         return new BasicComboBoxEvent(type,bubbles,cancelable);
      }
   }
}

