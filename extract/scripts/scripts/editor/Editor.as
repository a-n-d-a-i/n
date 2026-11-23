package editor
{
   import audiovisual.GraphicsManager;
   import audiovisual.SoundManager;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.media.SoundMixer;
   import flash.media.SoundTransform;
   import flash.ui.Keyboard;
   import flash.utils.ByteArray;
   import math.vec2;
   import simpleFramework.SimpleInput;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.sim_globals;
   import simulation.sim_loader;
   import tiles.tiletypes;
   
   public class Editor
   {
      
      private static const XFORMTYPE_INVERT:uint = 0;
      
      private static const XFORMTYPE_CLEAR:uint = 1;
      
      private static const XFORMTYPE_FILL:uint = 2;
      
      private static const XFORMTYPE_ROTATE_CW:uint = 3;
      
      private static const XFORMTYPE_ROTATE_CCW:uint = 4;
      
      private static const XFORMTYPE_MIRROR_H:uint = 5;
      
      private static const XFORMTYPE_MIRROR_V:uint = 6;
      
      private static const ENTITY_typelist:Vector.<uint> = new Vector.<uint>(18,true);
      
      private static const ENTITY_keylist:Vector.<uint> = new Vector.<uint>(18,true);
      
      private static const EDIT_key_delete_entities:uint = 84;
      
      private static const EDIT_key_clear_tiles:uint = 68;
      
      private static const EDIT_key_fill_tiles:uint = 69;
      
      private static const EDIT_key_invert_tiles:uint = 82;
      
      private static const EDIT_key_mirror_H:uint = 65;
      
      private static const EDIT_key_mirror_V:uint = 83;
      
      private static const EDIT_key_rotate_CCW:uint = 81;
      
      private static const EDIT_key_rotate_CW:uint = 87;
      
      private static const EDIT_key_copy_region:uint = 67;
      
      private static const EDIT_key_cut_region:uint = 88;
      
      private static const EDIT_key_paste_region:uint = 86;
      
      private static const EDIT_key_move:uint = 66;
      
      private static const TILE_key_NN:uint = 81;
      
      private static const TILE_key_PN:uint = 87;
      
      private static const TILE_key_PP:uint = 83;
      
      private static const TILE_key_NP:uint = 65;
      
      private static const TILE_key_Full:uint = 69;
      
      private static const TILE_key_Empty:uint = 68;
      
      private static const MAIN_key_menu:uint = 27;
      
      private static const MAIN_key_play:uint = 9;
      
      private static const MODE_PLACE_ENTITIES:uint = 0;
      
      private static const MODE_PLACE_TILES:uint = 1;
      
      private static const MODE_EDIT_ENTITIES:uint = 2;
      
      private static const MODE_EDIT_REGION:uint = 3;
      
      private static const EDITMODE_IDLE:uint = 0;
      
      private static const EDITMODE_DEFINING_REGION:uint = 1;
      
      private static const EDITMODE_REGION_DEFINED:uint = 2;
      
      private static const EDITMODE_DRAGGING:uint = 3;
      
      private static const EDITMODE_EDITING_BUFFER:uint = 4;
      
      ENTITY_typelist[0] = edat.ETYPE_PLAYER;
      ENTITY_keylist[0] = 57;
      ENTITY_typelist[1] = edat.ETYPE_GOLD;
      ENTITY_keylist[1] = 48;
      ENTITY_typelist[2] = edat.ETYPE_EXIT_DOOR;
      ENTITY_keylist[2] = 221;
      ENTITY_typelist[3] = edat.ETYPE_ONEWAY;
      ENTITY_keylist[3] = 219;
      ENTITY_typelist[4] = edat.ETYPE_BOUNCEBLOCK;
      ENTITY_keylist[4] = 189;
      ENTITY_typelist[5] = edat.ETYPE_LAUNCHPAD;
      ENTITY_keylist[5] = 187;
      ENTITY_typelist[6] = edat.ETYPE_DOOR_REGULAR;
      ENTITY_keylist[6] = 73;
      ENTITY_typelist[7] = edat.ETYPE_DOOR_LOCKED;
      ENTITY_keylist[7] = 79;
      ENTITY_typelist[8] = edat.ETYPE_DOOR_TRAP;
      ENTITY_keylist[8] = 80;
      ENTITY_typelist[9] = edat.ETYPE_TURRET;
      ENTITY_keylist[9] = 89;
      ENTITY_typelist[10] = edat.ETYPE_ROCKET;
      ENTITY_keylist[10] = 85;
      ENTITY_typelist[11] = edat.ETYPE_FLOORGUARD;
      ENTITY_keylist[11] = 78;
      ENTITY_typelist[12] = edat.ETYPE_MINE;
      ENTITY_keylist[12] = 77;
      ENTITY_typelist[13] = edat.ETYPE_ZAP;
      ENTITY_keylist[13] = 72;
      ENTITY_typelist[14] = edat.ETYPE_CHASER;
      ENTITY_keylist[14] = 74;
      ENTITY_typelist[15] = edat.ETYPE_LASER;
      ENTITY_keylist[15] = 75;
      ENTITY_typelist[16] = edat.ETYPE_CHAINGUN;
      ENTITY_keylist[16] = 76;
      ENTITY_typelist[17] = edat.ETYPE_THWOMP;
      ENTITY_keylist[17] = 188;
      
      private var input:SimpleInput;
      
      private var rend:SimpleRenderer;
      
      private var stage:Sprite;
      
      private var stage_mainmenu:Sprite;
      
      private var stage_editmenu:Sprite;
      
      private var stage_game:Sprite;
      
      private var stage_gamemenu:Sprite;
      
      private var stage_editor:Sprite;
      
      private var stage_editorhud:Sprite;
      
      private var sim:Simulator;
      
      private var gfx:GraphicsManager;
      
      private var sfx:SoundManager;
      
      private var edit_rend:Editor_Renderer;
      
      private var current_state:Editor_State;
      
      private var current_name:String;
      
      public var event_dispatcher:EventDispatcher;
      
      private var isInMenu:Boolean;
      
      private var isTesting:Boolean;
      
      private var MAIN_mainmenu_mc:asset_editor_mainmenu;
      
      private var MAIN_editmenu_mc:asset_editor_editmenu;
      
      private var GAME_phase:int;
      
      private var GAME_game_stage:Sprite;
      
      private var GAME_menu_mc_ingame:asset_editor_ingamemenu;
      
      private var EDIT_hud_mc:asset_editor_hud;
      
      private var editor_mode:uint;
      
      private var EDIT_tile_buffer:TileRect;
      
      private var EDIT_entity_buffer:EntityBuffer;
      
      private var EDIT_mode:uint;
      
      private var EDIT_start_tile:vec2;
      
      private var EDIT_end_tile:vec2;
      
      private var EDIT_min_tile:vec2;
      
      private var EDIT_max_tile:vec2;
      
      private var EDIT_is_select_entities_on_border:Boolean;
      
      private var EDIT_is_empty_tiles_opaque:Boolean;
      
      private var DRAW_grid_style:uint;
      
      private var DRAW_is_snap_grid:Boolean;
      
      private var ENTITY_dragged_id:int;
      
      private var ENTITY_type:uint;
      
      private var ENTITY_dir:uint;
      
      private var ENTITY_move:uint;
      
      private var ENTITY_isHalfSnap:Boolean;
      
      private var TILE_type:uint;
      
      private var UNDO_undo_stack:Vector.<Editor_State>;
      
      private var UNDO_current_index:int;
      
      private var UNDO_is_undoing:Boolean;
      
      private var IS_LEVEL_UNSAVED:Boolean;
      
      private var SIM_is_paused:Boolean;
      
      private var HUD_padding:Number;
      
      private var HUD_isVisible:Boolean;
      
      private var button_save:Boolean;
      
      private var button_quit:Boolean;
      
      private var button_resume:Boolean;
      
      private var button_hotkey:Boolean;
      
      private var button_edit_entities:Boolean;
      
      private var button_gridstyle:Boolean;
      
      private var button_snapgrid:Boolean;
      
      private var button_snapsize:Boolean;
      
      private var button_border:Boolean;
      
      private var button_opaque:Boolean;
      
      private var button_confirm_quit:Boolean;
      
      private var button_confirm_saveandquit:Boolean;
      
      private var button_confirm_cancel:Boolean;
      
      private var button_undo:Boolean;
      
      private var button_redo:Boolean;
      
      private var button_game_toggle:Boolean;
      
      private var button_game_pause:Boolean;
      
      private var button_game_reset:Boolean;
      
      public function Editor(param1:SimpleInput, param2:SimpleRenderer, param3:Sprite)
      {
         super();
         sim_globals.sim_rate = 60;
         this.input = param1;
         this.rend = param2;
         this.stage = param3;
         this.stage_editor = new Sprite();
         this.stage_editorhud = new Sprite();
         this.stage_game = new Sprite();
         this.stage_gamemenu = new Sprite();
         this.stage_editmenu = new Sprite();
         this.stage_mainmenu = new Sprite();
         this.stage.addChild(this.stage_editor);
         this.stage.addChild(this.stage_editorhud);
         this.stage.addChild(this.stage_game);
         this.stage.addChild(this.stage_gamemenu);
         this.stage.addChild(this.stage_editmenu);
         this.stage.addChild(this.stage_mainmenu);
         this.edit_rend = new Editor_Renderer(this.stage_editor);
         this.event_dispatcher = new EventDispatcher();
         this.MAIN_mainmenu_mc = new asset_editor_mainmenu();
         this.stage_mainmenu.addChild(this.MAIN_mainmenu_mc);
         this.MAIN_mainmenu_mc.textfield_levelname.background = true;
         this.MAIN_mainmenu_mc.panel_confirm.visible = false;
         this.MAIN_mainmenu_mc.visible = false;
         this.MAIN_mainmenu_mc.button_save.addEventListener(MouseEvent.CLICK,this.ButtonCallback_Save);
         this.MAIN_mainmenu_mc.button_quit.addEventListener(MouseEvent.CLICK,this.ButtonCallback_Quit);
         this.MAIN_mainmenu_mc.button_resume.addEventListener(MouseEvent.CLICK,this.ButtonCallback_Resume);
         this.MAIN_mainmenu_mc.panel_confirm.button_confirm_quit.addEventListener(MouseEvent.CLICK,this.ButtonCallback_Confirm_Quit);
         this.MAIN_mainmenu_mc.panel_confirm.button_save_and_quit.addEventListener(MouseEvent.CLICK,this.ButtonCallback_Confirm_SaveAndQuit);
         this.MAIN_mainmenu_mc.panel_confirm.button_cancel_quit.addEventListener(MouseEvent.CLICK,this.ButtonCallback_Confirm_Cancel);
         this.MAIN_editmenu_mc = new asset_editor_editmenu();
         this.stage_editmenu.addChild(this.MAIN_editmenu_mc);
         this.MAIN_editmenu_mc.visible = false;
         this.MAIN_editmenu_mc.addEventListener(MouseEvent.CLICK,this.ButtonCallback_EditMenu);
         this.GAME_menu_mc_ingame = new asset_editor_ingamemenu();
         this.stage_gamemenu.addChild(this.GAME_menu_mc_ingame);
         this.EDIT_hud_mc = new asset_editor_hud();
         this.stage_editorhud.addChild(this.EDIT_hud_mc);
         this.EDIT_hud_mc.visible = false;
         this.HUD_padding = edat.cell_size;
         this.EDIT_hud_mc.tile_hud.x = this.HUD_padding;
         this.EDIT_hud_mc.tile_hud.y = this.HUD_padding;
         this.EDIT_hud_mc.entity_hud.x = this.HUD_padding;
         this.EDIT_hud_mc.entity_hud.y = this.HUD_padding;
         this.EDIT_hud_mc.edit_hud.x = this.HUD_padding;
         this.EDIT_hud_mc.edit_hud.y = this.HUD_padding;
         this.EDIT_hud_mc.region_hud.x = this.HUD_padding;
         this.EDIT_hud_mc.region_hud.y = this.HUD_padding;
         this.Init();
      }
      
      private function Init() : void
      {
         this.current_state = null;
         this.current_name = "";
         this.EDIT_tile_buffer = null;
         this.EDIT_entity_buffer = null;
         this.EDIT_start_tile = new vec2();
         this.EDIT_end_tile = new vec2();
         this.EDIT_min_tile = new vec2();
         this.EDIT_max_tile = new vec2();
         this.EDIT_mode = EDITMODE_IDLE;
         this.EDIT_is_select_entities_on_border = true;
         this.EDIT_is_empty_tiles_opaque = true;
         this.TILE_type = 0;
         this.ENTITY_dir = 0;
         this.ENTITY_move = edat.MOVE_WANDER_CW;
         this.ENTITY_type = 0;
         this.ENTITY_isHalfSnap = true;
         this.ENTITY_dragged_id = -1;
         this.DRAW_grid_style = 1;
         this.DRAW_is_snap_grid = true;
         this.UNDO_undo_stack = new Vector.<Editor_State>();
         this.UNDO_current_index = -1;
         this.UNDO_is_undoing = false;
         this.editor_mode = MODE_PLACE_TILES;
         this.IS_LEVEL_UNSAVED = false;
         this.SIM_is_paused = false;
         this.HUD_isVisible = true;
         this.isInMenu = false;
         this.isTesting = false;
         this.GAME_phase = -1;
         this.HELPER_ClearAllCallbackFlags();
      }
      
      public function APP_LoadLevel_Old(param1:String, param2:String, param3:Boolean = false) : void
      {
         this.Init();
         this.current_state = sim_loader.BuildEditorState_OldData(param2);
         this.current_name = param1;
         this.MAIN_mainmenu_mc.textfield_levelname.text = this.current_name;
         this.IS_LEVEL_UNSAVED = false;
         if(param3)
         {
            this.isTesting = true;
         }
      }
      
      public function APP_LoadLevel_Bytes(param1:String, param2:ByteArray, param3:Boolean = false) : void
      {
         this.Init();
         this.current_state = Editor_State.Load_From_Bytes(param2);
         this.current_name = param1;
         this.MAIN_mainmenu_mc.textfield_levelname.text = this.current_name;
         this.IS_LEVEL_UNSAVED = false;
         if(param3)
         {
            this.isTesting = true;
         }
      }
      
      private function SanitizeCurrentStateForSaving() : void
      {
         if(this.EDIT_entity_buffer != null)
         {
            if(this.EDIT_entity_buffer.unmatchedCount != 0)
            {
               this.HELPER_Dispose_Entity_Buffer(this.EDIT_entity_buffer,this.current_state.entities);
            }
         }
      }
      
      private function Save() : void
      {
         this.SanitizeCurrentStateForSaving();
         var _loc1_:EditorEvent = new EditorEvent(EditorEvent.EVENT_SAVE);
         _loc1_.leveldata = Editor_State.Save_To_Bytes(this.current_state);
         _loc1_.levelname = this.current_name;
         this.event_dispatcher.dispatchEvent(_loc1_);
         this.IS_LEVEL_UNSAVED = false;
      }
      
      private function Quit() : void
      {
         this.current_state = null;
         this.edit_rend.Clear();
         this.stage.removeChild(this.stage_editor);
         this.stage.removeChild(this.stage_editorhud);
         this.stage.removeChild(this.stage_game);
         this.stage.removeChild(this.stage_gamemenu);
         this.stage.removeChild(this.stage_editmenu);
         this.stage.removeChild(this.stage_mainmenu);
         var _loc1_:EditorEvent = new EditorEvent(EditorEvent.EVENT_QUIT);
         this.event_dispatcher.dispatchEvent(_loc1_);
      }
      
      public function Tick() : void
      {
         var _loc18_:SoundMixer = null;
         var _loc19_:* = null;
         var _loc20_:String = null;
         var _loc21_:Array = null;
         var _loc22_:Array = null;
         var _loc23_:ByteArray = null;
         var _loc24_:ByteArray = null;
         var _loc25_:Vector.<int> = null;
         var _loc26_:Array = null;
         var _loc27_:int = 0;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc30_:vec2 = null;
         var _loc31_:int = 0;
         var _loc32_:uint = 0;
         var _loc33_:uint = 0;
         var _loc34_:int = 0;
         var _loc35_:int = 0;
         var _loc36_:Vector.<Vector.<uint>> = null;
         var _loc37_:Boolean = false;
         var _loc38_:Boolean = false;
         var _loc39_:Vector.<Vector.<uint>> = null;
         var _loc40_:int = 0;
         var _loc41_:Vector.<uint> = null;
         var _loc42_:uint = 0;
         var _loc43_:int = 0;
         var _loc44_:int = 0;
         var _loc45_:Vector.<uint> = null;
         var _loc46_:uint = 0;
         var _loc47_:Vector.<uint> = null;
         var _loc48_:TileRect = null;
         var _loc49_:TileRect = null;
         var _loc50_:TileRect = null;
         var _loc51_:TileRect = null;
         var _loc52_:EntityBuffer = null;
         var _loc53_:TileRect = null;
         var _loc54_:EntityBuffer = null;
         var _loc55_:TileRect = null;
         var _loc56_:TileRect = null;
         var _loc57_:uint = 0;
         var _loc58_:uint = 0;
         var _loc59_:int = 0;
         var _loc60_:int = 0;
         var _loc61_:Number = NaN;
         var _loc62_:Vector.<uint> = null;
         var _loc63_:Vector.<uint> = null;
         var _loc64_:Number = NaN;
         var _loc65_:Editor_State = null;
         var _loc66_:Vector.<uint> = null;
         var _loc67_:Vector.<Vector.<uint>> = null;
         var _loc68_:int = 0;
         var _loc69_:Editor_State = null;
         var _loc70_:Vector.<uint> = null;
         var _loc71_:int = 0;
         var _loc72_:uint = 0;
         var _loc73_:uint = 0;
         var _loc74_:Vector.<uint> = null;
         var _loc75_:uint = 0;
         var _loc76_:Number = NaN;
         var _loc77_:Number = NaN;
         var _loc78_:Number = NaN;
         var _loc79_:Number = NaN;
         var _loc80_:Number = NaN;
         var _loc81_:Number = NaN;
         var _loc82_:int = 0;
         var _loc83_:int = 0;
         var _loc84_:uint = 0;
         var _loc85_:Number = NaN;
         var _loc86_:Number = NaN;
         var _loc87_:Number = NaN;
         var _loc88_:Number = NaN;
         var _loc89_:int = 0;
         var _loc90_:uint = 0;
         var _loc91_:int = 0;
         var _loc92_:int = 0;
         var _loc93_:Number = NaN;
         var _loc94_:Number = NaN;
         var _loc95_:Number = NaN;
         var _loc96_:Number = NaN;
         if(this.current_state == null)
         {
            return;
         }
         if(this.input.IsKeyDown(Keyboard.CONTROL))
         {
            if(this.input.IsKeyPressed(Keyboard.S))
            {
               this.Save();
            }
         }
         if(this.input.IsKeyDown(Keyboard.CONTROL) && this.input.IsKeyPressed(Keyboard.M))
         {
            _loc18_ = new SoundMixer();
            if(this.input.IsKeyDown(Keyboard.SHIFT))
            {
               SoundMixer.soundTransform = new SoundTransform(1);
            }
            else
            {
               SoundMixer.soundTransform = new SoundTransform(0);
            }
         }
         if(this.input.IsKeyPressed(Keyboard.PAGE_DOWN))
         {
            this.isInMenu = true;
         }
         if(this.isInMenu)
         {
            this.EDIT_hud_mc.visible = false;
            this.MAIN_editmenu_mc.visible = false;
            this.MAIN_mainmenu_mc.visible = true;
            this.current_name = this.MAIN_mainmenu_mc.textfield_levelname.text;
            if(this.input.IsKeyPressed(MAIN_key_menu) || this.button_resume)
            {
               this.isInMenu = false;
            }
            if(this.button_save)
            {
               this.Save();
            }
            if(this.MAIN_mainmenu_mc.panel_confirm.visible)
            {
               if(this.button_confirm_quit)
               {
                  this.Quit();
                  return;
               }
               if(this.button_confirm_saveandquit)
               {
                  this.Save();
                  this.Quit();
                  return;
               }
               if(this.button_confirm_cancel)
               {
                  this.MAIN_mainmenu_mc.panel_confirm.visible = false;
               }
            }
            if(this.button_quit || this.input.IsKeyPressed(Keyboard.Q))
            {
               if(!this.IS_LEVEL_UNSAVED)
               {
                  this.Quit();
                  return;
               }
               this.MAIN_mainmenu_mc.panel_confirm.visible = true;
            }
            if(this.input.IsKeyPressed(Keyboard.PAGE_DOWN))
            {
               this.MAIN_mainmenu_mc.panel_leveldata.visible = true;
               this.SanitizeCurrentStateForSaving();
               _loc19_ = sim_globals.BAtoString(Editor_State.Save_To_Bytes(this.current_state));
               if(this.input.IsKeyDown(Keyboard.SHIFT))
               {
                  _loc19_ = "%" + this.current_name + "#" + _loc19_ + "#";
               }
               this.MAIN_mainmenu_mc.panel_leveldata.textfield_leveldata.text = _loc19_;
            }
            else if(this.input.IsKeyPressed(Keyboard.PAGE_UP) && this.MAIN_mainmenu_mc.panel_leveldata.visible == true)
            {
               _loc20_ = this.MAIN_mainmenu_mc.panel_leveldata.textfield_leveldata.text;
               _loc20_ = _loc20_.replace("\n","");
               _loc20_ = _loc20_.replace("\r","");
               _loc20_ = _loc20_.replace("\n\r","");
               if(_loc20_.charAt(0) == "$")
               {
                  _loc21_ = _loc20_.substring(1,_loc20_.length).split("#");
                  this.APP_LoadLevel_Old(_loc21_[0],_loc21_[_loc21_.length - 2],this.isTesting);
               }
               else if(_loc20_.charAt(0) == "%")
               {
                  _loc22_ = _loc20_.substring(1,_loc20_.length).split("#");
                  _loc23_ = sim_globals.StringtoBA(_loc22_[_loc22_.length - 2]);
                  if(!sim_globals.HORRIBLY_HACKY_DOES_STRING_TO_BA_ERROR_EXIST)
                  {
                     this.APP_LoadLevel_Bytes(_loc22_[0],_loc23_,this.isTesting);
                  }
                  else
                  {
                     this.MAIN_mainmenu_mc.panel_leveldata.textfield_leveldata.text = "ERROR: loading failed! Your input data was invalid.";
                  }
               }
               else if(this.input.IsKeyDown(Keyboard.SHIFT))
               {
                  this.APP_LoadLevel_Old("untitled",_loc20_,this.isTesting);
               }
               else
               {
                  _loc24_ = sim_globals.StringtoBA(_loc20_);
                  if(!sim_globals.HORRIBLY_HACKY_DOES_STRING_TO_BA_ERROR_EXIST && _loc24_.length > 4)
                  {
                     this.APP_LoadLevel_Bytes("untitled",_loc24_,this.isTesting);
                  }
                  else
                  {
                     this.MAIN_mainmenu_mc.panel_leveldata.textfield_leveldata.text = "ERROR: loading failed! Your input data was invalid.";
                  }
               }
               this.HELPER_ClearAllCallbackFlags();
               return;
            }
            if(this.isTesting)
            {
               this.gfx.Render();
            }
            else
            {
               this.edit_rend.StartFrame();
               this.edit_rend.DrawTiles_Background(this.current_state.tileIDs);
               this.edit_rend.DrawEntities_Background(this.current_state.entities);
            }
            this.HELPER_ClearAllCallbackFlags();
            return;
         }
         this.MAIN_mainmenu_mc.visible = false;
         this.MAIN_mainmenu_mc.panel_leveldata.visible = false;
         this.MAIN_mainmenu_mc.panel_confirm.visible = false;
         if(this.input.IsKeyPressed(MAIN_key_menu))
         {
            this.isInMenu = true;
         }
         if(this.isTesting)
         {
            this.EDIT_hud_mc.visible = false;
            this.edit_rend.Hide();
            if(this.input.IsKeyPressed(MAIN_key_play) || this.button_game_toggle)
            {
               this.isTesting = false;
            }
            if(this.GAME_phase == -1)
            {
               if(this.sim != null)
               {
                  this.sim = null;
               }
               if(this.gfx != null)
               {
                  this.gfx.Clear();
                  this.gfx = null;
               }
               if(this.sfx != null)
               {
                  this.sfx = null;
               }
               if(this.GAME_game_stage != null)
               {
                  this.stage_game.removeChild(this.GAME_game_stage);
                  this.GAME_game_stage = null;
               }
               this.GAME_game_stage = new Sprite();
               this.stage_game.addChild(this.GAME_game_stage);
               _loc25_ = new Vector.<int>();
               _loc25_.push(Keyboard.Z);
               _loc25_.push(Keyboard.LEFT);
               _loc25_.push(Keyboard.RIGHT);
               _loc25_.push(78);
               _loc25_.push(188);
               _loc25_.push(190);
               _loc25_.push(72);
               _loc25_.push(75);
               _loc25_.push(76);
               _loc25_.push(89);
               _loc25_.push(73);
               _loc25_.push(79);
               _loc26_ = new Array();
               _loc26_.push(0);
               _loc26_.push(0);
               this.sim = sim_loader.LoadLevel_EditorState(_loc25_,_loc26_,this.input,null,0,this.current_state);
               this.gfx = new GraphicsManager(this.GAME_game_stage,this.sim.GFX_GetEntityList(),this.sim.GFX_GetPlayerList(),this.sim.GFX_GetTileIDs(),Simulator.GRID_NUM_ROWS,Simulator.GRID_NUM_COLS,true);
               this.sfx = new SoundManager();
               this.sim.HACKY_SetAV(this.gfx,this.sfx);
               this.sim.APP_EnablePlayer(0);
               this.GAME_menu_mc_ingame.visible = true;
               this.GAME_menu_mc_ingame.prompt.visible = true;
               this.GAME_menu_mc_ingame.prompt.gotoAndPlay("begin");
               this.GAME_menu_mc_ingame.levelname.text = this.current_name;
               this.GAME_phase = 0;
               this.SIM_is_paused = false;
            }
            if(this.GAME_phase == 0)
            {
               if(this.input.IsKeyPressed(Keyboard.Z))
               {
                  this.GAME_menu_mc_ingame.prompt.visible = false;
                  this.GAME_phase = 1;
               }
               this.gfx.Render();
            }
            else
            {
               if(this.input.IsKeyPressed(Keyboard.P) || this.button_game_pause)
               {
                  this.SIM_is_paused = !this.SIM_is_paused;
               }
               this.HELPER_Tick_Sim();
               if(this.input.IsKeyPressed(Keyboard.R) || this.button_game_reset)
               {
                  this.GAME_phase = -1;
               }
               if(this.input.IsKeyPressed(Keyboard.Z) && this.sim.APP_IsGameDone())
               {
                  this.GAME_phase = -1;
               }
            }
            this.HELPER_ClearAllCallbackFlags();
            return;
         }
         if(this.sim != null)
         {
            this.sim = null;
         }
         if(this.gfx != null)
         {
            this.gfx.Clear();
            this.gfx = null;
         }
         if(this.sfx != null)
         {
            this.sfx = null;
         }
         if(this.GAME_game_stage != null)
         {
            this.stage_game.removeChild(this.GAME_game_stage);
            this.GAME_game_stage = null;
         }
         this.GAME_menu_mc_ingame.visible = false;
         this.edit_rend.StartFrame();
         this.edit_rend.Show();
         this.EDIT_hud_mc.visible = true;
         if(this.input.IsKeyDown(Keyboard.CONTROL) && this.input.IsKeyPressed(Keyboard.Z) || this.button_undo)
         {
            this.Undo();
         }
         else if(this.input.IsKeyDown(Keyboard.CONTROL) && this.input.IsKeyPressed(Keyboard.Y) || this.button_redo)
         {
            this.Redo();
         }
         var _loc1_:Boolean = false;
         var _loc2_:uint = this.editor_mode;
         var _loc3_:uint = this.ENTITY_type;
         var _loc4_:uint = this.EDIT_mode;
         if(!this.input.IsKeyDown(Keyboard.CONTROL))
         {
            _loc27_ = 0;
            while(_loc27_ < ENTITY_keylist.length)
            {
               if(this.input.IsKeyPressed(ENTITY_keylist[_loc27_]))
               {
                  this.editor_mode = MODE_PLACE_ENTITIES;
                  this.ENTITY_type = ENTITY_typelist[_loc27_];
                  _loc1_ = true;
                  break;
               }
               _loc27_++;
            }
         }
         var _loc5_:int = 0;
         while(_loc5_ < 8)
         {
            if(this.input.IsKeyPressed(49 + _loc5_))
            {
               this.editor_mode = MODE_PLACE_TILES;
               this.TILE_type = _loc5_;
               _loc1_ = true;
               break;
            }
            _loc5_++;
         }
         if(this.input.IsKeyPressed(70) || this.button_edit_entities)
         {
            this.editor_mode = MODE_EDIT_ENTITIES;
            _loc1_ = true;
         }
         if(this.editor_mode == MODE_EDIT_REGION && (this.input.IsKeyPressed(Keyboard.Z) && !this.input.IsKeyDown(Keyboard.CONTROL)))
         {
            this.editor_mode = MODE_PLACE_TILES;
         }
         if(this.input.IsKeyPressed(222) || this.button_gridstyle)
         {
            this.DRAW_grid_style = (this.DRAW_grid_style + 1) % 4;
         }
         if(this.input.IsKeyPressed(186) || this.button_snapgrid)
         {
            this.DRAW_is_snap_grid = !this.DRAW_is_snap_grid;
         }
         if(this.input.IsKeyPressed(191) || this.button_snapsize)
         {
            this.ENTITY_isHalfSnap = !this.ENTITY_isHalfSnap;
         }
         if(this.input.IsKeyPressed(190) || this.button_border)
         {
            this.EDIT_is_select_entities_on_border = !this.EDIT_is_select_entities_on_border;
         }
         if(this.input.IsKeyPressed(Keyboard.G) || this.button_opaque)
         {
            this.EDIT_is_empty_tiles_opaque = !this.EDIT_is_empty_tiles_opaque;
         }
         if(this.input.IsKeyPressed(Keyboard.BACKQUOTE))
         {
            this.HUD_isVisible = !this.HUD_isVisible;
         }
         if(_loc1_ || this.button_hotkey || !this.input.IsKeyDown(Keyboard.SPACE) || this.button_game_toggle)
         {
            this.MAIN_editmenu_mc.visible = false;
         }
         else if(this.input.IsKeyPressed(Keyboard.SPACE))
         {
            this.MAIN_editmenu_mc.visible = true;
         }
         if(this.MAIN_editmenu_mc.visible)
         {
            this.EDIT_hud_mc.visible = false;
            this.MAIN_editmenu_mc.button_gridstyle.gotoAndStop(this.DRAW_grid_style + 1);
            this.MAIN_editmenu_mc.button_border.gotoAndStop(1);
            if(!this.EDIT_is_select_entities_on_border)
            {
               this.MAIN_editmenu_mc.button_border.gotoAndStop(2);
            }
            this.MAIN_editmenu_mc.button_opaque.gotoAndStop(1);
            if(!this.EDIT_is_empty_tiles_opaque)
            {
               this.MAIN_editmenu_mc.button_opaque.gotoAndStop(2);
            }
            this.MAIN_editmenu_mc.button_snapgrid.gotoAndStop(1);
            if(this.DRAW_is_snap_grid)
            {
               this.MAIN_editmenu_mc.button_snapgrid.gotoAndStop(2);
            }
            this.MAIN_editmenu_mc.button_snapsize.gotoAndStop(2);
            if(this.ENTITY_isHalfSnap)
            {
               this.MAIN_editmenu_mc.button_snapsize.gotoAndStop(1);
            }
            this.edit_rend.DrawTiles_Background(this.current_state.tileIDs);
            this.edit_rend.DrawEntities_Background(this.current_state.entities);
            this.HELPER_ClearAllCallbackFlags();
            return;
         }
         this.EDIT_hud_mc.visible = true;
         this.EDIT_hud_mc.tile_hud.visible = false;
         this.EDIT_hud_mc.entity_hud.visible = false;
         this.EDIT_hud_mc.edit_hud.visible = false;
         this.EDIT_hud_mc.region_hud.visible = false;
         this.EDIT_hud_mc.mode_textbox.text = "";
         _loc28_ = this.stage.width / 2;
         _loc29_ = this.stage.height / 2;
         _loc30_ = this.input.GetMousePos();
         if(_loc30_.y < _loc29_)
         {
            _loc31_ = (edat.num_cols + 2) * edat.cell_size;
            if(_loc30_.x < _loc28_)
            {
               this.EDIT_hud_mc.tile_hud.x = _loc31_ - (120 + this.HUD_padding);
               this.EDIT_hud_mc.entity_hud.x = _loc31_ - (144 + this.HUD_padding);
               this.EDIT_hud_mc.edit_hud.x = _loc31_ - (144 + this.HUD_padding);
               this.EDIT_hud_mc.region_hud.x = _loc31_ - (200 + this.HUD_padding);
            }
            else
            {
               this.EDIT_hud_mc.tile_hud.x = this.HUD_padding;
               this.EDIT_hud_mc.entity_hud.x = this.HUD_padding;
               this.EDIT_hud_mc.edit_hud.x = this.HUD_padding;
               this.EDIT_hud_mc.region_hud.x = this.HUD_padding;
            }
         }
         if(this.input.IsKeyPressed(MAIN_key_play) || this.button_game_toggle)
         {
            this.isTesting = true;
            this.GAME_phase = -1;
         }
         if(this.isTesting)
         {
            if(this.editor_mode == MODE_EDIT_REGION)
            {
               this.editor_mode == MODE_PLACE_TILES;
            }
         }
         if(this.editor_mode != MODE_EDIT_REGION || _loc4_ == EDITMODE_EDITING_BUFFER && this.EDIT_mode != EDITMODE_EDITING_BUFFER || _loc4_ == EDITMODE_DRAGGING && this.EDIT_mode != EDITMODE_DRAGGING)
         {
            if(this.EDIT_tile_buffer != null)
            {
               this.EDIT_tile_buffer = null;
            }
            if(this.EDIT_entity_buffer != null)
            {
               this.HELPER_Dispose_Entity_Buffer(this.EDIT_entity_buffer,this.current_state.entities);
               this.EDIT_entity_buffer = null;
            }
         }
         if((this.isTesting && this.editor_mode == MODE_PLACE_ENTITIES || this.editor_mode != _loc2_ && _loc2_ == MODE_PLACE_ENTITIES) && (this.ENTITY_type == edat.ETYPE_SWITCH_LOCKED || this.ENTITY_type == edat.ETYPE_SWITCH_TRAP || this.ENTITY_type == edat.ETYPE_EXIT_SWITCH))
         {
            this.current_state.entities.pop();
            --this.ENTITY_type;
         }
         else if(this.editor_mode == MODE_PLACE_ENTITIES && this.ENTITY_type != _loc3_ && (_loc3_ == edat.ETYPE_SWITCH_LOCKED || _loc3_ == edat.ETYPE_SWITCH_TRAP || _loc3_ == edat.ETYPE_EXIT_SWITCH))
         {
            this.current_state.entities.pop();
         }
         var _loc6_:vec2 = this.input.GetMousePos();
         _loc6_.x = Math.max(0,_loc6_.x);
         _loc6_.y = Math.max(0,_loc6_.y);
         var _loc7_:uint = Math.max(1,Math.min(edat.num_cols,Math.floor(_loc6_.x / edat.cell_size)));
         var _loc8_:uint = Math.max(1,Math.min(edat.num_rows,Math.floor(_loc6_.y / edat.cell_size)));
         var _loc9_:uint = 0;
         var _loc10_:uint = 0;
         var _loc11_:vec2 = new vec2((Number(_loc7_) + 0.5) * edat.cell_size,(Number(_loc8_) + 0.5) * edat.cell_size);
         var _loc12_:vec2 = _loc11_.To(_loc6_);
         var _loc13_:uint = 1;
         var _loc14_:uint = 1;
         var _loc15_:* = this.ENTITY_isHalfSnap;
         if(this.editor_mode == MODE_PLACE_TILES)
         {
            this.EDIT_hud_mc.mode_textbox.text = "editor mode: PAINT TILES";
            if(this.input.IsKeyPressed(TILE_key_Full) || this.input.IsKeyPressed(TILE_key_Empty) || this.input.IsKeyPressed(TILE_key_NN) || this.input.IsKeyPressed(TILE_key_NP) || this.input.IsKeyPressed(TILE_key_PN) || this.input.IsKeyPressed(TILE_key_PP) && !this.input.IsKeyDown(Keyboard.CONTROL))
            {
               this.Add_Undo_Frame();
            }
            _loc32_ = this.TILE_type;
            if(this.input.IsKeyDown(Keyboard.SHIFT))
            {
               _loc32_ = (_loc32_ + 4) % 8;
            }
            this.edit_rend.DrawCell(_loc7_,_loc8_,edat.cell_size);
            _loc33_ = 0;
            if(_loc32_ == 4)
            {
               _loc33_ = 1;
            }
            _loc34_ = -1;
            if(this.input.IsKeyDown(TILE_key_Full))
            {
               _loc34_ = tiletypes.FULL;
            }
            else if(this.input.IsKeyDown(TILE_key_Empty))
            {
               _loc34_ = tiletypes.EMPTY;
            }
            else if(this.input.IsKeyDown(TILE_key_PP) && !this.input.IsKeyDown(Keyboard.CONTROL))
            {
               _loc34_ = edat.MAP_TILETYPE_TO_TILEID[_loc32_] + (0 + _loc33_) % 4;
            }
            else if(this.input.IsKeyDown(TILE_key_NP))
            {
               _loc34_ = edat.MAP_TILETYPE_TO_TILEID[_loc32_] + (1 + _loc33_) % 4;
            }
            else if(this.input.IsKeyDown(TILE_key_NN))
            {
               _loc34_ = edat.MAP_TILETYPE_TO_TILEID[_loc32_] + (2 + _loc33_) % 4;
            }
            else if(this.input.IsKeyDown(TILE_key_PN))
            {
               _loc34_ = edat.MAP_TILETYPE_TO_TILEID[_loc32_] + (3 + _loc33_) % 4;
            }
            if(_loc34_ >= 0)
            {
               this.Paint_Tile(_loc7_,_loc8_,_loc34_,this.current_state.tileIDs);
            }
            if(this.HUD_isVisible)
            {
               this.EDIT_hud_mc.tile_hud.visible = true;
               this.EDIT_hud_mc.tile_hud.gotoAndStop(_loc32_ + 1);
            }
            this.edit_rend.DrawTiles_Background(this.current_state.tileIDs);
            this.edit_rend.DrawEntities_Background(this.current_state.entities);
            if(this.input.IsMousePressed())
            {
               this.editor_mode = MODE_EDIT_REGION;
               this.EDIT_mode = EDITMODE_IDLE;
            }
         }
         if(this.editor_mode == MODE_PLACE_ENTITIES)
         {
            this.EDIT_hud_mc.mode_textbox.text = "editor mode: PLACE OBJECTS";
            if(this.input.IsKeyDown(Keyboard.SHIFT))
            {
               _loc15_ = !_loc15_;
            }
            if(this.input.IsKeyDown(EDIT_key_delete_entities))
            {
               _loc35_ = this.GetIndexOfEntityUnderPoint(_loc6_,this.current_state.entities);
               if(_loc35_ >= 0)
               {
                  if(this.input.IsMousePressed())
                  {
                     this.Add_Undo_Frame();
                     this.Delete_Single_Entity(_loc35_,this.current_state.entities);
                     _loc35_ = -1;
                  }
               }
               if(_loc35_ >= 0)
               {
                  _loc36_ = new Vector.<Vector.<uint>>();
                  _loc36_.push(this.current_state.entities[_loc35_]);
                  this.edit_rend.DrawEntities_Selected(_loc36_,0,0);
               }
               this.edit_rend.DrawTiles_Background(this.current_state.tileIDs);
               this.edit_rend.DrawEntities_Background(this.current_state.entities);
               if(this.HUD_isVisible)
               {
                  this.EDIT_hud_mc.entity_hud.visible = true;
                  this.EDIT_hud_mc.entity_hud.gotoAndStop(1);
               }
            }
            else
            {
               if(this.ENTITY_type == edat.ETYPE_SWITCH_LOCKED || this.ENTITY_type == edat.ETYPE_SWITCH_TRAP || this.ENTITY_type == edat.ETYPE_EXIT_SWITCH)
               {
                  if(this.current_state.entities.length == 0 || this.current_state.entities[this.current_state.entities.length - 1][edat.EPROP_TYPE] != this.ENTITY_type - 1)
                  {
                     --this.ENTITY_type;
                  }
               }
               _loc37_ = false;
               _loc38_ = false;
               if(this.ENTITY_type != edat.ETYPE_LAUNCHPAD)
               {
                  this.ENTITY_dir = (this.ENTITY_dir + this.ENTITY_dir % 2) % 8;
               }
               if(this.ENTITY_type == edat.ETYPE_LAUNCHPAD || this.ENTITY_type == edat.ETYPE_THWOMP || this.ENTITY_type == edat.ETYPE_ZAP || this.ENTITY_type == edat.ETYPE_CHASER || this.ENTITY_type == edat.ETYPE_CHAINGUN || this.ENTITY_type == edat.ETYPE_LASER || this.ENTITY_type == edat.ETYPE_ONEWAY)
               {
                  _loc37_ = true;
                  if(this.input.IsKeyPressed(65))
                  {
                     this.ENTITY_dir = edat.DIR_L;
                  }
                  else if(this.input.IsKeyPressed(68))
                  {
                     this.ENTITY_dir = edat.DIR_R;
                  }
                  else if(this.input.IsKeyPressed(87))
                  {
                     this.ENTITY_dir = edat.DIR_U;
                  }
                  else if(this.input.IsKeyPressed(83) && !this.input.IsKeyDown(Keyboard.CONTROL))
                  {
                     this.ENTITY_dir = edat.DIR_D;
                  }
               }
               if(this.ENTITY_type == edat.ETYPE_LAUNCHPAD)
               {
                  if(this.input.IsKeyPressed(69))
                  {
                     this.ENTITY_dir = edat.DIR_RU;
                  }
                  else if(this.input.IsKeyPressed(67))
                  {
                     this.ENTITY_dir = edat.DIR_RD;
                  }
                  else if(this.input.IsKeyPressed(90) && !this.input.IsKeyDown(Keyboard.CONTROL))
                  {
                     this.ENTITY_dir = edat.DIR_LD;
                  }
                  else if(this.input.IsKeyPressed(81))
                  {
                     this.ENTITY_dir = edat.DIR_LU;
                  }
               }
               if(this.ENTITY_type == edat.ETYPE_ZAP || this.ENTITY_type == edat.ETYPE_CHASER || this.ENTITY_type == edat.ETYPE_CHAINGUN || this.ENTITY_type == edat.ETYPE_LASER)
               {
                  _loc38_ = true;
                  if(this.input.IsKeyPressed(69))
                  {
                     this.ENTITY_move = edat.MOVE_WANDER_CW;
                  }
                  else if(this.input.IsKeyPressed(67))
                  {
                     this.ENTITY_move = edat.MOVE_SURFACE_CW;
                  }
                  else if(this.input.IsKeyPressed(90) && !this.input.IsKeyDown(Keyboard.CONTROL))
                  {
                     this.ENTITY_move = edat.MOVE_SURFACE_CCW;
                  }
                  else if(this.input.IsKeyPressed(81))
                  {
                     this.ENTITY_move = edat.MOVE_WANDER_CCW;
                  }
               }
               if(this.ENTITY_type == edat.ETYPE_ZAP || this.ENTITY_type == edat.ETYPE_CHASER)
               {
                  if(this.input.IsKeyPressed(88))
                  {
                     if(this.ENTITY_type == edat.ETYPE_ZAP)
                     {
                        this.ENTITY_type = edat.ETYPE_CHASER;
                     }
                     else
                     {
                        this.ENTITY_type = edat.ETYPE_ZAP;
                     }
                  }
               }
               if(this.ENTITY_type == edat.ETYPE_DOOR_LOCKED || this.ENTITY_type == edat.ETYPE_DOOR_TRAP || this.ENTITY_type == edat.ETYPE_DOOR_REGULAR)
               {
                  _loc37_ = true;
                  if(Math.abs(_loc12_.y) > Math.abs(_loc12_.x))
                  {
                     this.ENTITY_dir = edat.DIR_D;
                     _loc9_ = _loc7_ * edat.quantize_steps_per_cell + 2;
                     _loc10_ = _loc8_ * edat.quantize_steps_per_cell;
                     if(_loc12_.y > 0)
                     {
                        _loc10_ += edat.quantize_steps_per_cell;
                     }
                  }
                  else
                  {
                     this.ENTITY_dir = edat.DIR_R;
                     _loc9_ = _loc7_ * edat.quantize_steps_per_cell;
                     _loc10_ = _loc8_ * edat.quantize_steps_per_cell + 2;
                     if(_loc12_.x > 0)
                     {
                        _loc9_ += edat.quantize_steps_per_cell;
                     }
                  }
               }
               else if(this.ENTITY_type == edat.ETYPE_ZAP || this.ENTITY_type == edat.ETYPE_CHASER || this.ENTITY_type == edat.ETYPE_CHAINGUN || this.ENTITY_type == edat.ETYPE_LASER)
               {
                  _loc9_ = _loc7_ * edat.quantize_steps_per_cell + 2;
                  _loc10_ = _loc8_ * edat.quantize_steps_per_cell + 2;
               }
               else if(this.ENTITY_type == edat.ETYPE_FLOORGUARD)
               {
                  if(_loc6_.y < (Number(_loc8_) + 0.5) * edat.cell_size)
                  {
                     _loc10_ = _loc8_ * edat.quantize_steps_per_cell + 1;
                  }
                  else
                  {
                     _loc10_ = _loc8_ * edat.quantize_steps_per_cell + 3;
                  }
                  if(_loc15_)
                  {
                     _loc14_ = 2;
                  }
                  _loc9_ = Math.round(_loc6_.x / (edat.quantize_step_size * _loc14_)) * _loc14_;
               }
               else
               {
                  if(_loc15_)
                  {
                     _loc13_ = 2;
                  }
                  _loc9_ = Math.round(_loc6_.x / (edat.quantize_step_size * _loc13_)) * _loc13_;
                  _loc10_ = Math.round(_loc6_.y / (edat.quantize_step_size * _loc13_)) * _loc13_;
               }
               _loc9_ = Math.max(4,Math.min((edat.num_cols + 1) * edat.quantize_steps_per_cell,_loc9_));
               _loc10_ = Math.max(4,Math.min((edat.num_rows + 1) * edat.quantize_steps_per_cell,_loc10_));
               this.edit_rend.DrawEntity_Preview(this.ENTITY_type,_loc9_,_loc10_,this.ENTITY_dir,this.ENTITY_move,_loc37_,_loc38_);
               if(this.HUD_isVisible)
               {
                  this.EDIT_hud_mc.entity_hud.visible = true;
                  this.EDIT_hud_mc.entity_hud.gotoAndStop("etype_" + this.ENTITY_type);
               }
               if(this.input.IsMousePressed())
               {
                  if(!(this.ENTITY_type == edat.ETYPE_SWITCH_LOCKED || this.ENTITY_type == edat.ETYPE_SWITCH_TRAP || this.ENTITY_type == edat.ETYPE_EXIT_SWITCH))
                  {
                     this.Add_Undo_Frame();
                  }
                  this.Place_Entity(this.ENTITY_type,_loc9_,_loc10_,this.ENTITY_dir,this.ENTITY_move,_loc37_,_loc38_,this.current_state.entities);
                  if(this.ENTITY_type == edat.ETYPE_DOOR_LOCKED || this.ENTITY_type == edat.ETYPE_DOOR_TRAP || this.ENTITY_type == edat.ETYPE_EXIT_DOOR)
                  {
                     ++this.ENTITY_type;
                  }
                  else if(this.ENTITY_type == edat.ETYPE_SWITCH_LOCKED || this.ENTITY_type == edat.ETYPE_SWITCH_TRAP || this.ENTITY_type == edat.ETYPE_EXIT_SWITCH)
                  {
                     --this.ENTITY_type;
                  }
               }
               this.edit_rend.DrawTiles_Background(this.current_state.tileIDs);
               this.edit_rend.DrawEntities_Background(this.current_state.entities);
            }
         }
         if(this.editor_mode == MODE_EDIT_ENTITIES)
         {
            this.EDIT_hud_mc.mode_textbox.text = "editor mode: MODIFY OBJECTS";
            if(this.HUD_isVisible)
            {
               this.EDIT_hud_mc.edit_hud.visible = true;
               this.EDIT_hud_mc.edit_hud.gotoAndStop(1);
            }
            if(this.input.IsKeyDown(Keyboard.SHIFT))
            {
               _loc15_ = !_loc15_;
            }
            _loc39_ = new Vector.<Vector.<uint>>();
            _loc40_ = -1;
            if(this.ENTITY_dragged_id < 0)
            {
               _loc40_ = this.GetIndexOfEntityUnderPoint(_loc6_,this.current_state.entities);
            }
            if(_loc40_ >= 0)
            {
               _loc41_ = this.current_state.entities[_loc40_];
               _loc42_ = _loc41_[edat.EPROP_TYPE];
               this.EDIT_hud_mc.edit_hud.gotoAndStop("etype_" + _loc42_);
               _loc43_ = -1;
               _loc44_ = -1;
               if(_loc42_ == edat.ETYPE_LAUNCHPAD || _loc42_ == edat.ETYPE_THWOMP || _loc42_ == edat.ETYPE_ZAP || _loc42_ == edat.ETYPE_CHASER || _loc42_ == edat.ETYPE_CHAINGUN || _loc42_ == edat.ETYPE_LASER || _loc42_ == edat.ETYPE_ONEWAY)
               {
                  if(this.input.IsKeyPressed(65))
                  {
                     _loc43_ = int(edat.DIR_L);
                  }
                  else if(this.input.IsKeyPressed(68))
                  {
                     _loc43_ = int(edat.DIR_R);
                  }
                  else if(this.input.IsKeyPressed(87))
                  {
                     _loc43_ = int(edat.DIR_U);
                  }
                  else if(this.input.IsKeyPressed(83) && !this.input.IsKeyDown(Keyboard.CONTROL))
                  {
                     _loc43_ = int(edat.DIR_D);
                  }
               }
               if(_loc42_ == edat.ETYPE_LAUNCHPAD)
               {
                  if(this.input.IsKeyPressed(69))
                  {
                     _loc43_ = int(edat.DIR_RU);
                  }
                  else if(this.input.IsKeyPressed(67))
                  {
                     _loc43_ = int(edat.DIR_RD);
                  }
                  else if(this.input.IsKeyPressed(90) && !this.input.IsKeyDown(Keyboard.CONTROL))
                  {
                     _loc43_ = int(edat.DIR_LD);
                  }
                  else if(this.input.IsKeyPressed(81))
                  {
                     _loc43_ = int(edat.DIR_LU);
                  }
               }
               if(_loc42_ == edat.ETYPE_ZAP || _loc42_ == edat.ETYPE_CHASER || _loc42_ == edat.ETYPE_CHAINGUN || _loc42_ == edat.ETYPE_LASER)
               {
                  if(this.input.IsKeyPressed(69))
                  {
                     _loc44_ = int(edat.MOVE_WANDER_CW);
                  }
                  else if(this.input.IsKeyPressed(67))
                  {
                     _loc44_ = int(edat.MOVE_SURFACE_CW);
                  }
                  else if(this.input.IsKeyPressed(90) && !this.input.IsKeyDown(Keyboard.CONTROL))
                  {
                     _loc44_ = int(edat.MOVE_SURFACE_CCW);
                  }
                  else if(this.input.IsKeyPressed(81))
                  {
                     _loc44_ = int(edat.MOVE_WANDER_CCW);
                  }
               }
               if(_loc43_ >= 0)
               {
                  if(_loc41_[edat.EPROP_DIR] != _loc43_)
                  {
                     this.Add_Undo_Frame();
                     _loc41_[edat.EPROP_DIR] = _loc43_;
                  }
               }
               if(_loc44_ >= 0)
               {
                  if(_loc41_[edat.EPROP_MOVE] != _loc44_)
                  {
                     this.Add_Undo_Frame();
                     _loc41_[edat.EPROP_MOVE] = _loc44_;
                  }
               }
               if(_loc42_ == edat.ETYPE_ZAP || _loc42_ == edat.ETYPE_CHASER)
               {
                  if(this.input.IsKeyPressed(88))
                  {
                     this.Add_Undo_Frame();
                     if(_loc42_ == edat.ETYPE_ZAP)
                     {
                        _loc41_[edat.EPROP_TYPE] = edat.ETYPE_CHASER;
                     }
                     else
                     {
                        _loc41_[edat.EPROP_TYPE] = edat.ETYPE_ZAP;
                     }
                  }
               }
               if(this.input.IsKeyPressed(EDIT_key_delete_entities))
               {
                  this.Add_Undo_Frame();
                  this.Delete_Single_Entity(_loc40_,this.current_state.entities);
                  _loc40_ = -1;
               }
               else if(this.input.IsMousePressed())
               {
                  this.Add_Undo_Frame();
                  this.ENTITY_dragged_id = _loc40_;
               }
               else if(this.input.IsKeyPressed(70))
               {
                  if(_loc2_ == MODE_EDIT_ENTITIES)
                  {
                     this.editor_mode = MODE_PLACE_ENTITIES;
                     this.ENTITY_type = _loc41_[edat.EPROP_TYPE];
                     if(this.ENTITY_type == edat.ETYPE_EXIT_SWITCH || this.ENTITY_type == edat.ETYPE_SWITCH_LOCKED || this.ENTITY_type == edat.ETYPE_SWITCH_TRAP)
                     {
                        --this.ENTITY_type;
                     }
                     if(_loc41_.length > 3)
                     {
                        this.ENTITY_dir = _loc41_[edat.EPROP_DIR];
                        if(_loc41_.length > 4)
                        {
                           this.ENTITY_move = _loc41_[edat.EPROP_MOVE];
                        }
                     }
                  }
               }
               _loc39_.push(_loc41_);
            }
            if(!this.input.IsMouseDown())
            {
               this.ENTITY_dragged_id = -1;
            }
            if(this.ENTITY_dragged_id >= 0)
            {
               this.EDIT_hud_mc.edit_hud.gotoAndStop(2);
               _loc45_ = this.current_state.entities[this.ENTITY_dragged_id];
               _loc46_ = _loc45_[edat.EPROP_TYPE];
               if(_loc46_ == edat.ETYPE_DOOR_LOCKED || _loc46_ == edat.ETYPE_DOOR_TRAP || _loc46_ == edat.ETYPE_DOOR_REGULAR)
               {
                  if(Math.abs(_loc12_.y) > Math.abs(_loc12_.x))
                  {
                     _loc45_[edat.EPROP_DIR] = edat.DIR_D;
                     _loc9_ = _loc7_ * edat.quantize_steps_per_cell + 2;
                     _loc10_ = _loc8_ * edat.quantize_steps_per_cell;
                     if(_loc12_.y > 0)
                     {
                        _loc10_ += edat.quantize_steps_per_cell;
                     }
                  }
                  else
                  {
                     _loc45_[edat.EPROP_DIR] = edat.DIR_R;
                     _loc9_ = _loc7_ * edat.quantize_steps_per_cell;
                     _loc10_ = _loc8_ * edat.quantize_steps_per_cell + 2;
                     if(_loc12_.x > 0)
                     {
                        _loc9_ += edat.quantize_steps_per_cell;
                     }
                  }
               }
               else if(_loc46_ == edat.ETYPE_ZAP || _loc46_ == edat.ETYPE_CHASER || _loc46_ == edat.ETYPE_CHAINGUN || _loc46_ == edat.ETYPE_LASER)
               {
                  _loc9_ = _loc7_ * edat.quantize_steps_per_cell + 2;
                  _loc10_ = _loc8_ * edat.quantize_steps_per_cell + 2;
               }
               else if(_loc46_ == edat.ETYPE_FLOORGUARD)
               {
                  if(_loc6_.y < (Number(_loc8_) + 0.5) * edat.cell_size)
                  {
                     _loc10_ = _loc8_ * edat.quantize_steps_per_cell + 1;
                  }
                  else
                  {
                     _loc10_ = _loc8_ * edat.quantize_steps_per_cell + 3;
                  }
                  if(_loc15_)
                  {
                     _loc14_ = 2;
                  }
                  _loc9_ = Math.round(_loc6_.x / (edat.quantize_step_size * _loc14_)) * _loc14_;
               }
               else
               {
                  if(_loc15_)
                  {
                     _loc13_ = 2;
                  }
                  _loc9_ = Math.round(_loc6_.x / (edat.quantize_step_size * _loc13_)) * _loc13_;
                  _loc10_ = Math.round(_loc6_.y / (edat.quantize_step_size * _loc13_)) * _loc13_;
               }
               _loc45_[edat.EPROP_X] = Math.max(4,Math.min((edat.num_cols + 1) * edat.quantize_steps_per_cell,_loc9_));
               _loc45_[edat.EPROP_Y] = Math.max(4,Math.min((edat.num_rows + 1) * edat.quantize_steps_per_cell,_loc10_));
               _loc39_.push(_loc45_);
            }
            this.edit_rend.DrawTiles_Background(this.current_state.tileIDs);
            this.edit_rend.DrawEntities_Background(this.current_state.entities);
            this.edit_rend.DrawEntities_Selected(_loc39_,0,0);
         }
         if(this.editor_mode == MODE_EDIT_REGION)
         {
            this.EDIT_hud_mc.mode_textbox.text = "editor mode: MODIFY REGION";
            if(this.HUD_isVisible)
            {
               this.EDIT_hud_mc.region_hud.visible = true;
            }
            if(this.EDIT_mode == EDITMODE_IDLE)
            {
               this.EDIT_hud_mc.region_hud.gotoAndStop("idle");
               if(this.input.IsMousePressed())
               {
                  this.EDIT_start_tile.x = _loc7_;
                  this.EDIT_start_tile.y = _loc8_;
                  this.EDIT_mode = EDITMODE_DEFINING_REGION;
               }
            }
            if(this.EDIT_mode == EDITMODE_DEFINING_REGION)
            {
               this.EDIT_hud_mc.region_hud.gotoAndStop("selecting");
               this.EDIT_end_tile.x = _loc7_;
               this.EDIT_end_tile.y = _loc8_;
               this.EDIT_min_tile.x = Math.min(this.EDIT_start_tile.x,this.EDIT_end_tile.x);
               this.EDIT_min_tile.y = Math.min(this.EDIT_start_tile.y,this.EDIT_end_tile.y);
               this.EDIT_max_tile.x = Math.max(this.EDIT_start_tile.x,this.EDIT_end_tile.x);
               this.EDIT_max_tile.y = Math.max(this.EDIT_start_tile.y,this.EDIT_end_tile.y);
               if(this.input.IsMouseReleased())
               {
                  this.EDIT_mode = EDITMODE_REGION_DEFINED;
               }
            }
            if(this.EDIT_mode == EDITMODE_REGION_DEFINED)
            {
               if(this.input.IsKeyDown(Keyboard.SHIFT))
               {
                  this.EDIT_hud_mc.region_hud.gotoAndStop("selected_shift");
               }
               else
               {
                  this.EDIT_hud_mc.region_hud.gotoAndStop("selected");
               }
               if(this.input.IsMousePressed())
               {
                  this.EDIT_start_tile.x = _loc7_;
                  this.EDIT_start_tile.y = _loc8_;
                  this.EDIT_mode = EDITMODE_DEFINING_REGION;
               }
               else if(this.input.IsKeyPressed(EDIT_key_delete_entities))
               {
                  this.Add_Undo_Frame();
                  _loc47_ = this.GetOrderedEntityIDsInRegion(this.EDIT_is_select_entities_on_border,this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.entities);
                  this.Delete_Entities(_loc47_,this.current_state.entities);
               }
               else if(this.input.IsKeyPressed(EDIT_key_clear_tiles))
               {
                  this.Add_Undo_Frame();
                  _loc48_ = this.Copy_Tiles(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.tileIDs);
                  _loc48_ = this.Transform_Tile_Buffer(XFORMTYPE_CLEAR,_loc48_);
                  this.Paste_Tiles(true,this.EDIT_min_tile.x,this.EDIT_min_tile.y,_loc48_,this.current_state.tileIDs);
               }
               else if(this.input.IsKeyPressed(EDIT_key_fill_tiles))
               {
                  this.Add_Undo_Frame();
                  _loc49_ = this.Copy_Tiles(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.tileIDs);
                  _loc49_ = this.Transform_Tile_Buffer(XFORMTYPE_FILL,_loc49_);
                  this.Paste_Tiles(true,this.EDIT_min_tile.x,this.EDIT_min_tile.y,_loc49_,this.current_state.tileIDs);
               }
               else if(this.input.IsKeyPressed(EDIT_key_invert_tiles))
               {
                  this.Add_Undo_Frame();
                  _loc50_ = this.Copy_Tiles(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.tileIDs);
                  _loc50_ = this.Transform_Tile_Buffer(XFORMTYPE_INVERT,_loc50_);
                  this.Paste_Tiles(true,this.EDIT_min_tile.x,this.EDIT_min_tile.y,_loc50_,this.current_state.tileIDs);
               }
               else if(this.input.IsKeyPressed(EDIT_key_mirror_H))
               {
                  this.Add_Undo_Frame();
                  _loc51_ = this.Copy_Tiles(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.tileIDs);
                  _loc52_ = this.Cut_Entities(this.EDIT_is_select_entities_on_border,this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.entities);
                  this.Transform_Entity_Buffer(XFORMTYPE_MIRROR_H,_loc51_.stride,_loc51_.GetNumRows(),_loc52_);
                  _loc51_ = this.Transform_Tile_Buffer(XFORMTYPE_MIRROR_H,_loc51_);
                  this.Paste_Entities(this.EDIT_min_tile.x,this.EDIT_min_tile.y,_loc52_,this.current_state.entities);
                  this.Paste_Tiles(true,this.EDIT_min_tile.x,this.EDIT_min_tile.y,_loc51_,this.current_state.tileIDs);
                  this.HELPER_Dispose_Entity_Buffer(_loc52_,this.current_state.entities);
               }
               else if(this.input.IsKeyPressed(EDIT_key_mirror_V) && !this.input.IsKeyDown(Keyboard.CONTROL))
               {
                  this.Add_Undo_Frame();
                  _loc53_ = this.Copy_Tiles(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.tileIDs);
                  _loc54_ = this.Cut_Entities(this.EDIT_is_select_entities_on_border,this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.entities);
                  this.Transform_Entity_Buffer(XFORMTYPE_MIRROR_V,_loc53_.stride,_loc53_.GetNumRows(),_loc54_);
                  _loc53_ = this.Transform_Tile_Buffer(XFORMTYPE_MIRROR_V,_loc53_);
                  this.Paste_Entities(this.EDIT_min_tile.x,this.EDIT_min_tile.y,_loc54_,this.current_state.entities);
                  this.Paste_Tiles(true,this.EDIT_min_tile.x,this.EDIT_min_tile.y,_loc53_,this.current_state.tileIDs);
                  this.HELPER_Dispose_Entity_Buffer(_loc54_,this.current_state.entities);
               }
               else if(this.input.IsKeyPressed(EDIT_key_rotate_CCW))
               {
                  this.Add_Undo_Frame();
                  this.EDIT_tile_buffer = this.Copy_Tiles(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.tileIDs);
                  this.EDIT_entity_buffer = this.Cut_Entities(this.EDIT_is_select_entities_on_border,this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.entities);
                  this.Paste_Entities(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_entity_buffer,this.current_state.entities);
                  this.EDIT_mode = EDITMODE_EDITING_BUFFER;
               }
               else if(this.input.IsKeyPressed(EDIT_key_rotate_CW))
               {
                  this.Add_Undo_Frame();
                  this.EDIT_tile_buffer = this.Copy_Tiles(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.tileIDs);
                  this.EDIT_entity_buffer = this.Cut_Entities(this.EDIT_is_select_entities_on_border,this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.entities);
                  this.Paste_Entities(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_entity_buffer,this.current_state.entities);
                  this.EDIT_mode = EDITMODE_EDITING_BUFFER;
               }
               else if(this.input.IsKeyPressed(EDIT_key_copy_region))
               {
                  this.EDIT_tile_buffer = this.Copy_Tiles(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.tileIDs);
                  this.EDIT_entity_buffer = this.Cut_Entities(this.EDIT_is_select_entities_on_border,this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.entities);
                  this.Paste_Entities(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_entity_buffer,this.current_state.entities);
                  this.EDIT_mode = EDITMODE_EDITING_BUFFER;
               }
               else if(this.input.IsKeyPressed(EDIT_key_cut_region))
               {
                  this.Add_Undo_Frame();
                  this.EDIT_tile_buffer = this.Copy_Tiles(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.tileIDs);
                  this.EDIT_entity_buffer = this.Cut_Entities(this.EDIT_is_select_entities_on_border,this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.entities);
                  _loc55_ = this.Copy_Tiles(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.tileIDs);
                  if(this.input.IsKeyDown(Keyboard.SHIFT))
                  {
                     _loc55_ = this.Transform_Tile_Buffer(XFORMTYPE_FILL,_loc55_);
                  }
                  else
                  {
                     _loc55_ = this.Transform_Tile_Buffer(XFORMTYPE_CLEAR,_loc55_);
                  }
                  this.Paste_Tiles(true,this.EDIT_min_tile.x,this.EDIT_min_tile.y,_loc55_,this.current_state.tileIDs);
                  this.EDIT_mode = EDITMODE_EDITING_BUFFER;
               }
               else if(this.input.IsKeyPressed(EDIT_key_move))
               {
                  this.Add_Undo_Frame();
                  this.EDIT_tile_buffer = this.Copy_Tiles(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.tileIDs);
                  this.EDIT_entity_buffer = this.Cut_Entities(this.EDIT_is_select_entities_on_border,this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.entities);
                  _loc56_ = this.Copy_Tiles(this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,this.current_state.tileIDs);
                  if(this.input.IsKeyDown(Keyboard.SHIFT))
                  {
                     _loc56_ = this.Transform_Tile_Buffer(XFORMTYPE_FILL,_loc56_);
                  }
                  else
                  {
                     _loc56_ = this.Transform_Tile_Buffer(XFORMTYPE_CLEAR,_loc56_);
                  }
                  this.Paste_Tiles(true,this.EDIT_min_tile.x,this.EDIT_min_tile.y,_loc56_,this.current_state.tileIDs);
                  this.EDIT_mode = EDITMODE_DRAGGING;
               }
            }
            if(this.EDIT_mode == EDITMODE_EDITING_BUFFER || this.EDIT_mode == EDITMODE_DRAGGING)
            {
               if(this.input.IsKeyDown(Keyboard.SHIFT))
               {
                  this.EDIT_hud_mc.region_hud.gotoAndStop("editing_shift");
               }
               else
               {
                  this.EDIT_hud_mc.region_hud.gotoAndStop("editing");
               }
               if(this.EDIT_mode == EDITMODE_DRAGGING)
               {
                  this.EDIT_hud_mc.region_hud.gotoAndStop("moving");
               }
               else if(this.input.IsKeyPressed(EDIT_key_delete_entities))
               {
                  this.HELPER_Dispose_Entity_Buffer(this.EDIT_entity_buffer,this.current_state.entities);
                  this.EDIT_entity_buffer = new EntityBuffer();
               }
               else if(this.input.IsKeyPressed(EDIT_key_clear_tiles))
               {
                  this.EDIT_tile_buffer = this.Transform_Tile_Buffer(XFORMTYPE_CLEAR,this.EDIT_tile_buffer);
               }
               else if(this.input.IsKeyPressed(EDIT_key_fill_tiles))
               {
                  this.EDIT_tile_buffer = this.Transform_Tile_Buffer(XFORMTYPE_FILL,this.EDIT_tile_buffer);
               }
               else if(this.input.IsKeyPressed(EDIT_key_invert_tiles))
               {
                  this.EDIT_tile_buffer = this.Transform_Tile_Buffer(XFORMTYPE_INVERT,this.EDIT_tile_buffer);
               }
               else if(this.input.IsKeyPressed(EDIT_key_mirror_H))
               {
                  this.Transform_Entity_Buffer(XFORMTYPE_MIRROR_H,this.EDIT_tile_buffer.stride,this.EDIT_tile_buffer.GetNumRows(),this.EDIT_entity_buffer);
                  this.EDIT_tile_buffer = this.Transform_Tile_Buffer(XFORMTYPE_MIRROR_H,this.EDIT_tile_buffer);
               }
               else if(this.input.IsKeyPressed(EDIT_key_mirror_V) && !this.input.IsKeyDown(Keyboard.CONTROL))
               {
                  this.Transform_Entity_Buffer(XFORMTYPE_MIRROR_V,this.EDIT_tile_buffer.stride,this.EDIT_tile_buffer.GetNumRows(),this.EDIT_entity_buffer);
                  this.EDIT_tile_buffer = this.Transform_Tile_Buffer(XFORMTYPE_MIRROR_V,this.EDIT_tile_buffer);
               }
               else if(this.input.IsKeyPressed(EDIT_key_rotate_CCW))
               {
                  this.Transform_Entity_Buffer(XFORMTYPE_ROTATE_CCW,this.EDIT_tile_buffer.stride,this.EDIT_tile_buffer.GetNumRows(),this.EDIT_entity_buffer);
                  this.EDIT_tile_buffer = this.Transform_Tile_Buffer(XFORMTYPE_ROTATE_CCW,this.EDIT_tile_buffer);
               }
               else if(this.input.IsKeyPressed(EDIT_key_rotate_CW))
               {
                  this.Transform_Entity_Buffer(XFORMTYPE_ROTATE_CW,this.EDIT_tile_buffer.stride,this.EDIT_tile_buffer.GetNumRows(),this.EDIT_entity_buffer);
                  this.EDIT_tile_buffer = this.Transform_Tile_Buffer(XFORMTYPE_ROTATE_CW,this.EDIT_tile_buffer);
               }
               _loc57_ = this.EDIT_tile_buffer.stride;
               _loc58_ = this.EDIT_tile_buffer.GetNumRows();
               _loc59_ = Math.round((_loc6_.x - edat.cell_size * (Number(_loc57_) / 2)) / edat.cell_size);
               _loc60_ = Math.round((_loc6_.y - edat.cell_size * (Number(_loc58_) / 2)) / edat.cell_size);
               if(_loc57_ <= edat.num_cols)
               {
                  if(_loc59_ < 1)
                  {
                     _loc59_ = 1;
                  }
                  else if(_loc59_ + (_loc57_ - 1) > edat.num_cols)
                  {
                     _loc59_ = edat.num_cols - (_loc57_ - 1);
                  }
               }
               else
               {
                  trace("WARNING! editor found a too-wide buffer: " + _loc57_ + " .. " + edat.num_cols);
               }
               if(_loc58_ <= edat.num_rows)
               {
                  if(_loc60_ < 1)
                  {
                     _loc60_ = 1;
                  }
                  else if(_loc60_ + (_loc58_ - 1) > edat.num_rows)
                  {
                     _loc60_ = edat.num_rows - (_loc58_ - 1);
                  }
               }
               else
               {
                  _loc61_ = (Number(edat.num_rows) + 2) / 2 * edat.cell_size;
                  if(_loc6_.y > _loc61_)
                  {
                     _loc60_ = 1;
                  }
                  else
                  {
                     _loc60_ = edat.num_rows - (_loc58_ - 1);
                  }
               }
               if(this.EDIT_mode == EDITMODE_DRAGGING)
               {
                  if(!this.input.IsKeyDown(EDIT_key_move))
                  {
                     _loc62_ = this.GetOrderedEntityIDsInRegion(false,_loc59_,_loc60_,_loc59_ + (_loc57_ - 1),_loc60_ + (_loc58_ - 1),this.current_state.entities);
                     this.Delete_Entities(_loc62_,this.current_state.entities);
                     this.Paste_Entities(_loc59_,_loc60_,this.EDIT_entity_buffer,this.current_state.entities);
                     this.Paste_Tiles(this.EDIT_is_empty_tiles_opaque,_loc59_,_loc60_,this.EDIT_tile_buffer,this.current_state.tileIDs);
                     this.EDIT_tile_buffer = null;
                     this.HELPER_Dispose_Entity_Buffer(this.EDIT_entity_buffer,this.current_state.entities);
                     this.EDIT_entity_buffer = null;
                     this.EDIT_min_tile.x = _loc59_;
                     this.EDIT_min_tile.y = _loc60_;
                     this.EDIT_max_tile.x = _loc59_ + (_loc57_ - 1);
                     this.EDIT_max_tile.y = _loc60_ + (_loc58_ - 1);
                     this.EDIT_mode = EDITMODE_REGION_DEFINED;
                  }
               }
               else if(this.input.IsKeyPressed(EDIT_key_paste_region) || this.input.IsMousePressed())
               {
                  if(this.EDIT_entity_buffer.unmatchedCount == 0)
                  {
                     this.Add_Undo_Frame();
                  }
                  _loc63_ = this.GetOrderedEntityIDsInRegion(false,_loc59_,_loc60_,_loc59_ + (_loc57_ - 1),_loc60_ + (_loc58_ - 1),this.current_state.entities);
                  this.Delete_Entities(_loc63_,this.current_state.entities);
                  this.Paste_Entities(_loc59_,_loc60_,this.EDIT_entity_buffer,this.current_state.entities);
                  this.Paste_Tiles(this.EDIT_is_empty_tiles_opaque,_loc59_,_loc60_,this.EDIT_tile_buffer,this.current_state.tileIDs);
                  if(this.input.IsKeyDown(Keyboard.SHIFT))
                  {
                     this.EDIT_tile_buffer = null;
                     this.HELPER_Dispose_Entity_Buffer(this.EDIT_entity_buffer,this.current_state.entities);
                     this.EDIT_entity_buffer = null;
                     this.EDIT_min_tile.x = _loc59_;
                     this.EDIT_min_tile.y = _loc60_;
                     this.EDIT_max_tile.x = _loc59_ + (_loc57_ - 1);
                     this.EDIT_max_tile.y = _loc60_ + (_loc58_ - 1);
                     this.EDIT_mode = EDITMODE_REGION_DEFINED;
                  }
               }
            }
            if(this.EDIT_mode == EDITMODE_IDLE)
            {
               this.edit_rend.DrawCell(_loc7_,_loc8_,edat.cell_size);
               this.edit_rend.DrawTiles_Background(this.current_state.tileIDs);
               this.edit_rend.DrawEntities_Background(this.current_state.entities);
            }
            else if(this.EDIT_mode == EDITMODE_DEFINING_REGION || this.EDIT_mode == EDITMODE_REGION_DEFINED)
            {
               _loc64_ = -2;
               if(this.EDIT_is_select_entities_on_border)
               {
                  _loc64_ = 2;
               }
               this.rend.SetStyle(1,16711935,100);
               this.rend.DrawAABB(this.EDIT_min_tile.x * edat.cell_size - _loc64_,(this.EDIT_max_tile.x + 1) * edat.cell_size + _loc64_,this.EDIT_min_tile.y * edat.cell_size - _loc64_,(this.EDIT_max_tile.y + 1) * edat.cell_size + _loc64_);
               this.edit_rend.DrawTiles_Background(this.current_state.tileIDs);
               this.edit_rend.DrawEntities_Background(this.current_state.entities);
               _loc65_ = this.current_state.Clone();
               _loc66_ = this.GetOrderedEntityIDsInRegion(this.EDIT_is_select_entities_on_border,this.EDIT_min_tile.x,this.EDIT_min_tile.y,this.EDIT_max_tile.x,this.EDIT_max_tile.y,_loc65_.entities);
               _loc67_ = new Vector.<Vector.<uint>>();
               _loc68_ = 0;
               while(_loc68_ < _loc66_.length)
               {
                  _loc67_.push(this.current_state.entities[_loc66_[_loc68_]]);
                  _loc68_++;
               }
               this.edit_rend.DrawEntities_Selected(_loc67_,0,0);
            }
            else if(this.EDIT_mode == EDITMODE_EDITING_BUFFER || this.EDIT_mode == EDITMODE_DRAGGING)
            {
               this.rend.SetStyle(1,16777215,100);
               this.rend.DrawAABB(_loc59_ * edat.cell_size,(_loc59_ + _loc57_) * edat.cell_size,_loc60_ * edat.cell_size,(_loc60_ + _loc58_) * edat.cell_size);
               this.edit_rend.DrawTiles_Background(this.current_state.tileIDs);
               this.edit_rend.DrawTiles_Selected(this.EDIT_tile_buffer,_loc59_,_loc60_,this.EDIT_is_empty_tiles_opaque);
               this.edit_rend.DrawEntities_Selected(this.EDIT_entity_buffer.entities,_loc59_,_loc60_);
               _loc69_ = this.current_state.Clone();
               _loc70_ = this.GetOrderedEntityIDsInRegion(false,_loc59_,_loc60_,_loc59_ + (_loc57_ - 1),_loc60_ + (_loc58_ - 1),_loc69_.entities);
               this.Delete_Entities(_loc70_,_loc69_.entities);
               this.edit_rend.DrawEntities_Background(_loc69_.entities);
            }
         }
         var _loc16_:Boolean = false;
         if(this.DRAW_is_snap_grid && (this.editor_mode == MODE_EDIT_ENTITIES || this.editor_mode == MODE_PLACE_ENTITIES))
         {
            _loc71_ = -1;
            if(this.editor_mode == MODE_PLACE_ENTITIES)
            {
               _loc71_ = int(this.ENTITY_type);
            }
            else if(this.ENTITY_dragged_id >= 0)
            {
               _loc71_ = int(this.current_state.entities[this.ENTITY_dragged_id][edat.EPROP_TYPE]);
            }
            else if(_loc40_ >= 0)
            {
               _loc71_ = int(this.current_state.entities[_loc40_][edat.EPROP_TYPE]);
            }
            if(_loc71_ >= 0)
            {
               _loc72_ = 4;
               _loc73_ = 4;
               if(_loc15_)
               {
                  _loc72_ = 2;
                  _loc73_ = 2;
               }
               if(_loc71_ == edat.ETYPE_DOOR_LOCKED || _loc71_ == edat.ETYPE_DOOR_REGULAR || _loc71_ == edat.ETYPE_DOOR_TRAP || _loc71_ == edat.ETYPE_CHAINGUN || _loc71_ == edat.ETYPE_CHASER || _loc71_ == edat.ETYPE_LASER || _loc71_ == edat.ETYPE_ZAP)
               {
                  if(this.DRAW_grid_style == 0)
                  {
                     this.edit_rend.DrawSnapGrid(edat.num_cols,edat.num_rows,edat.cell_size,1,1,false);
                  }
               }
               else
               {
                  _loc16_ = true;
                  if(_loc71_ == edat.ETYPE_FLOORGUARD)
                  {
                     this.edit_rend.DrawSnapGrid(edat.num_cols,edat.num_rows,edat.cell_size,_loc72_,2,true);
                  }
                  else
                  {
                     this.edit_rend.DrawSnapGrid(edat.num_cols,edat.num_rows,edat.cell_size,_loc72_,_loc73_,false);
                  }
               }
            }
         }
         if(this.DRAW_grid_style != 0)
         {
            if(_loc16_ && this.DRAW_grid_style == 3)
            {
               this.edit_rend.DrawGrid(edat.num_cols,edat.num_rows,edat.cell_size,1);
            }
            else
            {
               this.edit_rend.DrawGrid(edat.num_cols,edat.num_rows,edat.cell_size,this.DRAW_grid_style);
            }
         }
         if(this.editor_mode == MODE_PLACE_ENTITIES)
         {
            if(this.ENTITY_type == edat.ETYPE_EXIT_SWITCH || this.ENTITY_type == edat.ETYPE_SWITCH_LOCKED || this.ENTITY_type == edat.ETYPE_SWITCH_TRAP)
            {
               _loc74_ = this.current_state.entities[this.current_state.entities.length - 1];
               this.edit_rend.DrawPair(_loc9_ * edat.quantize_step_size,_loc10_ * edat.quantize_step_size,_loc74_[edat.EPROP_X] * edat.quantize_step_size,_loc74_[edat.EPROP_Y] * edat.quantize_step_size);
            }
         }
         var _loc17_:int = 0;
         while(_loc17_ < this.current_state.entities.length)
         {
            _loc75_ = this.current_state.entities[_loc17_][edat.EPROP_TYPE];
            if(_loc75_ == edat.ETYPE_EXIT_DOOR || _loc75_ == edat.ETYPE_DOOR_LOCKED || _loc75_ == edat.ETYPE_DOOR_TRAP)
            {
               if(_loc17_ != this.current_state.entities.length - 1)
               {
                  if(this.current_state.entities[_loc17_ + 1][edat.EPROP_TYPE] != edat.ETYPE_NULLFLAG)
                  {
                     _loc76_ = this.current_state.entities[_loc17_][edat.EPROP_X] * edat.quantize_step_size;
                     _loc77_ = this.current_state.entities[_loc17_][edat.EPROP_Y] * edat.quantize_step_size;
                     _loc78_ = this.current_state.entities[_loc17_ + 1][edat.EPROP_X] * edat.quantize_step_size;
                     _loc79_ = this.current_state.entities[_loc17_ + 1][edat.EPROP_Y] * edat.quantize_step_size;
                     this.edit_rend.DrawPair(_loc76_,_loc77_,_loc78_,_loc79_);
                  }
               }
            }
            _loc17_++;
         }
         if((this.EDIT_mode == EDITMODE_EDITING_BUFFER || this.EDIT_mode == EDITMODE_DRAGGING) && this.EDIT_entity_buffer != null)
         {
            _loc80_ = _loc59_ * edat.cell_size;
            _loc81_ = _loc60_ * edat.cell_size;
            _loc82_ = 0;
            while(_loc82_ < this.EDIT_entity_buffer.entities.length - 1 - this.EDIT_entity_buffer.unmatchedCount)
            {
               _loc84_ = this.EDIT_entity_buffer.entities[_loc82_][edat.EPROP_TYPE];
               if(_loc84_ == edat.ETYPE_EXIT_DOOR || _loc84_ == edat.ETYPE_DOOR_LOCKED || _loc84_ == edat.ETYPE_DOOR_TRAP)
               {
                  if(_loc82_ != this.EDIT_entity_buffer.entities.length - 1 - this.EDIT_entity_buffer.unmatchedCount)
                  {
                     _loc85_ = _loc80_ + this.EDIT_entity_buffer.entities[_loc82_][edat.EPROP_X] * edat.quantize_step_size;
                     _loc86_ = _loc81_ + this.EDIT_entity_buffer.entities[_loc82_][edat.EPROP_Y] * edat.quantize_step_size;
                     _loc87_ = _loc80_ + this.EDIT_entity_buffer.entities[_loc82_ + 1][edat.EPROP_X] * edat.quantize_step_size;
                     _loc88_ = _loc81_ + this.EDIT_entity_buffer.entities[_loc82_ + 1][edat.EPROP_Y] * edat.quantize_step_size;
                     this.edit_rend.DrawPair(_loc85_,_loc86_,_loc87_,_loc88_);
                  }
               }
               _loc82_++;
            }
            _loc83_ = 0;
            while(_loc83_ < this.EDIT_entity_buffer.unmatchedCount)
            {
               _loc89_ = this.EDIT_entity_buffer.entities.length - this.EDIT_entity_buffer.unmatchedCount + _loc83_;
               _loc90_ = this.EDIT_entity_buffer.entities[_loc89_][edat.EPROP_TYPE];
               _loc91_ = 0;
               _loc92_ = 0;
               while(_loc92_ < this.current_state.entities.length)
               {
                  if(this.current_state.entities[_loc92_][edat.EPROP_TYPE] == edat.ETYPE_NULLFLAG)
                  {
                     if(_loc91_ == _loc83_)
                     {
                        if(_loc90_ == edat.ETYPE_EXIT_DOOR || _loc90_ == edat.ETYPE_DOOR_LOCKED || _loc90_ == edat.ETYPE_DOOR_TRAP)
                        {
                           _loc92_++;
                        }
                        else
                        {
                           _loc92_--;
                        }
                        break;
                     }
                     _loc91_++;
                  }
                  _loc92_++;
               }
               _loc93_ = _loc80_ + this.EDIT_entity_buffer.entities[_loc89_][edat.EPROP_X] * edat.quantize_step_size;
               _loc94_ = _loc81_ + this.EDIT_entity_buffer.entities[_loc89_][edat.EPROP_Y] * edat.quantize_step_size;
               _loc95_ = this.current_state.entities[_loc92_][edat.EPROP_X] * edat.quantize_step_size;
               _loc96_ = this.current_state.entities[_loc92_][edat.EPROP_Y] * edat.quantize_step_size;
               this.edit_rend.DrawPair(_loc93_,_loc94_,_loc95_,_loc96_);
               _loc83_++;
            }
         }
         this.HELPER_ClearAllCallbackFlags();
      }
      
      private function ButtonCallback_EditMenu(param1:Event) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < 18)
         {
            if(param1.target.name == "button_e" + _loc2_)
            {
               this.editor_mode = MODE_PLACE_ENTITIES;
               this.ENTITY_type = ENTITY_typelist[_loc2_];
               this.button_hotkey = true;
            }
            _loc2_++;
         }
         var _loc3_:int = 0;
         while(_loc3_ < 8)
         {
            if(param1.target.name == "button_t" + _loc3_)
            {
               this.editor_mode = MODE_PLACE_TILES;
               this.TILE_type = _loc3_;
               this.button_hotkey = true;
            }
            _loc3_++;
         }
         if(param1.target.name == "button_entities")
         {
            this.button_edit_entities = true;
         }
         if(param1.target.name == "button_undo")
         {
            this.button_undo = true;
         }
         if(param1.target.name == "button_redo")
         {
            this.button_redo = true;
         }
         if(param1.target.name == "button_play")
         {
            this.button_game_toggle = true;
            trace("PLAY!");
         }
         if(param1.target.name == "button_gridstyle")
         {
            this.button_gridstyle = true;
         }
         if(param1.target.name == "button_border")
         {
            this.button_border = true;
         }
         if(param1.target.name == "button_opaque")
         {
            this.button_opaque = true;
         }
         if(param1.target.name == "button_snapgrid")
         {
            this.button_snapgrid = true;
         }
         if(param1.target.name == "button_snapsize")
         {
            this.button_snapsize = true;
         }
      }
      
      private function ButtonCallback_Save(param1:Event) : void
      {
         this.button_save = true;
      }
      
      private function ButtonCallback_Quit(param1:Event) : void
      {
         this.button_quit = true;
      }
      
      private function ButtonCallback_Resume(param1:Event) : void
      {
         this.button_resume = true;
      }
      
      private function ButtonCallback_Confirm_Quit(param1:Event) : void
      {
         this.button_confirm_quit = true;
      }
      
      private function ButtonCallback_Confirm_SaveAndQuit(param1:Event) : void
      {
         this.button_confirm_saveandquit = true;
      }
      
      private function ButtonCallback_Confirm_Cancel(param1:Event) : void
      {
         this.button_confirm_cancel = true;
      }
      
      private function ButtonCallback_Game_Toggle(param1:Event) : void
      {
         this.button_game_toggle = true;
      }
      
      private function ButtonCallback_Game_Reset(param1:Event) : void
      {
         this.button_game_reset = true;
      }
      
      private function ButtonCallback_Game_Pause(param1:Event) : void
      {
         this.button_game_pause = true;
      }
      
      private function ButtonCallback_Undo(param1:Event) : void
      {
         this.button_undo = true;
      }
      
      private function ButtonCallback_Redo(param1:Event) : void
      {
         this.button_redo = true;
      }
      
      private function HELPER_ClearAllCallbackFlags() : void
      {
         this.button_save = false;
         this.button_quit = false;
         this.button_resume = false;
         this.button_confirm_quit = false;
         this.button_confirm_saveandquit = false;
         this.button_confirm_cancel = false;
         this.button_hotkey = false;
         this.button_edit_entities = false;
         this.button_gridstyle = false;
         this.button_snapgrid = false;
         this.button_snapsize = false;
         this.button_border = false;
         this.button_opaque = false;
         this.button_undo = false;
         this.button_redo = false;
         this.button_game_toggle = false;
         this.button_game_pause = false;
         this.button_game_reset = false;
      }
      
      private function HELPER_Tick_Sim() : void
      {
         var _loc1_:vec2 = this.input.GetMousePos();
         var _loc2_:vec2 = this.input.GetMouseVel();
         if(this.input.IsKeyDown(88))
         {
            this.sim.DEBUG_SetPlayerPosVel(_loc1_,new vec2());
         }
         if(this.input.IsKeyPressed(Keyboard.ENTER))
         {
            this.sim.DEBUG_ToggleRagdoll(_loc1_);
         }
         if(this.input.IsKeyPressed(Keyboard.SPACE))
         {
            this.sim.DEBUG_ToggleExploded();
         }
         if(this.input.IsKeyDown(Keyboard.SHIFT))
         {
            this.sim.DEBUG_GrabRagdoll(_loc1_,_loc2_);
         }
         if(!this.SIM_is_paused || this.input.IsMousePressed())
         {
            this.sim.Tick(this.rend);
            this.gfx.Render();
            this.sfx.Tick();
         }
      }
      
      private function Add_Undo_Frame() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.current_state.entities.length)
         {
            if(this.current_state.entities[_loc1_][edat.EPROP_TYPE] == edat.ETYPE_NULLFLAG)
            {
               trace("WARNING! Add_Undo_Frame() was called when unmatched entities existed!");
               return;
            }
            _loc1_++;
         }
         if(this.UNDO_undo_stack.length > this.UNDO_current_index + 1)
         {
            while(this.UNDO_undo_stack.length > this.UNDO_current_index + 1)
            {
               this.UNDO_undo_stack.pop();
            }
         }
         else
         {
            this.UNDO_undo_stack.push(this.current_state.Clone());
            this.UNDO_current_index = this.UNDO_undo_stack.length - 1;
         }
         this.UNDO_is_undoing = false;
         this.IS_LEVEL_UNSAVED = true;
      }
      
      private function Undo() : void
      {
         var _loc1_:uint = 0;
         if(this.UNDO_current_index < 1 || this.UNDO_undo_stack.length == 0)
         {
            return;
         }
         this.ENTITY_dragged_id = -1;
         if(!this.UNDO_is_undoing)
         {
            if(this.EDIT_entity_buffer != null)
            {
               this.EDIT_entity_buffer.WipeUnmatchedEntities();
            }
            if(this.current_state.entities.length > 0)
            {
               _loc1_ = this.current_state.entities[this.current_state.entities.length - 1][edat.EPROP_TYPE];
               if(_loc1_ == edat.ETYPE_EXIT_DOOR || _loc1_ == edat.ETYPE_DOOR_LOCKED || _loc1_ == edat.ETYPE_DOOR_TRAP)
               {
                  this.current_state.entities.pop();
               }
            }
            this.UNDO_undo_stack.push(this.current_state.Clone());
            this.current_state = this.UNDO_undo_stack[this.UNDO_current_index].Clone();
            this.UNDO_is_undoing = true;
         }
         else
         {
            --this.UNDO_current_index;
            this.current_state = this.UNDO_undo_stack[this.UNDO_current_index].Clone();
         }
      }
      
      private function Redo() : void
      {
         if(this.UNDO_current_index < this.UNDO_undo_stack.length - 1)
         {
            ++this.UNDO_current_index;
            this.current_state = this.UNDO_undo_stack[this.UNDO_current_index].Clone();
         }
      }
      
      private function DEBUG_ValidateState() : Boolean
      {
         var _loc5_:Vector.<uint> = null;
         var _loc6_:uint = 0;
         var _loc1_:int = 0;
         if(this.EDIT_entity_buffer != null)
         {
            _loc1_ = int(this.EDIT_entity_buffer.unmatchedCount);
         }
         var _loc2_:Boolean = true;
         var _loc3_:int = 0;
         var _loc4_:uint = 0;
         while(_loc4_ < this.current_state.entities.length)
         {
            _loc5_ = this.current_state.entities[_loc4_];
            _loc6_ = _loc5_[edat.EPROP_TYPE];
            if(_loc6_ == edat.ETYPE_NULLFLAG)
            {
               _loc3_++;
            }
            else if(_loc6_ == edat.ETYPE_EXIT_DOOR || _loc6_ == edat.ETYPE_DOOR_LOCKED || _loc6_ == edat.ETYPE_DOOR_TRAP)
            {
               if(_loc4_ >= this.current_state.entities.length - 1)
               {
                  trace("WARNING! DEBUG_ValidateState() found a door last: " + _loc6_ + "," + _loc4_);
                  _loc2_ = false;
               }
               else if(this.current_state.entities[_loc4_ + 1][edat.EPROP_TYPE] != edat.ETYPE_NULLFLAG)
               {
                  if(this.current_state.entities[_loc4_ + 1][edat.EPROP_TYPE] != _loc6_ + 1)
                  {
                     trace("WARNING! DEBUG_ValidateState() found a door without a switch: " + _loc6_ + "," + _loc4_);
                     _loc2_ = false;
                  }
               }
            }
            else if(_loc6_ == edat.ETYPE_EXIT_SWITCH || _loc6_ == edat.ETYPE_SWITCH_LOCKED || _loc6_ == edat.ETYPE_SWITCH_TRAP)
            {
               if(_loc4_ < 1)
               {
                  trace("WARNING! GetOrderedEntityIDsInRegion() found a switch first: " + _loc6_ + "," + _loc4_);
                  _loc2_ = false;
               }
               else if(this.current_state.entities[_loc4_ - 1][edat.EPROP_TYPE] != edat.ETYPE_NULLFLAG)
               {
                  if(this.current_state.entities[_loc4_ - 1][edat.EPROP_TYPE] != _loc6_ - 1)
                  {
                     trace("WARNING! DEBUG_ValidateState() found a switch without a door: " + _loc6_ + "," + _loc4_);
                     _loc2_ = false;
                  }
               }
            }
            _loc4_++;
         }
         if(_loc1_ != _loc3_)
         {
            trace("WARNING! DEBUG_ValidateState() found a contradictory number of unmatched items: " + _loc1_ + "," + _loc3_);
            _loc2_ = false;
         }
         return _loc2_;
      }
      
      private function GetIndexOfEntityUnderPoint(param1:vec2, param2:Vector.<Vector.<uint>>) : int
      {
         var _loc5_:Vector.<uint> = null;
         var _loc6_:vec2 = null;
         var _loc7_:vec2 = null;
         var _loc8_:vec2 = null;
         var _loc3_:int = -1;
         var _loc4_:int = 0;
         for(; _loc4_ < param2.length; _loc4_++)
         {
            _loc5_ = param2[_loc4_];
            _loc6_ = edat.GET_WORLDSPACE_POS(_loc5_);
            _loc7_ = edat.GET_COLLISION_SHAPE(_loc5_);
            _loc8_ = _loc6_.To(param1);
            if(_loc7_.y < 0)
            {
               if(_loc8_.Len() > _loc7_.x)
               {
                  continue;
               }
            }
            else if(Math.abs(_loc8_.x) > _loc7_.x || Math.abs(_loc8_.y) > _loc7_.y)
            {
               continue;
            }
            _loc3_ = _loc4_;
         }
         return _loc3_;
      }
      
      private function Delete_Entities(param1:Vector.<uint>, param2:Vector.<Vector.<uint>>) : void
      {
         var _loc4_:Vector.<uint> = null;
         var _loc5_:uint = 0;
         var _loc3_:int = int(param1.length - 1);
         while(_loc3_ >= 0)
         {
            _loc4_ = param2[param1[_loc3_]];
            _loc5_ = _loc4_[edat.EPROP_TYPE];
            this.Delete_Single_Entity(param1[_loc3_],param2);
            if(_loc5_ == edat.ETYPE_SWITCH_LOCKED || _loc5_ == edat.ETYPE_SWITCH_TRAP || _loc5_ == edat.ETYPE_EXIT_SWITCH)
            {
               if(param1[_loc3_] == 0)
               {
                  trace("WARNING! Delete_Entities() found a switch coming first?!");
                  return;
               }
               if(_loc3_ != 0)
               {
                  if(param1[_loc3_] == param1[_loc3_ - 1] + 1)
                  {
                     _loc3_--;
                  }
               }
            }
            _loc3_--;
         }
      }
      
      private function Delete_Single_Entity(param1:uint, param2:Vector.<Vector.<uint>>) : void
      {
         var _loc3_:uint = param2[param1][edat.EPROP_TYPE];
         var _loc4_:uint = 1;
         var _loc5_:uint = param1;
         if(_loc3_ == edat.ETYPE_DOOR_LOCKED || _loc3_ == edat.ETYPE_DOOR_TRAP || _loc3_ == edat.ETYPE_EXIT_DOOR)
         {
            _loc4_ = 2;
         }
         else if(_loc3_ == edat.ETYPE_SWITCH_LOCKED || _loc3_ == edat.ETYPE_SWITCH_TRAP || _loc3_ == edat.ETYPE_EXIT_SWITCH)
         {
            _loc4_ = 2;
            _loc5_ = param1 - 1;
         }
         param2.splice(_loc5_,_loc4_);
      }
      
      private function Paint_Tile(param1:uint, param2:uint, param3:uint, param4:Vector.<uint>) : void
      {
         if(param3 < 0 || param3 >= tiletypes.num_ingame_tile_types)
         {
            trace("WARNING! Paint_Tile() was passed an invalid tileID: " + param3);
            return;
         }
         var _loc5_:uint = Math.max(1,Math.min(edat.num_cols,param1)) - 1;
         var _loc6_:uint = Math.max(1,Math.min(edat.num_rows,param2)) - 1;
         param4[_loc5_ + _loc6_ * edat.num_cols] = param3;
      }
      
      private function Place_Entity(param1:uint, param2:uint, param3:uint, param4:uint, param5:uint, param6:Boolean, param7:Boolean, param8:Vector.<Vector.<uint>>) : void
      {
         var _loc9_:Vector.<uint> = new Vector.<uint>();
         _loc9_.push(param1);
         _loc9_.push(param2);
         _loc9_.push(param3);
         if(param6)
         {
            _loc9_.push(param4);
            if(param7)
            {
               _loc9_.push(param5);
            }
         }
         param8.push(_loc9_);
      }
      
      private function Copy_Tiles(param1:int, param2:int, param3:int, param4:int, param5:Vector.<uint>) : TileRect
      {
         var _loc10_:int = 0;
         param1--;
         param2--;
         param3--;
         param4--;
         if(param1 < 0 || param2 < 0 || param3 >= edat.num_cols || param4 >= edat.num_rows || param1 > param3 || param2 > param4)
         {
            trace("WARNING! Copy_Tiles() was called with an invalid rect: " + param1 + "," + param2 + " .. " + param3 + "," + param4);
            return null;
         }
         var _loc6_:uint = uint(1 + (param3 - param1));
         var _loc7_:uint = uint(1 + (param4 - param2));
         var _loc8_:TileRect = new TileRect(_loc6_,_loc7_);
         var _loc9_:int = 0;
         while(_loc9_ < _loc7_)
         {
            _loc10_ = 0;
            while(_loc10_ < _loc6_)
            {
               _loc8_.data[_loc10_ + _loc9_ * _loc6_] = param5[param1 + _loc10_ + (param2 + _loc9_) * edat.num_cols];
               _loc10_++;
            }
            _loc9_++;
         }
         return _loc8_;
      }
      
      private function Paste_Tiles(param1:Boolean, param2:int, param3:int, param4:TileRect, param5:Vector.<uint>) : void
      {
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:uint = 0;
         param2--;
         param3--;
         var _loc6_:uint = param4.stride;
         var _loc7_:uint = param4.GetNumRows();
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_)
         {
            _loc9_ = param3 + _loc8_;
            if(!(_loc9_ < 0 || _loc9_ >= edat.num_rows))
            {
               _loc10_ = 0;
               while(_loc10_ < _loc6_)
               {
                  _loc11_ = param2 + _loc10_;
                  if(!(_loc11_ < 0 || _loc11_ >= edat.num_cols))
                  {
                     _loc12_ = param4.data[_loc10_ + _loc8_ * _loc6_];
                     if(!(_loc12_ == tiletypes.EMPTY && !param1))
                     {
                        param5[_loc11_ + _loc9_ * edat.num_cols] = _loc12_;
                     }
                  }
                  _loc10_++;
               }
            }
            _loc8_++;
         }
      }
      
      private function GetOrderedEntityIDsInRegion(param1:Boolean, param2:int, param3:int, param4:int, param5:int, param6:Vector.<Vector.<uint>>) : Vector.<uint>
      {
         var _loc13_:Vector.<uint> = null;
         var _loc14_:uint = 0;
         var _loc15_:uint = 0;
         var _loc16_:uint = 0;
         if(param2 < 1 || param3 < 1 || param4 > edat.num_cols || param5 > edat.num_rows || param2 > param4 || param3 > param5)
         {
            trace("WARNING! GetOrderedEntityIDsInRegion() was called with an invalid rect: " + param2 + "," + param3 + " .. " + param4 + "," + param5);
            return null;
         }
         var _loc7_:uint = uint(param2 * edat.quantize_steps_per_cell);
         var _loc8_:uint = uint((param4 + 1) * edat.quantize_steps_per_cell);
         var _loc9_:uint = uint(param3 * edat.quantize_steps_per_cell);
         var _loc10_:uint = uint((param5 + 1) * edat.quantize_steps_per_cell);
         if(!param1)
         {
            _loc7_++;
            _loc9_++;
            _loc8_--;
            _loc10_--;
         }
         var _loc11_:Vector.<uint> = new Vector.<uint>();
         var _loc12_:uint = 0;
         for(; _loc12_ < param6.length; _loc12_++)
         {
            _loc13_ = param6[_loc12_];
            _loc14_ = _loc13_[edat.EPROP_X];
            _loc15_ = _loc13_[edat.EPROP_Y];
            _loc16_ = _loc13_[edat.EPROP_TYPE];
            if(_loc16_ != edat.ETYPE_NULLFLAG)
            {
               if(_loc16_ == edat.ETYPE_EXIT_DOOR || _loc16_ == edat.ETYPE_DOOR_LOCKED || _loc16_ == edat.ETYPE_DOOR_TRAP)
               {
                  if(_loc12_ >= param6.length - 1)
                  {
                     trace("WARNING! GetOrderedEntityIDsInRegion() found a door without a switch: " + _loc16_);
                     continue;
                  }
                  if(param6[_loc12_ + 1][edat.EPROP_TYPE] == edat.ETYPE_NULLFLAG)
                  {
                     continue;
                  }
               }
               if(_loc16_ == edat.ETYPE_EXIT_SWITCH || _loc16_ == edat.ETYPE_SWITCH_LOCKED || _loc16_ == edat.ETYPE_SWITCH_TRAP)
               {
                  if(_loc12_ < 1)
                  {
                     trace("WARNING! GetOrderedEntityIDsInRegion() found a switch without a door: " + _loc16_);
                     continue;
                  }
                  if(param6[_loc12_ - 1][edat.EPROP_TYPE] == edat.ETYPE_NULLFLAG)
                  {
                     continue;
                  }
               }
               if(_loc14_ >= _loc7_ && _loc14_ <= _loc8_ && _loc15_ >= _loc9_ && _loc15_ <= _loc10_)
               {
                  _loc11_.push(_loc12_);
               }
            }
         }
         return _loc11_;
      }
      
      private function Cut_Entities(param1:Boolean, param2:int, param3:int, param4:int, param5:int, param6:Vector.<Vector.<uint>>) : EntityBuffer
      {
         var _loc16_:Vector.<uint> = null;
         var _loc17_:uint = 0;
         var _loc18_:Boolean = false;
         var _loc19_:Vector.<uint> = null;
         var _loc20_:Vector.<uint> = null;
         var _loc21_:int = 0;
         var _loc22_:Vector.<uint> = null;
         if(param2 < 1 || param3 < 1 || param4 > edat.num_cols || param5 > edat.num_rows || param2 > param4 || param3 > param5)
         {
            trace("WARNING! Cut_Entities() was called with an invalid rect: " + param2 + "," + param3 + " .. " + param4 + "," + param5);
            return null;
         }
         var _loc7_:int = param2 * edat.quantize_steps_per_cell;
         var _loc8_:int = param3 * edat.quantize_steps_per_cell;
         var _loc9_:EntityBuffer = new EntityBuffer();
         var _loc10_:Vector.<uint> = this.GetOrderedEntityIDsInRegion(param1,param2,param3,param4,param5,param6);
         var _loc11_:Vector.<uint> = new Vector.<uint>();
         var _loc12_:int = 0;
         while(_loc12_ < _loc10_.length)
         {
            _loc16_ = param6[_loc10_[_loc12_]];
            _loc17_ = _loc16_[edat.EPROP_TYPE];
            _loc18_ = false;
            if(_loc17_ == edat.ETYPE_EXIT_DOOR || _loc17_ == edat.ETYPE_DOOR_LOCKED || _loc17_ == edat.ETYPE_DOOR_TRAP)
            {
               if(_loc12_ == _loc10_.length - 1)
               {
                  _loc18_ = true;
               }
               else if(_loc10_[_loc12_ + 1] != _loc10_[_loc12_] + 1)
               {
                  _loc18_ = true;
               }
            }
            else if(_loc17_ == edat.ETYPE_EXIT_SWITCH || _loc17_ == edat.ETYPE_SWITCH_LOCKED || _loc17_ == edat.ETYPE_SWITCH_TRAP)
            {
               if(_loc12_ == 0)
               {
                  _loc18_ = true;
               }
               else if(_loc10_[_loc12_ - 1] != _loc10_[_loc12_] - 1)
               {
                  _loc18_ = true;
               }
            }
            if(_loc18_)
            {
               _loc11_.push(_loc10_[_loc12_]);
            }
            else
            {
               _loc9_.entities.push(_loc16_);
            }
            _loc12_++;
         }
         _loc9_.unmatchedCount = _loc11_.length;
         var _loc13_:int = 0;
         while(_loc13_ < _loc11_.length)
         {
            _loc19_ = param6[_loc11_[_loc13_]];
            _loc20_ = new Vector.<uint>();
            _loc21_ = 0;
            while(_loc21_ < _loc19_.length)
            {
               _loc20_.push(_loc19_[_loc21_]);
               _loc21_++;
            }
            _loc9_.entities.push(_loc20_);
            _loc19_[edat.EPROP_TYPE] = edat.ETYPE_NULLFLAG;
            _loc13_++;
         }
         var _loc14_:int = int(_loc10_.length - 1);
         while(_loc14_ >= 0)
         {
            if(param6[_loc10_[_loc14_]][edat.EPROP_TYPE] != edat.ETYPE_NULLFLAG)
            {
               param6.splice(_loc10_[_loc14_],1);
            }
            _loc14_--;
         }
         var _loc15_:int = 0;
         while(_loc15_ < _loc9_.entities.length)
         {
            _loc22_ = _loc9_.entities[_loc15_];
            _loc22_[edat.EPROP_X] = _loc22_[edat.EPROP_X] - _loc7_;
            _loc22_[edat.EPROP_Y] -= _loc8_;
            _loc15_++;
         }
         return _loc9_;
      }
      
      private function Paste_Entities(param1:int, param2:int, param3:EntityBuffer, param4:Vector.<Vector.<uint>>) : void
      {
         var _loc19_:int = 0;
         var _loc20_:Vector.<uint> = null;
         var _loc21_:uint = 0;
         var _loc22_:uint = 0;
         var _loc23_:Vector.<uint> = null;
         var _loc24_:int = 0;
         var _loc25_:uint = 0;
         var _loc26_:int = 0;
         var _loc5_:uint = uint(param1 * edat.quantize_steps_per_cell);
         var _loc6_:uint = uint(param2 * edat.quantize_steps_per_cell);
         var _loc7_:uint = 4;
         var _loc8_:uint = 4;
         var _loc9_:uint = uint((edat.num_cols + 1) * edat.quantize_steps_per_cell);
         var _loc10_:uint = uint((edat.num_rows + 1) * edat.quantize_steps_per_cell);
         var _loc11_:Vector.<uint> = new Vector.<uint>();
         if(param3.unmatchedCount > 0)
         {
            _loc19_ = 0;
            while(_loc19_ < param4.length)
            {
               if(param4[_loc19_][edat.EPROP_TYPE] == edat.ETYPE_NULLFLAG)
               {
                  _loc11_.push(_loc19_);
               }
               _loc19_++;
            }
         }
         if(_loc11_.length != param3.unmatchedCount)
         {
            trace("WARNING! Paste_Entities() has an inconsistent number of unmatched objects, pre-operation: " + _loc11_.length + "," + param3.unmatchedCount);
            trace(this.current_state.GetDebugString());
         }
         var _loc12_:Vector.<uint> = new Vector.<uint>();
         var _loc13_:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>();
         var _loc14_:int = int(param3.entities.length - 1);
         while(_loc14_ >= 0)
         {
            _loc20_ = param3.entities[_loc14_];
            _loc21_ = _loc5_ + _loc20_[edat.EPROP_X];
            _loc22_ = _loc6_ + _loc20_[edat.EPROP_Y];
            if(!(_loc21_ < _loc7_ || _loc22_ < _loc8_ || _loc21_ > _loc9_ || _loc22_ > _loc10_))
            {
               _loc23_ = new Vector.<uint>();
               _loc24_ = 0;
               while(_loc24_ < _loc20_.length)
               {
                  _loc23_.push(_loc20_[_loc24_]);
                  _loc24_++;
               }
               _loc23_[edat.EPROP_X] = _loc21_;
               _loc23_[edat.EPROP_Y] = _loc22_;
               _loc25_ = uint(param3.entities.length - _loc14_);
               if(_loc25_ <= param3.unmatchedCount)
               {
                  _loc26_ = int(_loc11_[_loc11_.length - _loc25_]);
                  if(param4[_loc26_][edat.EPROP_TYPE] != edat.ETYPE_NULLFLAG)
                  {
                     trace("WARNING! Paste_Entities() has an invalid flagged index: " + _loc26_ + " .. " + _loc25_ + "," + param3.unmatchedCount);
                  }
                  param4[_loc26_] = _loc23_;
                  _loc12_.push(_loc14_);
               }
               else
               {
                  _loc13_.push(_loc23_);
               }
            }
            _loc14_--;
         }
         var _loc15_:int = int(_loc13_.length - 1);
         while(_loc15_ >= 0)
         {
            param4.push(_loc13_[_loc15_]);
            _loc15_--;
         }
         var _loc16_:int = 0;
         while(_loc16_ < _loc12_.length)
         {
            param3.entities.splice(_loc12_[_loc16_],1);
            --param3.unmatchedCount;
            _loc16_++;
         }
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         while(_loc18_ < param4.length)
         {
            if(param4[_loc18_][edat.EPROP_TYPE] == edat.ETYPE_NULLFLAG)
            {
               _loc17_++;
            }
            _loc18_++;
         }
         if(_loc17_ != param3.unmatchedCount)
         {
            trace("WARNING! Paste_Entities() has an unconsistant number of unmatched entities, post-operation: " + _loc17_ + "," + param3.unmatchedCount);
            trace(this.current_state.GetDebugString());
         }
      }
      
      private function DEPRECATED_Clear_Selection(param1:TileRect, param2:EntityBuffer, param3:Vector.<Vector.<uint>>) : void
      {
         param1 = null;
         this.HELPER_Dispose_Entity_Buffer(param2,param3);
         param2 = null;
      }
      
      private function HELPER_Dispose_Entity_Buffer(param1:EntityBuffer, param2:Vector.<Vector.<uint>>) : void
      {
         var _loc3_:Vector.<uint> = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(param1.unmatchedCount > 0)
         {
            _loc3_ = new Vector.<uint>();
            _loc4_ = 0;
            while(_loc4_ < param2.length)
            {
               if(param2[_loc4_][edat.EPROP_TYPE] == edat.ETYPE_NULLFLAG)
               {
                  _loc3_.push(_loc4_);
               }
               _loc4_++;
            }
            if(_loc3_.length != param1.unmatchedCount)
            {
               trace("WARNING! Clear_Selection() has an inconsistent number of unmatched objects, pre-operation: " + _loc3_.length + "," + param1.unmatchedCount);
               trace(this.current_state.GetDebugString());
            }
            _loc5_ = param1.entities.length - param1.unmatchedCount;
            _loc6_ = 0;
            while(_loc6_ < param1.unmatchedCount)
            {
               param2[_loc3_[_loc6_]][edat.EPROP_TYPE] = param1.entities[_loc5_ + _loc6_][edat.EPROP_TYPE];
               _loc6_++;
            }
         }
      }
      
      private function Transform_Tile_Buffer(param1:uint, param2:TileRect) : TileRect
      {
         var _loc3_:TileRect = new TileRect(param2.stride,param2.GetNumRows());
         if(param1 == XFORMTYPE_INVERT)
         {
            this.TileOp_Invert(param2,_loc3_);
         }
         else if(param1 == XFORMTYPE_CLEAR)
         {
            this.TileOp_Fill(param2,_loc3_,tiletypes.EMPTY);
         }
         else if(param1 == XFORMTYPE_FILL)
         {
            this.TileOp_Fill(param2,_loc3_,tiletypes.FULL);
         }
         else if(param1 == XFORMTYPE_ROTATE_CW)
         {
            this.TileOp_Rotate90CW(param2,_loc3_);
         }
         else if(param1 == XFORMTYPE_ROTATE_CCW)
         {
            this.TileOp_Rotate90CCW(param2,_loc3_);
         }
         else if(param1 == XFORMTYPE_MIRROR_H)
         {
            this.TileOp_MirrorH(param2,_loc3_);
         }
         else
         {
            if(param1 != XFORMTYPE_MIRROR_V)
            {
               trace("WARNING! Transform_Tile_Buffer() was called with an invalid xform type: " + param1);
               return null;
            }
            this.TileOp_MirrorV(param2,_loc3_);
         }
         return _loc3_;
      }
      
      private function Transform_Entity_Buffer(param1:uint, param2:uint, param3:uint, param4:EntityBuffer) : void
      {
         if(param1 == XFORMTYPE_ROTATE_CW)
         {
            this.EntityOp_Rotate90CW(param2,param3,param4);
         }
         else if(param1 == XFORMTYPE_ROTATE_CCW)
         {
            this.EntityOp_Rotate90CCW(param2,param3,param4);
         }
         else if(param1 == XFORMTYPE_MIRROR_H)
         {
            this.EntityOp_MirrorH(param2,param3,param4);
         }
         else if(param1 == XFORMTYPE_MIRROR_V)
         {
            this.EntityOp_MirrorV(param2,param3,param4);
         }
         else
         {
            trace("WARNING! Transform_Entity_Buffer() was called with an invalid xform type: " + param1);
         }
      }
      
      private function DEPRECATED_Transform_Selection(param1:uint, param2:TileRect, param3:EntityBuffer) : TileRect
      {
         var _loc4_:TileRect = new TileRect(param2.stride,param2.GetNumRows());
         if(param1 == XFORMTYPE_INVERT)
         {
            this.TileOp_Invert(param2,_loc4_);
         }
         else if(param1 == XFORMTYPE_CLEAR)
         {
            this.TileOp_Fill(param2,_loc4_,tiletypes.EMPTY);
         }
         else if(param1 == XFORMTYPE_FILL)
         {
            this.TileOp_Fill(param2,_loc4_,tiletypes.FULL);
         }
         else if(param1 == XFORMTYPE_ROTATE_CW)
         {
            this.EntityOp_Rotate90CW(param2.stride,param2.GetNumRows(),param3);
            this.TileOp_Rotate90CW(param2,_loc4_);
         }
         else if(param1 == XFORMTYPE_ROTATE_CCW)
         {
            this.EntityOp_Rotate90CCW(param2.stride,param2.GetNumRows(),param3);
            this.TileOp_Rotate90CCW(param2,_loc4_);
         }
         else if(param1 == XFORMTYPE_MIRROR_H)
         {
            this.EntityOp_MirrorH(param2.stride,param2.GetNumRows(),param3);
            this.TileOp_MirrorH(param2,_loc4_);
         }
         else
         {
            if(param1 != XFORMTYPE_MIRROR_V)
            {
               trace("WARNING! Transform_Selection() was called with an invalid xform type: " + param1);
               return null;
            }
            this.EntityOp_MirrorV(param2.stride,param2.GetNumRows(),param3);
            this.TileOp_MirrorV(param2,_loc4_);
         }
         return _loc4_;
      }
      
      private function EntityOp_Rotate90CW(param1:uint, param2:uint, param3:EntityBuffer) : void
      {
         var _loc9_:Vector.<uint> = null;
         var _loc10_:uint = 0;
         var _loc11_:uint = 0;
         var _loc4_:uint = param1 * 4 / 2;
         var _loc5_:uint = param2 * 4 / 2;
         var _loc6_:uint = uint(_loc4_ - _loc5_);
         var _loc7_:uint = uint(_loc5_ - _loc4_);
         var _loc8_:int = 0;
         while(_loc8_ < param3.entities.length)
         {
            _loc9_ = param3.entities[_loc8_];
            _loc10_ = -(_loc9_[edat.EPROP_Y] - _loc5_);
            _loc11_ = uint(_loc9_[edat.EPROP_X] - _loc4_);
            _loc9_[edat.EPROP_X] = _loc4_ + _loc10_ - _loc6_;
            _loc9_[edat.EPROP_Y] = _loc5_ + _loc11_ - _loc7_;
            if(_loc9_.length > 3)
            {
               _loc9_[edat.EPROP_DIR] = (_loc9_[edat.EPROP_DIR] + 2) % 8;
            }
            _loc8_++;
         }
      }
      
      private function EntityOp_Rotate90CCW(param1:uint, param2:uint, param3:EntityBuffer) : void
      {
         var _loc9_:Vector.<uint> = null;
         var _loc10_:uint = 0;
         var _loc11_:uint = 0;
         var _loc4_:uint = param1 * 4 / 2;
         var _loc5_:uint = param2 * 4 / 2;
         var _loc6_:uint = uint(_loc4_ - _loc5_);
         var _loc7_:uint = uint(_loc5_ - _loc4_);
         var _loc8_:int = 0;
         while(_loc8_ < param3.entities.length)
         {
            _loc9_ = param3.entities[_loc8_];
            _loc10_ = uint(_loc9_[edat.EPROP_Y] - _loc5_);
            _loc11_ = -(_loc9_[edat.EPROP_X] - _loc4_);
            _loc9_[edat.EPROP_X] = _loc4_ + _loc10_ - _loc6_;
            _loc9_[edat.EPROP_Y] = _loc5_ + _loc11_ - _loc7_;
            if(_loc9_.length > 3)
            {
               _loc9_[edat.EPROP_DIR] = (_loc9_[edat.EPROP_DIR] - 2 + 8) % 8;
            }
            _loc8_++;
         }
      }
      
      private function EntityOp_MirrorH(param1:uint, param2:uint, param3:EntityBuffer) : void
      {
         var _loc7_:Vector.<uint> = null;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc4_:uint = param1 * 4 / 2;
         var _loc5_:uint = param2 * 4 / 2;
         var _loc6_:int = 0;
         while(_loc6_ < param3.entities.length)
         {
            _loc7_ = param3.entities[_loc6_];
            _loc8_ = -(_loc7_[edat.EPROP_X] - _loc4_);
            _loc9_ = uint(_loc7_[edat.EPROP_Y] - _loc5_);
            _loc7_[edat.EPROP_X] = _loc4_ + _loc8_;
            _loc7_[edat.EPROP_Y] = _loc5_ + _loc9_;
            if(_loc7_.length > 3)
            {
               _loc7_[edat.EPROP_DIR] = (4 - _loc7_[edat.EPROP_DIR] + 8) % 8;
            }
            if(_loc7_.length > 4)
            {
               _loc7_[edat.EPROP_MOVE] = edat.HELPER_MIRROR_MOVE[_loc7_[edat.EPROP_MOVE]];
            }
            _loc6_++;
         }
      }
      
      private function EntityOp_MirrorV(param1:uint, param2:uint, param3:EntityBuffer) : void
      {
         var _loc7_:Vector.<uint> = null;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc4_:uint = param1 * 4 / 2;
         var _loc5_:uint = param2 * 4 / 2;
         var _loc6_:int = 0;
         while(_loc6_ < param3.entities.length)
         {
            _loc7_ = param3.entities[_loc6_];
            _loc8_ = uint(_loc7_[edat.EPROP_X] - _loc4_);
            _loc9_ = -(_loc7_[edat.EPROP_Y] - _loc5_);
            _loc7_[edat.EPROP_X] = _loc4_ + _loc8_;
            _loc7_[edat.EPROP_Y] = _loc5_ + _loc9_;
            if(_loc7_.length > 3)
            {
               _loc7_[edat.EPROP_DIR] = (-_loc7_[edat.EPROP_DIR] + 8) % 8;
            }
            if(_loc7_.length > 4)
            {
               _loc7_[edat.EPROP_MOVE] = edat.HELPER_MIRROR_MOVE[_loc7_[edat.EPROP_MOVE]];
            }
            _loc6_++;
         }
      }
      
      private function TileOp_Invert(param1:TileRect, param2:TileRect) : void
      {
         var _loc3_:int = 0;
         while(_loc3_ < param1.data.length)
         {
            param2.data[_loc3_] = tiletypes.XFORM_INVERT[param1.data[_loc3_]];
            _loc3_++;
         }
      }
      
      private function TileOp_Fill(param1:TileRect, param2:TileRect, param3:uint) : void
      {
         var _loc4_:int = 0;
         while(_loc4_ < param1.data.length)
         {
            param2.data[_loc4_] = param3;
            _loc4_++;
         }
      }
      
      private function TileOp_Rotate90CW(param1:TileRect, param2:TileRect) : void
      {
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc10_:uint = 0;
         param2.stride = param2.GetNumRows();
         var _loc3_:uint = param1.stride;
         var _loc4_:uint = param2.stride;
         var _loc5_:uint = param1.GetNumRows() - 1;
         var _loc6_:int = 0;
         while(_loc6_ < param1.data.length)
         {
            _loc7_ = _loc6_ % _loc3_;
            _loc8_ = _loc6_ / _loc3_;
            _loc9_ = uint(_loc5_ - _loc8_);
            _loc10_ = _loc7_;
            param2.data[_loc9_ + _loc10_ * _loc4_] = tiletypes.XFORM_ROTCW[param1.data[_loc7_ + _loc8_ * _loc3_]];
            _loc6_++;
         }
      }
      
      private function TileOp_Rotate90CCW(param1:TileRect, param2:TileRect) : void
      {
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc10_:uint = 0;
         param2.stride = param2.GetNumRows();
         var _loc3_:uint = param1.stride;
         var _loc4_:uint = param2.stride;
         var _loc5_:uint = _loc3_ - 1;
         var _loc6_:int = 0;
         while(_loc6_ < param1.data.length)
         {
            _loc7_ = _loc6_ % _loc3_;
            _loc9_ = _loc8_ = _loc6_ / _loc3_;
            _loc10_ = uint(_loc5_ - _loc7_);
            param2.data[_loc9_ + _loc10_ * _loc4_] = tiletypes.XFORM_ROTCCW[param1.data[_loc7_ + _loc8_ * _loc3_]];
            _loc6_++;
         }
      }
      
      private function TileOp_MirrorH(param1:TileRect, param2:TileRect) : void
      {
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc3_:uint = param1.stride;
         var _loc4_:uint = _loc3_ - 1;
         var _loc5_:int = 0;
         while(_loc5_ < param1.data.length)
         {
            _loc6_ = _loc5_ % _loc3_;
            _loc7_ = _loc5_ / _loc3_;
            _loc8_ = uint(_loc4_ - _loc6_);
            _loc9_ = _loc7_;
            param2.data[_loc8_ + _loc9_ * _loc3_] = tiletypes.XFORM_FLIPH[param1.data[_loc6_ + _loc7_ * _loc3_]];
            _loc5_++;
         }
      }
      
      private function TileOp_MirrorV(param1:TileRect, param2:TileRect) : void
      {
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc3_:uint = param1.stride;
         var _loc4_:uint = param1.GetNumRows() - 1;
         var _loc5_:int = 0;
         while(_loc5_ < param1.data.length)
         {
            _loc6_ = _loc5_ % _loc3_;
            _loc7_ = _loc5_ / _loc3_;
            _loc8_ = _loc6_;
            _loc9_ = uint(_loc4_ - _loc7_);
            param2.data[_loc8_ + _loc9_ * _loc3_] = tiletypes.XFORM_FLIPV[param1.data[_loc6_ + _loc7_ * _loc3_]];
            _loc5_++;
         }
      }
      
      private function DEBUG_DrawCollisionShapes(param1:Vector.<Vector.<uint>>) : void
      {
         this.rend.SetStyle(0,16711935,100);
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            this.DEBUG_DrawCollisionShape(param1[_loc2_]);
            _loc2_++;
         }
      }
      
      private function DEBUG_DrawCollisionShape(param1:Vector.<uint>) : void
      {
         if(param1[edat.EPROP_TYPE] == edat.ETYPE_NULLFLAG)
         {
            return;
         }
         var _loc2_:vec2 = edat.GET_WORLDSPACE_POS(param1);
         var _loc3_:vec2 = edat.GET_COLLISION_SHAPE(param1);
         if(_loc3_.y < 0)
         {
            this.rend.DrawCircle(_loc2_.x,_loc2_.y,_loc3_.x);
         }
         else
         {
            this.rend.DrawAABB(_loc2_.x - _loc3_.x,_loc2_.x + _loc3_.x,_loc2_.y - _loc3_.y,_loc2_.y + _loc3_.y);
         }
      }
   }
}

