package com.metanet.commands
{
   import com.metanet.data.AccountDetails;
   import com.metanet.events.MenuEvent;
   import com.metanet.remote.NRequest;
   import com.metanet.remote.NRequestFactory;
   import com.metanet.remote.NServerConnector;
   import org.robotlegs.mvcs.Command;
   
   public class Signup extends Command
   {
      
      [Inject]
      public var account:AccountDetails;
      
      [Inject]
      public var server:NServerConnector;
      
      [Inject]
      public var requestFactory:NRequestFactory;
      
      private var _valid:Boolean = true;
      
      public function Signup()
      {
         super();
      }
      
      override public function execute() : void
      {
         this.validate();
         if(!this._valid)
         {
            dispatch(new MenuEvent(MenuEvent.ACCOUNT_ERROR));
            return;
         }
         var _loc1_:NRequest = this.requestFactory.signup(this.account.email,this.account.enteredUserName,this.account.enteredPassword);
         this.server.sendRequest(_loc1_);
      }
      
      private function validate() : void
      {
         var _loc1_:Array = this.account.email.split("@");
         if(this.account.enteredUserName.length < 3)
         {
            this.account.error = "user names must be at least 3 characters";
            this._valid = false;
         }
         else if(this.account.enteredUserName.length > 40)
         {
            this.account.error = "user names must be no more than 40 characters";
            this._valid = false;
         }
         else if(!this.account.enteredUserName.charAt(0).match("[a-zA-Z]"))
         {
            this.account.error = "user names must start with a letter";
            this._valid = false;
         }
         else if(this.account.enteredPassword.length < 8)
         {
            this.account.error = "passwords must be at least 8 characters";
            this._valid = false;
         }
         else if(this.account.enteredPassword.length > 40)
         {
            this.account.error = "passwords must be no more than 40 characters";
            this._valid = false;
         }
         else if(this.account.email.length > 255)
         {
            this.account.error = "e-mail addresses must be no more than 255 characters";
            this._valid = false;
         }
         else if(_loc1_.length > 2)
         {
            this.account.error = "invalid email address";
            this._valid = false;
         }
         else if(_loc1_[0].length < 1 || _loc1_[1].length < 1)
         {
            this.account.error = "invalid email address";
            this._valid = false;
         }
         else if(_loc1_[1].indexOf(".") == -1)
         {
            this.account.error = "invalid email address";
            this._valid = false;
         }
         else if(_loc1_[0].length > 64)
         {
            this.account.error = "the part of email address before the @ symbol must be no more than 64 characters";
            this._valid = false;
         }
         else if(_loc1_[1] != _loc1_[1].toLowerCase())
         {
            this.account.error = "the part of the email address that follows the @ symbol cannot contain capital letters";
            this._valid = false;
         }
         else if(this.account.enteredPassword != this.account.enteredPasswordRetype)
         {
            this.account.error = "re-typed password did not match";
            this._valid = false;
         }
      }
   }
}

