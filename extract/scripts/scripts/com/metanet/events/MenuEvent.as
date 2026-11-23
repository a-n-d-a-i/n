package com.metanet.events
{
   import flash.events.Event;
   
   public class MenuEvent extends Event
   {
      
      public static const SHOW_LAST_SCREEN:String = "SelectLastScreen";
      
      public static const SHOW_MAIN_MENU:String = "ShowMainMenu";
      
      public static const SHOW_CREDITS:String = "ShowCredits";
      
      public static const SHOW_ACCOUNT:String = "ShowAccounts";
      
      public static const SHOW_HELP:String = "ShowHelp";
      
      public static const SHOW_STORY:String = "ShowStory";
      
      public static const SHOW_USER_LEVELS:String = "ShowUserLevels";
      
      public static const SHOW_EPISODES:String = "ShowEpisodes";
      
      public static const SHOW_SITELOCK:String = "ShowSiteLock";
      
      public static const RESET_LOCAL_DATA:String = "ResetLocalData";
      
      public static const STORE_DEFAULTS:String = "StoreDefaults";
      
      public static const LOGIN:String = "Login";
      
      public static const LOGOUT:String = "Logout";
      
      public static const SIGNUP:String = "Signup";
      
      public static const ACCOUNT_ERROR:String = "AccountError";
      
      public static const PUBLISH_LEVEL:String = "PublishLevel";
      
      public static const DELETE_LEVEL:String = "DeleteLevel";
      
      public function MenuEvent(param1:String)
      {
         super(param1,bubbles,cancelable);
      }
      
      override public function clone() : Event
      {
         return new MenuEvent(type);
      }
   }
}

