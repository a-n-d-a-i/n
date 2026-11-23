package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol32")]
   public dynamic class EpisodesScreen extends MovieClip
   {
      
      public var returnButton:ReturnToMenuButton;
      
      public var thumbnails:MovieClip;
      
      public var grid:EpisodeGrid;
      
      public function EpisodesScreen()
      {
         super();
      }
   }
}

