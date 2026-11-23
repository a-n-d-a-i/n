package com.metanet.screens.levels
{
   import com.metanet.screens.levels.metanet.EpisodeBookmarksMediator;
   import com.metanet.screens.levels.metanet.MetanetLevelDisplayMediator;
   import com.metanet.screens.levels.mylevels.DeleteButtonMediator;
   import com.metanet.screens.levels.mylevels.EditButtonMediator;
   import com.metanet.screens.levels.mylevels.MyLevelPaneMediator;
   import com.metanet.screens.levels.mylevels.NewButtonMediator;
   import com.metanet.screens.levels.mylevels.PublishButtonMediator;
   import com.metanet.screens.levels.mylevels.SaveButtonMediator;
   import com.metanet.screens.levels.userlevels.FlagLevelMediator;
   import com.metanet.screens.levels.userlevels.Rate1Mediator;
   import com.metanet.screens.levels.userlevels.Rate2Mediator;
   import com.metanet.screens.levels.userlevels.Rate3Mediator;
   import com.metanet.screens.levels.userlevels.Rate4Mediator;
   import com.metanet.screens.levels.userlevels.Rate5Mediator;
   import com.metanet.screens.levels.userlevels.SearchAuthorMediator;
   import com.metanet.screens.levels.userlevels.SearchButtonMediator;
   import com.metanet.screens.levels.userlevels.SearchNewestMediator;
   import com.metanet.screens.levels.userlevels.SearchPopularMediator;
   import com.metanet.screens.levels.userlevels.SearchSectionMediator;
   import com.metanet.screens.levels.userlevels.SearchTitleMediator;
   import com.metanet.screens.levels.userlevels.SearchTypeMediator;
   import com.metanet.screens.levels.userlevels.SearchUnratedMediator;
   import com.metanet.screens.levels.userlevels.SelectedLevelPaneMediator;
   import org.robotlegs.core.IMediatorMap;
   
   public class LevelsMappings
   {
      
      public function LevelsMappings()
      {
         super();
      }
      
      public static function mapMediators(param1:IMediatorMap) : void
      {
         param1.mapView(UserLevelsScreen,LevelsScreenMediator);
         param1.mapView(EpisodeBookmarks,EpisodeBookmarksMediator);
         param1.mapView(UserLevelDisplay,LevelDisplayMediator);
         param1.mapView(SelectedLevelPane,SelectedLevelPaneMediator);
         param1.mapView(MetanetLevelDisplay,MetanetLevelDisplayMediator);
         param1.mapView(HighscoreSection,HighscoreSectionMediator);
         param1.mapView(SearchButton,SearchButtonMediator);
         param1.mapView(SearchTypeDropdown,SearchTypeMediator);
         param1.mapView(InputSearchTerm,InputSearchTermMediator);
         param1.mapView(NextButton,NextButtonMediator);
         param1.mapView(PreviousButton,PreviousButtonMediator);
         param1.mapView(PlayButton,PlayButtonMediator);
         param1.mapView(Rate1Button,Rate1Mediator);
         param1.mapView(Rate2Button,Rate2Mediator);
         param1.mapView(Rate3Button,Rate3Mediator);
         param1.mapView(Rate4Button,Rate4Mediator);
         param1.mapView(Rate5Button,Rate5Mediator);
         param1.mapView(FlagLevelButton,FlagLevelMediator);
         param1.mapView(FavouriteButton,FavouriteButtonMediator);
         param1.mapView(UnfavouriteButton,UnfavouriteButtonMediator);
         param1.mapView(SaveButton,SaveButtonMediator);
         param1.mapView(DeleteButton,DeleteButtonMediator);
         param1.mapView(NewButton,NewButtonMediator);
         param1.mapView(EditButton,EditButtonMediator);
         param1.mapView(PublishButton,PublishButtonMediator);
         param1.mapView(SelectedEditorLevelPane,MyLevelPaneMediator);
         param1.mapView(SearchSection,SearchSectionMediator);
         param1.mapView(SearchAuthorButton,SearchAuthorMediator);
         param1.mapView(SearchTitleButton,SearchTitleMediator);
         param1.mapView(SearchNewestButton,SearchNewestMediator);
         param1.mapView(SearchPopularButton,SearchPopularMediator);
         param1.mapView(SearchUnratedButton,SearchUnratedMediator);
      }
   }
}

