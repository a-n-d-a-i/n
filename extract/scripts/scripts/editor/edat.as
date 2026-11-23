package editor
{
   import math.vec2;
   
   public class edat
   {
      
      public static const num_cols:int = 31;
      
      public static const num_rows:int = 23;
      
      public static const cell_size:int = 24;
      
      public static const quantize_steps_per_cell:int = 4;
      
      public static const quantize_step_size:int = 6;
      
      public static const ETYPE_PLAYER:uint = 0;
      
      public static const ETYPE_MINE:uint = 1;
      
      public static const ETYPE_GOLD:uint = 2;
      
      public static const ETYPE_DOOR_REGULAR:uint = 3;
      
      public static const ETYPE_DOOR_LOCKED:uint = 4;
      
      public static const ETYPE_SWITCH_LOCKED:uint = 5;
      
      public static const ETYPE_DOOR_TRAP:uint = 6;
      
      public static const ETYPE_SWITCH_TRAP:uint = 7;
      
      public static const ETYPE_ONEWAY:uint = 8;
      
      public static const ETYPE_EXIT_DOOR:uint = 9;
      
      public static const ETYPE_EXIT_SWITCH:uint = 10;
      
      public static const ETYPE_CHAINGUN:uint = 11;
      
      public static const ETYPE_LASER:uint = 12;
      
      public static const ETYPE_ZAP:uint = 13;
      
      public static const ETYPE_CHASER:uint = 14;
      
      public static const ETYPE_FLOORGUARD:uint = 15;
      
      public static const ETYPE_LAUNCHPAD:uint = 16;
      
      public static const ETYPE_BOUNCEBLOCK:uint = 17;
      
      public static const ETYPE_ROCKET:uint = 18;
      
      public static const ETYPE_TURRET:uint = 19;
      
      public static const ETYPE_THWOMP:uint = 20;
      
      public static const num_etypes:uint = 21;
      
      public static const ETYPE_NULLFLAG:uint = 999;
      
      public static const EPROP_TYPE:uint = 0;
      
      public static const EPROP_X:uint = 1;
      
      public static const EPROP_Y:uint = 2;
      
      public static const EPROP_DIR:uint = 3;
      
      public static const EPROP_MOVE:uint = 4;
      
      public static const DIR_R:uint = 0;
      
      public static const DIR_RD:uint = 1;
      
      public static const DIR_D:uint = 2;
      
      public static const DIR_LD:uint = 3;
      
      public static const DIR_L:uint = 4;
      
      public static const DIR_LU:uint = 5;
      
      public static const DIR_U:uint = 6;
      
      public static const DIR_RU:uint = 7;
      
      public static const MOVE_SURFACE_CW:uint = 0;
      
      public static const MOVE_SURFACE_CCW:uint = 1;
      
      public static const MOVE_WANDER_CW:uint = 2;
      
      public static const MOVE_WANDER_CCW:uint = 3;
      
      public static var HELPER_MIRROR_MOVE:Vector.<uint> = new Vector.<uint>(4,true);
      
      public static var MAP_TILETYPE_TO_TILEID:Vector.<uint> = new Vector.<uint>(8,true);
      
      public static var MAP_ETYPE_TO_MC:Vector.<Class> = new Vector.<Class>(num_etypes,true);
      
      public static var MAP_ETYPE_TO_MC_SELECTED:Vector.<Class> = new Vector.<Class>(num_etypes,true);
      
      private static var HELPER_MAP_DIR_TO_VEC:Vector.<vec2> = new Vector.<vec2>(8,true);
      
      private static var HELPER_MAP_ETYPE_TO_COLSHAPE:Vector.<vec2> = new Vector.<vec2>(num_etypes,true);
      
      public static const STRUCTTYPE_PLAYER:uint = 0;
      
      public static const STRUCTTYPE_MINE:uint = 1;
      
      public static const STRUCTTYPE_GOLD:uint = 2;
      
      public static const STRUCTTYPE_EXIT:uint = 3;
      
      public static const STRUCTTYPE_DOOR_REGULAR:uint = 4;
      
      public static const STRUCTTYPE_DOOR_LOCKED:uint = 5;
      
      public static const STRUCTTYPE_DOOR_TRAP:uint = 6;
      
      public static const STRUCTTYPE_LAUNCHPAD:uint = 7;
      
      public static const STRUCTTYPE_ONEWAY:uint = 8;
      
      public static const STRUCTTYPE_CHAINGUN:uint = 9;
      
      public static const STRUCTTYPE_LASER:uint = 10;
      
      public static const STRUCTTYPE_ZAP:uint = 11;
      
      public static const STRUCTTYPE_CHASER:uint = 12;
      
      public static const STRUCTTYPE_FLOORGUARD:uint = 13;
      
      public static const STRUCTTYPE_BOUNCEBLOCK:uint = 14;
      
      public static const STRUCTTYPE_ROCKET:uint = 15;
      
      public static const STRUCTTYPE_TURRET:uint = 16;
      
      public static const STRUCTTYPE_THWOMP:uint = 17;
      
      public static const num_structtypes:uint = 18;
      
      public static var STRUCT_SIZE:Vector.<uint> = new Vector.<uint>(num_structtypes,true);
      
      public static var MAP_STRUCT_TO_ETYPE:Vector.<uint> = new Vector.<uint>(num_structtypes,true);
      
      HELPER_MIRROR_MOVE[MOVE_SURFACE_CW] = MOVE_SURFACE_CCW;
      HELPER_MIRROR_MOVE[MOVE_SURFACE_CCW] = MOVE_SURFACE_CW;
      HELPER_MIRROR_MOVE[MOVE_WANDER_CW] = MOVE_WANDER_CCW;
      HELPER_MIRROR_MOVE[MOVE_WANDER_CCW] = MOVE_WANDER_CW;
      MAP_TILETYPE_TO_TILEID[0] = 6;
      MAP_TILETYPE_TO_TILEID[1] = 26;
      MAP_TILETYPE_TO_TILEID[2] = 18;
      MAP_TILETYPE_TO_TILEID[3] = 14;
      MAP_TILETYPE_TO_TILEID[4] = 2;
      MAP_TILETYPE_TO_TILEID[5] = 30;
      MAP_TILETYPE_TO_TILEID[6] = 22;
      MAP_TILETYPE_TO_TILEID[7] = 10;
      MAP_ETYPE_TO_MC[ETYPE_PLAYER] = asset_editor_gfx_player;
      MAP_ETYPE_TO_MC[ETYPE_BOUNCEBLOCK] = asset_editor_gfx_bounceblock;
      MAP_ETYPE_TO_MC[ETYPE_DOOR_REGULAR] = asset_editor_gfx_door_regular;
      MAP_ETYPE_TO_MC[ETYPE_DOOR_LOCKED] = asset_editor_gfx_door_locked;
      MAP_ETYPE_TO_MC[ETYPE_SWITCH_LOCKED] = asset_editor_gfx_switch_locked;
      MAP_ETYPE_TO_MC[ETYPE_DOOR_TRAP] = asset_editor_gfx_door_trap;
      MAP_ETYPE_TO_MC[ETYPE_SWITCH_TRAP] = asset_editor_gfx_switch_trap;
      MAP_ETYPE_TO_MC[ETYPE_CHAINGUN] = asset_editor_gfx_chaingun;
      MAP_ETYPE_TO_MC[ETYPE_LASER] = asset_editor_gfx_laser;
      MAP_ETYPE_TO_MC[ETYPE_ZAP] = asset_editor_gfx_zap;
      MAP_ETYPE_TO_MC[ETYPE_CHASER] = asset_editor_gfx_chaser;
      MAP_ETYPE_TO_MC[ETYPE_EXIT_DOOR] = asset_editor_gfx_exit_door;
      MAP_ETYPE_TO_MC[ETYPE_EXIT_SWITCH] = asset_editor_gfx_exit_switch;
      MAP_ETYPE_TO_MC[ETYPE_FLOORGUARD] = asset_editor_gfx_floorguard;
      MAP_ETYPE_TO_MC[ETYPE_GOLD] = asset_editor_gfx_gold;
      MAP_ETYPE_TO_MC[ETYPE_LAUNCHPAD] = asset_editor_gfx_launchpad;
      MAP_ETYPE_TO_MC[ETYPE_MINE] = asset_editor_gfx_mine;
      MAP_ETYPE_TO_MC[ETYPE_ONEWAY] = asset_editor_gfx_oneway;
      MAP_ETYPE_TO_MC[ETYPE_ROCKET] = asset_editor_gfx_rocket;
      MAP_ETYPE_TO_MC[ETYPE_TURRET] = asset_editor_gfx_turret;
      MAP_ETYPE_TO_MC[ETYPE_THWOMP] = asset_editor_gfx_thwomp;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_PLAYER] = asset_editor_gfx_player_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_BOUNCEBLOCK] = asset_editor_gfx_bounceblock_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_DOOR_REGULAR] = asset_editor_gfx_door_regular_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_DOOR_LOCKED] = asset_editor_gfx_door_locked_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_SWITCH_LOCKED] = asset_editor_gfx_switch_locked_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_DOOR_TRAP] = asset_editor_gfx_door_trap_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_SWITCH_TRAP] = asset_editor_gfx_switch_trap_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_CHAINGUN] = asset_editor_gfx_chaingun_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_LASER] = asset_editor_gfx_laser_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_ZAP] = asset_editor_gfx_zap_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_CHASER] = asset_editor_gfx_chaser_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_EXIT_DOOR] = asset_editor_gfx_exit_door_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_EXIT_SWITCH] = asset_editor_gfx_exit_switch_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_FLOORGUARD] = asset_editor_gfx_floorguard_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_GOLD] = asset_editor_gfx_gold_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_LAUNCHPAD] = asset_editor_gfx_launchpad_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_MINE] = asset_editor_gfx_mine_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_ONEWAY] = asset_editor_gfx_oneway_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_ROCKET] = asset_editor_gfx_rocket_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_TURRET] = asset_editor_gfx_turret_SEL;
      MAP_ETYPE_TO_MC_SELECTED[ETYPE_THWOMP] = asset_editor_gfx_thwomp_SEL;
      HELPER_MAP_DIR_TO_VEC[DIR_R] = new vec2(1,0);
      HELPER_MAP_DIR_TO_VEC[DIR_RD] = new vec2(1 / Math.SQRT2,1 / Math.SQRT2);
      HELPER_MAP_DIR_TO_VEC[DIR_D] = new vec2(0,1);
      HELPER_MAP_DIR_TO_VEC[DIR_LD] = new vec2(-1 / Math.SQRT2,1 / Math.SQRT2);
      HELPER_MAP_DIR_TO_VEC[DIR_L] = new vec2(-1,0);
      HELPER_MAP_DIR_TO_VEC[DIR_LU] = new vec2(-1 / Math.SQRT2,-1 / Math.SQRT2);
      HELPER_MAP_DIR_TO_VEC[DIR_U] = new vec2(0,-1);
      HELPER_MAP_DIR_TO_VEC[DIR_RU] = new vec2(1 / Math.SQRT2,-1 / Math.SQRT2);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_PLAYER] = new vec2(10,-1);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_BOUNCEBLOCK] = new vec2(9.6,9.6);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_DOOR_REGULAR] = new vec2(12,-1);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_DOOR_LOCKED] = new vec2(12,-1);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_SWITCH_LOCKED] = new vec2(4,4);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_DOOR_TRAP] = new vec2(12,-1);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_SWITCH_TRAP] = new vec2(4,4);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_CHAINGUN] = new vec2(9,-1);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_LASER] = new vec2(9,-1);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_ZAP] = new vec2(9,-1);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_CHASER] = new vec2(9,-1);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_EXIT_DOOR] = new vec2(12,12);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_EXIT_SWITCH] = new vec2(6,4);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_FLOORGUARD] = new vec2(6,-1);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_GOLD] = new vec2(4,4);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_LAUNCHPAD] = new vec2(8,-1);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_MINE] = new vec2(4,-1);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_ONEWAY] = new vec2(12,-1);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_ROCKET] = new vec2(6,-1);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_TURRET] = new vec2(6,-1);
      HELPER_MAP_ETYPE_TO_COLSHAPE[ETYPE_THWOMP] = new vec2(9,9);
      STRUCT_SIZE[STRUCTTYPE_PLAYER] = 2;
      STRUCT_SIZE[STRUCTTYPE_BOUNCEBLOCK] = 2;
      STRUCT_SIZE[STRUCTTYPE_DOOR_REGULAR] = 3;
      STRUCT_SIZE[STRUCTTYPE_DOOR_LOCKED] = 5;
      STRUCT_SIZE[STRUCTTYPE_DOOR_TRAP] = 5;
      STRUCT_SIZE[STRUCTTYPE_CHAINGUN] = 4;
      STRUCT_SIZE[STRUCTTYPE_LASER] = 4;
      STRUCT_SIZE[STRUCTTYPE_ZAP] = 4;
      STRUCT_SIZE[STRUCTTYPE_CHASER] = 4;
      STRUCT_SIZE[STRUCTTYPE_EXIT] = 4;
      STRUCT_SIZE[STRUCTTYPE_FLOORGUARD] = 2;
      STRUCT_SIZE[STRUCTTYPE_GOLD] = 2;
      STRUCT_SIZE[STRUCTTYPE_LAUNCHPAD] = 3;
      STRUCT_SIZE[STRUCTTYPE_MINE] = 2;
      STRUCT_SIZE[STRUCTTYPE_ONEWAY] = 3;
      STRUCT_SIZE[STRUCTTYPE_ROCKET] = 2;
      STRUCT_SIZE[STRUCTTYPE_TURRET] = 2;
      STRUCT_SIZE[STRUCTTYPE_THWOMP] = 3;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_BOUNCEBLOCK] = edat.ETYPE_BOUNCEBLOCK;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_CHAINGUN] = edat.ETYPE_CHAINGUN;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_CHASER] = edat.ETYPE_CHASER;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_DOOR_LOCKED] = edat.ETYPE_DOOR_LOCKED;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_DOOR_REGULAR] = edat.ETYPE_DOOR_REGULAR;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_DOOR_TRAP] = edat.ETYPE_DOOR_TRAP;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_EXIT] = edat.ETYPE_EXIT_DOOR;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_FLOORGUARD] = edat.ETYPE_FLOORGUARD;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_GOLD] = edat.ETYPE_GOLD;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_LASER] = edat.ETYPE_LASER;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_LAUNCHPAD] = edat.ETYPE_LAUNCHPAD;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_MINE] = edat.ETYPE_MINE;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_ONEWAY] = edat.ETYPE_ONEWAY;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_PLAYER] = edat.ETYPE_PLAYER;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_ROCKET] = edat.ETYPE_ROCKET;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_THWOMP] = edat.ETYPE_THWOMP;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_TURRET] = edat.ETYPE_TURRET;
      MAP_STRUCT_TO_ETYPE[edat.STRUCTTYPE_ZAP] = edat.ETYPE_ZAP;
      
      public function edat()
      {
         super();
      }
      
      public static function GET_WORLDSPACE_POS(param1:Vector.<uint>) : vec2
      {
         return new vec2(param1[EPROP_X] * quantize_step_size,param1[EPROP_Y] * quantize_step_size);
      }
      
      public static function MAP_DIR_TO_VEC(param1:int) : vec2
      {
         return HELPER_MAP_DIR_TO_VEC[param1].Clone();
      }
      
      public static function GET_COLLISION_SHAPE(param1:Vector.<uint>) : vec2
      {
         return HELPER_MAP_ETYPE_TO_COLSHAPE[param1[EPROP_TYPE]].Clone();
      }
   }
}

