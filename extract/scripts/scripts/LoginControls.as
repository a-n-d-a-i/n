package
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol308")]
   public dynamic class LoginControls extends MovieClip
   {
      
      public var statusField:TextField;
      
      public var reset:ResetPasswordPane;
      
      public var signup:RegisterPane;
      
      public var login:LoginPane;
      
      public var logout:LogoutPane;
      
      public function LoginControls()
      {
         super();
      }
   }
}

