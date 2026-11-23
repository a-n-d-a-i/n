package com.metanet.data
{
   public class AccountDetails
   {
      
      public var enteredUserName:String = "";
      
      public var enteredPassword:String = "";
      
      public var loggedInUserName:String = "";
      
      public var email:String = "";
      
      public var enteredPasswordRetype:String = "";
      
      public var loggedIn:Boolean;
      
      public var cookie:String;
      
      public var userID:String;
      
      public var error:String;
      
      public var useDatabase:Boolean = true;
      
      public var isWeb:Boolean = false;
      
      public var canAddFavourites:Boolean = true;
      
      public var canCreateNewLevel:Boolean = true;
      
      public function AccountDetails()
      {
         super();
      }
   }
}

