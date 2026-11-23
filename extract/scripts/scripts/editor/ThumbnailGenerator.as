package editor
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class ThumbnailGenerator
   {
      
      private static var MAP_ETYPE_TO_MC:Vector.<Class> = new Vector.<Class>(edat.num_etypes,true);
      
      MAP_ETYPE_TO_MC[edat.ETYPE_PLAYER] = asset_thumbnail_gfx_player;
      MAP_ETYPE_TO_MC[edat.ETYPE_BOUNCEBLOCK] = asset_thumbnail_gfx_bounceblock;
      MAP_ETYPE_TO_MC[edat.ETYPE_DOOR_REGULAR] = asset_thumbnail_gfx_door_regular;
      MAP_ETYPE_TO_MC[edat.ETYPE_DOOR_LOCKED] = asset_thumbnail_gfx_door_locked;
      MAP_ETYPE_TO_MC[edat.ETYPE_SWITCH_LOCKED] = asset_thumbnail_gfx_switch_locked;
      MAP_ETYPE_TO_MC[edat.ETYPE_DOOR_TRAP] = asset_thumbnail_gfx_door_trap;
      MAP_ETYPE_TO_MC[edat.ETYPE_SWITCH_TRAP] = asset_thumbnail_gfx_switch_trap;
      MAP_ETYPE_TO_MC[edat.ETYPE_CHAINGUN] = asset_thumbnail_gfx_chaingun;
      MAP_ETYPE_TO_MC[edat.ETYPE_LASER] = asset_thumbnail_gfx_laser;
      MAP_ETYPE_TO_MC[edat.ETYPE_ZAP] = asset_thumbnail_gfx_zap;
      MAP_ETYPE_TO_MC[edat.ETYPE_CHASER] = asset_thumbnail_gfx_chaser;
      MAP_ETYPE_TO_MC[edat.ETYPE_EXIT_DOOR] = asset_thumbnail_gfx_exit_door;
      MAP_ETYPE_TO_MC[edat.ETYPE_EXIT_SWITCH] = asset_thumbnail_gfx_exit_switch;
      MAP_ETYPE_TO_MC[edat.ETYPE_FLOORGUARD] = asset_thumbnail_gfx_floorguard;
      MAP_ETYPE_TO_MC[edat.ETYPE_GOLD] = asset_thumbnail_gfx_gold;
      MAP_ETYPE_TO_MC[edat.ETYPE_LAUNCHPAD] = asset_thumbnail_gfx_launchpad;
      MAP_ETYPE_TO_MC[edat.ETYPE_MINE] = asset_thumbnail_gfx_mine;
      MAP_ETYPE_TO_MC[edat.ETYPE_ONEWAY] = asset_thumbnail_gfx_oneway;
      MAP_ETYPE_TO_MC[edat.ETYPE_ROCKET] = asset_thumbnail_gfx_rocket;
      MAP_ETYPE_TO_MC[edat.ETYPE_TURRET] = asset_thumbnail_gfx_turret;
      MAP_ETYPE_TO_MC[edat.ETYPE_THWOMP] = asset_thumbnail_gfx_thwomp;
      
      public function ThumbnailGenerator()
      {
         super();
      }
      
      public static function Generate(param1:Editor_State) : Sprite
      {
         var _loc7_:MovieClip = null;
         var _loc8_:MovieClip = null;
         var _loc9_:MovieClip = null;
         var _loc10_:MovieClip = null;
         var _loc11_:int = 0;
         var _loc12_:MovieClip = null;
         var _loc13_:int = 0;
         var _loc14_:Vector.<uint> = null;
         var _loc15_:MovieClip = null;
         var _loc2_:Sprite = new Sprite();
         var _loc3_:int = 0;
         while(_loc3_ < edat.num_cols + 2)
         {
            _loc7_ = new asset_gfx_tiles();
            _loc8_ = new asset_gfx_tiles();
            _loc7_.x = (_loc3_ + 0.5) * edat.cell_size;
            _loc7_.y = 0.5 * edat.cell_size;
            _loc8_.x = (_loc3_ + 0.5) * edat.cell_size;
            _loc8_.y = (edat.num_rows + 1 + 0.5) * edat.cell_size;
            _loc7_.gotoAndStop(2);
            _loc8_.gotoAndStop(2);
            _loc2_.addChild(_loc7_);
            _loc2_.addChild(_loc8_);
            _loc3_++;
         }
         var _loc4_:int = 0;
         while(_loc4_ < edat.num_rows)
         {
            _loc9_ = new asset_gfx_tiles();
            _loc10_ = new asset_gfx_tiles();
            _loc9_.x = 0.5 * edat.cell_size;
            _loc9_.y = (_loc4_ + 1.5) * edat.cell_size;
            _loc10_.x = (edat.num_cols + 1 + 0.5) * edat.cell_size;
            _loc10_.y = (_loc4_ + 1.5) * edat.cell_size;
            _loc9_.gotoAndStop(2);
            _loc10_.gotoAndStop(2);
            _loc2_.addChild(_loc9_);
            _loc2_.addChild(_loc10_);
            _loc4_++;
         }
         var _loc5_:int = 0;
         while(_loc5_ < edat.num_cols)
         {
            _loc11_ = 0;
            while(_loc11_ < edat.num_rows)
            {
               _loc12_ = new asset_gfx_tiles();
               _loc12_.x = (_loc5_ + 1.5) * edat.cell_size;
               _loc12_.y = (_loc11_ + 1.5) * edat.cell_size;
               _loc13_ = _loc5_ + _loc11_ * edat.num_cols;
               _loc12_.gotoAndStop(param1.tileIDs[_loc13_] + 1);
               _loc2_.addChild(_loc12_);
               _loc11_++;
            }
            _loc5_++;
         }
         var _loc6_:int = 0;
         while(_loc6_ < param1.entities.length)
         {
            _loc14_ = param1.entities[_loc6_];
            _loc15_ = new MAP_ETYPE_TO_MC[_loc14_[edat.EPROP_TYPE]]();
            _loc15_.x = edat.quantize_step_size * _loc14_[edat.EPROP_X];
            _loc15_.y = edat.quantize_step_size * _loc14_[edat.EPROP_Y];
            if(_loc14_.length > 3)
            {
               if(_loc14_.length > 4)
               {
                  _loc15_.gotoAndStop(1);
               }
               else
               {
                  _loc15_.gotoAndStop(1 + _loc14_[edat.EPROP_DIR]);
               }
            }
            else
            {
               _loc15_.gotoAndStop(1);
            }
            _loc2_.addChild(_loc15_);
            _loc6_++;
         }
         _loc2_.scaleX = 1 / 6;
         _loc2_.scaleY = 1 / 6;
         _loc2_.cacheAsBitmap = true;
         return _loc2_;
      }
   }
}

