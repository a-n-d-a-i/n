package simulation.ninja
{
   import audiovisual.entitygraphics.EntityGraphics_Ninja;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Segment;
   import simulation.collision.colutils;
   import simulation.entities.Entity_Base;
   import simulation.entities.Entity_Thwomp;
   import simulation.entities.collision_result_logical;
   import simulation.entities.collision_result_physical;
   import simulation.inputsource.InputSource_Base;
   import simulation.sim_globals;
   
   public class Ninja
   {
      
      public static const PSTATE_STANDING:uint = 0;
      
      public static const PSTATE_RUNNING:uint = 1;
      
      public static const PSTATE_SKIDDING:uint = 2;
      
      public static const PSTATE_JUMPING:uint = 3;
      
      public static const PSTATE_FALLING:uint = 4;
      
      public static const PSTATE_WALLSLIDING:uint = 5;
      
      public static const PSTATE_DEAD:uint = 6;
      
      public static const PSTATE_AWAITINGDEATH:uint = 7;
      
      public static const PSTATE_CELEBRATING:uint = 8;
      
      public static const PSTATE_DISABLED:uint = 9;
      
      private static const PSTATE_TO_STRING:Vector.<String> = new Vector.<String>(10,true);
      
      PSTATE_TO_STRING[PSTATE_STANDING] = "standing";
      PSTATE_TO_STRING[PSTATE_RUNNING] = "running";
      PSTATE_TO_STRING[PSTATE_SKIDDING] = "skidding";
      PSTATE_TO_STRING[PSTATE_JUMPING] = "jumping";
      PSTATE_TO_STRING[PSTATE_FALLING] = "falling";
      PSTATE_TO_STRING[PSTATE_WALLSLIDING] = "wallsliding";
      PSTATE_TO_STRING[PSTATE_DEAD] = "dead";
      PSTATE_TO_STRING[PSTATE_AWAITINGDEATH] = "waiting to die";
      PSTATE_TO_STRING[PSTATE_CELEBRATING] = "celebration";
      PSTATE_TO_STRING[PSTATE_DISABLED] = "disabled";
      
      public var inputsource:InputSource_Base;
      
      private var pos:vec2;
      
      private var vel:vec2;
      
      private var oldpos:vec2;
      
      private var r:Number;
      
      private var g:Number;
      
      private var d:Number;
      
      private var maxspeedAir:Number;
      
      private var maxspeedGround:Number;
      
      private var groundAccel:Number;
      
      private var airAccel:Number;
      
      private var normGrav:Number;
      
      private var jumpGrav:Number;
      
      private var normDrag:Number;
      
      private var winDrag:Number;
      
      private var wallFriction:Number;
      
      private var skidFriction:Number;
      
      private var standFriction:Number;
      
      private var curState:uint;
      
      private var facingDir:int;
      
      private var max_jump_time:Number;
      
      private var jumptimer:Number;
      
      private var jumpAmt:Number;
      
      private var jump_y_bias:Number;
      
      private var terminal_vel:Number;
      
      private var wasJdown:Boolean;
      
      private var oldv:vec2;
      
      private var WAS_IN_AIR:Boolean;
      
      private var IN_AIR:Boolean;
      
      private var NEAR_WALL:Boolean;
      
      private var wallN:vec2;
      
      private var floorN:vec2;
      
      private var fcount:int;
      
      private var fvec:vec2;
      
      private var impulse_scale:Number;
      
      private var pID:int;
      
      private var raggy:Ragdoll;
      
      private var ninja_gfx:EntityGraphics_Ninja;
      
      private var crush_threshold:Number;
      
      private var crush_vec:vec2;
      
      private var crush_dist:Number;
      
      private var crush_flag:Boolean;
      
      private var death_type:int;
      
      private var death_pos:vec2;
      
      private var death_force:vec2;
      
      private var TEMP_near_pos:vec2;
      
      private var objList:Vector.<Entity_Base>;
      
      private var segList:Vector.<Segment>;
      
      private var seg_cp:vec2;
      
      private var wallList_X:Vector.<Number>;
      
      private var wallList_Y:Vector.<Number>;
      
      private var result_logical:collision_result_logical;
      
      private var result_physical:collision_result_physical;
      
      private var cp:vec2;
      
      private var tempV:vec2;
      
      private var tempP:vec2;
      
      private var public_pos:vec2;
      
      private var public_vel:vec2;
      
      private var gfxColor:uint;
      
      public function Ninja(param1:int, param2:InputSource_Base, param3:Number, param4:Number, param5:uint = 0)
      {
         super();
         this.pID = param1;
         this.inputsource = param2;
         this.gfxColor = param5;
         this.pos = new vec2(param3,param4);
         this.vel = new vec2(0,0);
         this.oldpos = new vec2(0,0);
         this.r = 10;
         this.impulse_scale = 40 / sim_globals.sim_rate;
         this.maxspeedAir = this.r * 0.5 * (40 / sim_globals.sim_rate);
         this.maxspeedGround = this.r * 0.5 * (40 / sim_globals.sim_rate);
         this.groundAccel = 0.15 * (40 / sim_globals.sim_rate) * (40 / sim_globals.sim_rate);
         this.airAccel = 0.1 * (40 / sim_globals.sim_rate) * (40 / sim_globals.sim_rate);
         this.normGrav = 0.15 * (40 / sim_globals.sim_rate) * (40 / sim_globals.sim_rate);
         this.jumpGrav = 0.025 * (40 / sim_globals.sim_rate) * (40 / sim_globals.sim_rate);
         this.normDrag = Math.pow(0.99,40 / sim_globals.sim_rate);
         this.winDrag = Math.pow(0.8,40 / sim_globals.sim_rate);
         this.wallFriction = Math.pow(0.87,40 / sim_globals.sim_rate);
         this.skidFriction = Math.pow(0.92,40 / sim_globals.sim_rate);
         this.standFriction = Math.pow(0.8,40 / sim_globals.sim_rate);
         this.g = this.normGrav;
         this.d = this.normDrag;
         this.curState = PSTATE_DISABLED;
         this.facingDir = 1;
         this.jumpAmt = 1;
         this.jump_y_bias = 2;
         this.max_jump_time = 30 * (sim_globals.sim_rate / 40);
         this.terminal_vel = this.r * 0.9 * (40 / sim_globals.sim_rate);
         this.jumptimer = 0;
         this.wasJdown = false;
         this.WAS_IN_AIR = false;
         this.oldv = new vec2(0,0);
         this.IN_AIR = false;
         this.NEAR_WALL = false;
         this.wallN = new vec2(0,0);
         this.floorN = new vec2(0,-1);
         this.fcount = 1;
         this.fvec = new vec2();
         this.raggy = new Ragdoll();
         this.ninja_gfx = null;
         this.crush_threshold = 0.05;
         this.crush_vec = new vec2();
         this.crush_dist = 0;
         this.crush_flag = false;
         this.death_type = sim_globals.DEATHTYPE_TIME;
         this.death_pos = new vec2();
         this.death_force = new vec2();
         this.TEMP_near_pos = new vec2();
         this.objList = new Vector.<Entity_Base>();
         this.segList = new Vector.<Segment>();
         this.seg_cp = new vec2();
         this.wallList_X = new Vector.<Number>();
         this.wallList_Y = new Vector.<Number>();
         this.result_logical = new collision_result_logical();
         this.result_physical = new collision_result_physical();
         this.cp = new vec2();
         this.tempV = new vec2();
         this.tempP = new vec2();
         this.public_pos = new vec2();
         this.public_vel = new vec2();
      }
      
      public function DEBUG_SetPosVel(param1:vec2, param2:vec2) : void
      {
         if(this.curState == PSTATE_DEAD)
         {
            this.raggy.TESTING_SetPosVel(param1,param2);
         }
         else
         {
            this.pos.Copy(param1);
            this.vel.Copy(param2);
         }
      }
      
      public function DEBUG_Respawn(param1:vec2) : void
      {
         this.curState = PSTATE_STANDING;
         this.pos.x = param1.x;
         this.pos.y = param1.y;
         this.vel.x = 0;
         this.vel.y = 0;
         this.g = this.normGrav;
         this.d = this.normDrag;
      }
      
      public function GetIndex() : int
      {
         return this.pID;
      }
      
      public function GetPos() : vec2
      {
         this.public_pos.Copy(this.pos);
         return this.public_pos;
      }
      
      public function GetVel() : vec2
      {
         this.public_vel.Copy(this.vel);
         return this.public_vel;
      }
      
      public function GetRadius() : Number
      {
         return this.r;
      }
      
      public function IsDead() : Boolean
      {
         return this.curState == PSTATE_DEAD || this.curState == PSTATE_DISABLED;
      }
      
      public function DEBUG_GetRagdoll() : Ragdoll
      {
         return this.raggy;
      }
      
      public function APP_Enable() : void
      {
         this.curState = PSTATE_STANDING;
      }
      
      public function APP_Disable() : void
      {
         this.curState = PSTATE_DISABLED;
      }
      
      public function Integrate() : void
      {
         if(this.curState != PSTATE_DISABLED)
         {
            if(this.curState == PSTATE_DEAD)
            {
               this.raggy.Integrate(this.normGrav);
            }
            else
            {
               this.vel.x *= this.d;
               this.vel.y *= this.d;
               this.vel.y += this.g;
               this.pos.x += this.vel.x;
               this.pos.y += this.vel.y;
            }
         }
      }
      
      public function PreCollision() : void
      {
         if(this.curState != PSTATE_DISABLED)
         {
            if(this.curState == PSTATE_DEAD)
            {
               this.raggy.PreCollision();
            }
            else
            {
               this.oldv.x = this.vel.x;
               this.oldv.y = this.vel.y;
               this.fcount = 0;
               this.fvec.x = 0;
               this.fvec.y = 0;
               this.crush_vec.x = 0;
               this.crush_vec.y = 0;
               this.crush_dist = 0;
               this.crush_flag = false;
            }
         }
      }
      
      public function SolveInternalConstraints() : void
      {
         if(this.curState == PSTATE_DEAD)
         {
            this.raggy.SolveConstraints();
         }
      }
      
      public function PostCollision(param1:Simulator) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:Entity_Base = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         if(this.curState != PSTATE_DISABLED)
         {
            if(this.curState == PSTATE_DEAD)
            {
               this.raggy.PostCollision(param1);
            }
            else
            {
               this.oldpos.Copy(this.pos);
               _loc2_ = 0.1;
               this.wallList_X.length = 0;
               this.wallList_Y.length = 0;
               this.result_logical.Clear();
               param1.objGrid.GatherCellContentsInNeighbourhood(this.pos,this.objList);
               _loc3_ = 0;
               while(_loc3_ < this.objList.length)
               {
                  _loc6_ = this.objList[_loc3_];
                  if(_loc6_.CollideVsCircle_Logical(param1,this,this.result_logical,this.pos,this.vel,this.oldpos,this.r,_loc2_))
                  {
                     if(this.result_logical.vec_y == 0)
                     {
                        this.wallList_X.push(this.result_logical.vec_x);
                        this.wallList_Y.push(this.result_logical.vec_y);
                     }
                  }
                  _loc3_++;
               }
               _loc4_ = this.r + _loc2_;
               param1.segGrid.GatherCellContentsFromWorldspaceRegion(this.pos.x - _loc4_,this.pos.y - _loc4_,this.pos.x + _loc4_,this.pos.y + _loc4_,this.segList);
               _loc5_ = 0;
               while(_loc5_ < this.segList.length)
               {
                  this.segList[_loc5_].GetClosestPoint(this.pos,this.seg_cp);
                  _loc7_ = this.pos.x - this.seg_cp.x;
                  _loc8_ = this.pos.y - this.seg_cp.y;
                  _loc9_ = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_);
                  if(_loc8_ == 0 && _loc9_ <= _loc4_ && _loc9_ != 0)
                  {
                     _loc7_ *= 1 / _loc9_;
                     _loc8_ *= 1 / _loc9_;
                     this.wallList_X.push(_loc7_);
                     this.wallList_Y.push(_loc8_);
                  }
                  _loc5_++;
               }
               this.WAS_IN_AIR = this.IN_AIR;
               this.IN_AIR = true;
               this.NEAR_WALL = false;
               if(this.wallList_X.length > 0)
               {
                  this.NEAR_WALL = true;
                  this.wallN.x = this.wallList_X[0];
                  this.wallN.y = 0;
               }
               if(this.fcount > 0)
               {
                  this.IN_AIR = false;
                  _loc10_ = this.fvec.Len();
                  if(_loc10_ == 0)
                  {
                     trace("WARNING! Ninja found a null floor vector: " + this.fvec.ToString());
                     this.floorN.x = 0;
                     this.floorN.y = -1;
                  }
                  else
                  {
                     this.floorN.x = this.fvec.x / _loc10_;
                     this.floorN.y = this.fvec.y / _loc10_;
                  }
                  if(this.WAS_IN_AIR)
                  {
                     _loc11_ = this.oldv.x * this.floorN.x + this.oldv.y * this.floorN.y;
                     _loc11_ = _loc11_ - 2 * Math.abs(this.floorN.y) * this.impulse_scale;
                     if(_loc11_ < -this.terminal_vel)
                     {
                        this.vel.Copy(this.oldv);
                        param1.Event_PlayerWasKilled(this,sim_globals.ENEMYTYPE_FALL,this.pos.x,this.pos.y,0,0);
                     }
                  }
               }
               if(this.crush_flag)
               {
                  if(this.crush_dist > 0)
                  {
                     _loc12_ = this.crush_vec.Len();
                     _loc13_ = _loc12_ / this.crush_dist;
                     if(_loc13_ < this.crush_threshold)
                     {
                        param1.Event_PlayerWasKilled(this,sim_globals.ENEMYTYPE_CRUSH,this.pos.x,this.pos.y,0,0);
                     }
                  }
               }
            }
         }
      }
      
      private function RespondToCollision(param1:Number, param2:Number, param3:Number, param4:Boolean, param5:Boolean) : void
      {
         var _loc6_:Number = NaN;
         this.pos.x += param3 * param1;
         this.pos.y += param3 * param2;
         if(param5)
         {
            this.crush_flag = true;
         }
         if(param4 || param5)
         {
            this.crush_vec.x += param3 * param1;
            this.crush_vec.y += param3 * param2;
            this.crush_dist += Math.abs(param3);
         }
         if(param4)
         {
            _loc6_ = this.vel.x * param1 + this.vel.y * param2;
            if(_loc6_ < 0)
            {
               this.vel.x -= _loc6_ * param1;
               this.vel.y -= _loc6_ * param2;
            }
         }
         else
         {
            this.vel.x += param3 * param1;
            this.vel.y += param3 * param2;
         }
         if(param2 < 0)
         {
            ++this.fcount;
            this.fvec.x += param1;
            this.fvec.y += param2;
         }
      }
      
      public function CollideVsObjects(param1:Simulator) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Entity_Base = null;
         var _loc4_:* = false;
         if(this.curState == PSTATE_DEAD)
         {
            this.raggy.CollideVsObjects(param1);
         }
         else
         {
            this.result_physical.Clear();
            param1.objGrid.GatherCellContentsInNeighbourhood(this.pos,this.objList);
            _loc2_ = 0;
            while(_loc2_ < this.objList.length)
            {
               _loc3_ = this.objList[_loc2_];
               if(_loc3_.CollideVsCircle_Physical(this.result_physical,this.pos,this.vel,this.oldpos,this.r))
               {
                  _loc4_ = _loc3_ is Entity_Thwomp;
                  this.RespondToCollision(this.result_physical.nx,this.result_physical.ny,this.result_physical.pen,this.result_physical.isHardCollision,_loc4_);
               }
               _loc2_++;
            }
         }
      }
      
      public function CollideVsTiles(param1:Simulator) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(this.curState == PSTATE_DEAD)
         {
            this.raggy.CollideVsTiles(param1);
         }
         else
         {
            _loc2_ = 32;
            _loc3_ = 0;
            this.cp.x = 0;
            this.cp.y = 0;
            while(true)
            {
               _loc4_ = colutils.GetSingleClosestPoint_Signed(param1.segGrid,this.pos,this.r,this.cp);
               if(_loc4_ == 0)
               {
                  break;
               }
               _loc5_ = this.pos.x - this.cp.x;
               _loc6_ = this.pos.y - this.cp.y;
               _loc7_ = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_);
               _loc8_ = this.r - _loc4_ * _loc7_;
               if(_loc8_ < 1e-7)
               {
                  break;
               }
               if(_loc7_ == 0)
               {
                  return;
               }
               _loc5_ /= _loc7_;
               _loc6_ /= _loc7_;
               this.RespondToCollision(_loc5_,_loc6_,_loc4_ * _loc8_,true,false);
               _loc3_++;
               if(_loc3_ >= _loc2_)
               {
                  trace("WARNING! collision loop hit max iterations: " + _loc8_);
                  break;
               }
            }
         }
      }
      
      public function Think(param1:Simulator, param2:uint) : void
      {
         var _loc10_:Vector.<vec2> = null;
         var _loc11_:Vector.<vec2> = null;
         var _loc12_:* = false;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc30_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc33_:Number = NaN;
         var _loc34_:Number = NaN;
         var _loc35_:Number = NaN;
         var _loc36_:Number = NaN;
         var _loc37_:Number = NaN;
         var _loc38_:Number = NaN;
         var _loc39_:Number = NaN;
         var _loc40_:Number = NaN;
         var _loc41_:Number = NaN;
         this.inputsource.Tick(param2);
         var _loc3_:Boolean = this.inputsource.IsButtonDown_Right();
         var _loc4_:Boolean = this.inputsource.IsButtonDown_Left();
         var _loc5_:Boolean = this.inputsource.IsButtonDown_Jump();
         var _loc6_:Boolean = (_loc5_) && !this.wasJdown;
         this.wasJdown = _loc5_;
         if(this.curState == PSTATE_DISABLED)
         {
            return;
         }
         if(this.curState == PSTATE_DEAD)
         {
            return;
         }
         if(this.curState == PSTATE_AWAITINGDEATH)
         {
            _loc10_ = null;
            _loc11_ = null;
            if(this.ninja_gfx != null && this.ninja_gfx.hasValidPose)
            {
               _loc10_ = new Vector.<vec2>(6,true);
               _loc11_ = new Vector.<vec2>(6,true);
               this.ninja_gfx.NINJA_GetCurrentPose(_loc10_,_loc11_);
            }
            this.raggy.ActivateRagdoll(this.pos,this.vel,this.death_pos,this.death_force,_loc10_,_loc11_);
            if(this.death_type == sim_globals.DEATHTYPE_EXPLOSIVE || this.death_type == sim_globals.DEATHTYPE_SUICIDE)
            {
               this.raggy.ExplodeRagdoll(param1);
            }
            param1.HACKY_GetParticleManager().Spawn_BloodSpurt(this.death_pos.x,this.death_pos.y,this.death_force.x,this.death_force.y,3 + Math.floor(Math.random() * 4));
            _loc12_ = Math.random() < 0.5;
            if(this.death_type == sim_globals.DEATHTYPE_EXPLOSIVE)
            {
               if(_loc12_)
               {
                  this.ninja_gfx.HACKY_PlayOneshotSound("explode1");
               }
               else
               {
                  this.ninja_gfx.HACKY_PlayOneshotSound("explode2");
               }
            }
            else if(this.death_type == sim_globals.DEATHTYPE_FALL)
            {
               this.ninja_gfx.HACKY_PlayOneshotSound("fall");
            }
            else if(this.death_type == sim_globals.DEATHTYPE_LASER)
            {
               this.ninja_gfx.HACKY_PlayOneshotSound("laser");
            }
            else if(this.death_type == sim_globals.DEATHTYPE_ELECTRIC)
            {
               if(_loc12_)
               {
                  this.ninja_gfx.HACKY_PlayOneshotSound("zap1");
               }
               else
               {
                  this.ninja_gfx.HACKY_PlayOneshotSound("zap2");
               }
            }
            else if(_loc12_)
            {
               this.ninja_gfx.HACKY_PlayOneshotSound("shot1");
            }
            else
            {
               this.ninja_gfx.HACKY_PlayOneshotSound("shot2");
            }
            this.curState = PSTATE_DEAD;
            return;
         }
         if(this.curState == PSTATE_CELEBRATING)
         {
            if(this.IN_AIR)
            {
               this.d = this.normDrag;
               if(this.WAS_IN_AIR)
               {
               }
            }
            else
            {
               this.d = this.winDrag;
               if(this.WAS_IN_AIR)
               {
               }
            }
            return;
         }
         this.tempV.x = 0;
         this.tempV.y = 0;
         this.tempP.x = 0;
         this.tempP.y = 0;
         var _loc7_:Number = this.vel.x;
         var _loc8_:Number = this.vel.y;
         var _loc9_:Number = 0;
         if(_loc4_)
         {
            _loc9_--;
         }
         if(_loc3_)
         {
            _loc9_ += 1;
         }
         if(this.IN_AIR)
         {
            this.tempV.Copy(this.vel);
            _loc13_ = _loc7_ + _loc9_ * this.airAccel;
            if(Math.abs(_loc13_) < this.maxspeedAir)
            {
               _loc7_ = _loc13_;
            }
            this.vel.x = _loc7_;
            if(this.curState < 3)
            {
               this.ACTION_Fall();
               return;
            }
            if(this.curState == PSTATE_JUMPING)
            {
               ++this.jumptimer;
               if(!_loc5_ || this.jumptimer > this.max_jump_time)
               {
                  this.ACTION_Fall();
                  return;
               }
               return;
            }
            if(this.curState == PSTATE_FALLING)
            {
            }
            if(this.NEAR_WALL)
            {
               if(_loc6_)
               {
                  _loc14_ = 0;
                  _loc15_ = 0;
                  if(this.curState == PSTATE_WALLSLIDING && _loc9_ * this.wallN.x < 0)
                  {
                     _loc14_ = 1;
                     _loc15_ = 0.5;
                  }
                  else
                  {
                     _loc14_ = 1.5;
                     _loc15_ = 0.7;
                  }
                  param1.HACKY_GetParticleManager().Spawn_JumpDust(this.pos.x - this.wallN.x * this.r,this.pos.y - this.wallN.y * this.r,this.wallN.x * 90);
                  this.ACTION_Jump(this.wallN.x * _loc14_,this.wallN.y - _loc15_);
                  return;
               }
               if(this.curState == PSTATE_WALLSLIDING)
               {
                  if(0 < _loc9_ * this.wallN.x)
                  {
                     this.ACTION_Fall();
                     return;
                  }
                  _loc16_ = Math.abs(_loc8_);
                  _loc17_ = -this.wallFriction * _loc16_;
                  this.tempV.Copy(this.vel);
                  this.vel.y *= this.wallFriction;
                  param1.HACKY_GetParticleManager().Spawn_WallDust(this.pos,this.r,this.wallN,Math.min(4,_loc16_));
                  return;
               }
               if(0 < _loc8_ && _loc9_ * this.wallN.x < 0)
               {
                  this.ACTION_Wallslide();
                  return;
               }
            }
            else if(this.curState == PSTATE_WALLSLIDING)
            {
               this.ACTION_Fall();
               return;
            }
         }
         else
         {
            this.tempV.Copy(this.vel);
            _loc18_ = _loc7_ + _loc9_ * this.groundAccel;
            if(Math.abs(_loc18_) < this.maxspeedGround)
            {
               _loc7_ = _loc18_;
            }
            this.vel.x = _loc7_;
            if(2 < this.curState)
            {
               param1.HACKY_GetParticleManager().Spawn_LandDust(this.pos.x - this.floorN.x * this.r,this.pos.y - this.floorN.y * this.r,90 + Math.atan2(this.floorN.y,this.floorN.x) / Math.PI * 180,Math.abs(this.vel.x) + this.vel.y);
               this.ninja_gfx.HACKY_PlayOneshotSound("land");
               if(0 < _loc7_ * _loc9_)
               {
                  this.ACTION_Run(_loc9_);
                  return;
               }
               this.ACTION_Skid();
               return;
            }
            if(_loc6_)
            {
               param1.HACKY_GetParticleManager().Spawn_JumpDust(this.pos.x - this.floorN.x * this.r,this.pos.y - this.floorN.y * this.r,90 + Math.atan2(this.floorN.y,this.floorN.x) / Math.PI * 180);
               if(_loc9_ * this.floorN.x < 0)
               {
                  this.ACTION_Jump(0,-0.7);
                  return;
               }
               this.ACTION_Jump(this.floorN.x,this.floorN.y);
               return;
            }
            if(this.curState != PSTATE_RUNNING)
            {
               if(this.curState == PSTATE_SKIDDING)
               {
                  _loc29_ = this.floorN.x;
                  _loc30_ = this.floorN.y;
                  _loc31_ = Math.abs(_loc7_ * -_loc30_ + _loc8_ * _loc29_);
                  _loc32_ = _loc7_ * _loc31_;
                  if(0 < _loc32_ * _loc9_)
                  {
                     this.ACTION_Run(_loc9_);
                     return;
                  }
                  if(_loc31_ < 0.1 && this.floorN.x == 0)
                  {
                     this.ACTION_Stand();
                     return;
                  }
                  _loc33_ = 1;
                  if(_loc32_ < 0)
                  {
                     _loc33_ = -1;
                  }
                  _loc34_ = Math.atan2(this.floorN.x,-this.floorN.y) * (180 / Math.PI);
                  param1.HACKY_GetParticleManager().Spawn_FloorDust(this.pos,this.r,this.floorN,_loc34_,_loc33_,_loc31_);
                  this.tempV.Copy(this.vel);
                  if(_loc8_ < 0 && this.floorN.x != 0)
                  {
                     _loc35_ = Math.abs(_loc7_ * this.skidFriction - _loc7_);
                     _loc36_ = Math.abs(_loc35_ * this.floorN.y);
                     _loc36_ = _loc36_ * (this.floorN.y * this.floorN.y);
                     _loc37_ = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_);
                     _loc38_ = _loc37_ - _loc36_;
                     _loc7_ /= _loc37_;
                     _loc8_ /= _loc37_;
                     _loc7_ *= _loc38_;
                     _loc8_ *= _loc38_;
                  }
                  else
                  {
                     _loc7_ *= this.skidFriction;
                  }
                  this.vel.x = _loc7_;
                  this.vel.y = _loc8_;
                  return;
               }
               if(_loc9_ != 0)
               {
                  this.ACTION_Run(_loc9_);
                  return;
               }
               _loc39_ = this.floorN.x;
               _loc40_ = this.floorN.y;
               _loc41_ = Math.abs(_loc7_ * -_loc40_ + _loc8_ * _loc39_);
               if(0.1 <= _loc41_)
               {
                  this.ACTION_Skid();
                  return;
               }
               this.tempV.Copy(this.vel);
               _loc7_ *= this.standFriction;
               this.vel.x = _loc7_;
               this.vel.y = _loc8_;
               return;
            }
            _loc19_ = this.floorN.x;
            _loc20_ = this.floorN.y;
            _loc21_ = _loc7_ * -_loc20_ + _loc8_ * _loc19_;
            _loc22_ = Math.abs(_loc21_);
            _loc23_ = _loc7_ * _loc22_;
            if(_loc9_ * _loc23_ <= 0)
            {
               this.ACTION_Skid();
               return;
            }
            if(_loc9_ * _loc19_ < 0)
            {
               _loc24_ = -Math.abs(_loc19_);
               _loc25_ = _loc20_;
               if(_loc19_ < 0)
               {
                  _loc25_ = -_loc20_;
               }
               _loc26_ = Math.abs(_loc20_);
               _loc25_ *= 0.5 * _loc26_;
               _loc24_ *= 0.5 * _loc26_;
               _loc27_ = _loc7_ + _loc25_ * this.groundAccel;
               _loc28_ = _loc8_ + _loc24_ * this.groundAccel;
               if(Math.abs(_loc18_) < this.maxspeedGround)
               {
                  _loc7_ = _loc27_;
                  _loc8_ = _loc28_;
               }
               this.tempV.Copy(this.vel);
               this.vel.x = _loc7_;
               this.vel.y = _loc8_;
            }
         }
      }
      
      public function DEATHMATCH_IsInAir() : Boolean
      {
         return this.IN_AIR;
      }
      
      public function DEATHMATCH_Jump(param1:Number) : void
      {
         this.ACTION_Jump(0,param1);
      }
      
      private function ACTION_Jump(param1:Number, param2:Number) : void
      {
         this.HELPER_ExitCurrentState();
         this.curState = PSTATE_JUMPING;
         this.g = this.jumpGrav;
         var _loc3_:Number = this.vel.x;
         var _loc4_:Number = this.vel.y;
         if(_loc3_ * param1 < 0)
         {
            this.vel.x = 0;
         }
         if(_loc4_ * param2 < 0)
         {
            this.vel.y = 0;
         }
         this.pos.x += param1 * this.jumpAmt * this.impulse_scale;
         this.pos.y += param2 * (this.jumpAmt + this.jump_y_bias) * this.impulse_scale;
         this.vel.x += param1 * this.jumpAmt * this.impulse_scale;
         this.vel.y += param2 * (this.jumpAmt + this.jump_y_bias) * this.impulse_scale;
         this.jumptimer = 0;
         this.ninja_gfx.HACKY_PlayOneshotSound("jump");
      }
      
      private function ACTION_Fall() : void
      {
         this.HELPER_ExitCurrentState();
         this.curState = PSTATE_FALLING;
      }
      
      private function ACTION_Wallslide() : void
      {
         this.HELPER_ExitCurrentState();
         this.curState = PSTATE_WALLSLIDING;
      }
      
      private function ACTION_Skid() : void
      {
         this.HELPER_ExitCurrentState();
         this.curState = PSTATE_SKIDDING;
      }
      
      private function ACTION_Run(param1:Number) : void
      {
         this.HELPER_ExitCurrentState();
         this.curState = PSTATE_RUNNING;
      }
      
      private function ACTION_Stand() : void
      {
         this.HELPER_ExitCurrentState();
         this.curState = PSTATE_STANDING;
      }
      
      private function ACTION_Die() : void
      {
         this.HELPER_ExitCurrentState();
         this.curState = PSTATE_AWAITINGDEATH;
      }
      
      private function ACTION_Win() : void
      {
         this.HELPER_ExitCurrentState();
         this.curState = PSTATE_CELEBRATING;
      }
      
      private function HELPER_ExitCurrentState() : void
      {
         if(this.curState == PSTATE_DEAD)
         {
            trace("WARNING! HELPER_ExitCurrentState() was called on a dead player!: " + this.pID);
         }
         if(this.curState == PSTATE_JUMPING)
         {
            this.g = this.normGrav;
         }
      }
      
      public function SIM_Launch(param1:Number, param2:Number) : void
      {
         if(this.curState == PSTATE_AWAITINGDEATH)
         {
            return;
         }
         this.pos.x += param1 * this.impulse_scale;
         this.pos.y += param2 * this.impulse_scale;
         this.vel.x = param1 * this.impulse_scale;
         this.vel.y = param2 * this.impulse_scale;
         this.fcount = 0;
         if(this.curState != PSTATE_CELEBRATING)
         {
            this.ACTION_Fall();
         }
      }
      
      public function SIM_Kill(param1:int, param2:Number, param3:Number, param4:Number, param5:Number) : Boolean
      {
         if(this.curState == PSTATE_AWAITINGDEATH || this.curState == PSTATE_DISABLED)
         {
            return false;
         }
         this.death_pos.x = param2;
         this.death_pos.y = param3;
         this.death_force.x = param4;
         this.death_force.y = param5;
         this.death_type = sim_globals.ETYPE_TO_DTYPE[param1];
         this.ACTION_Die();
         return true;
      }
      
      public function SIM_Win() : Boolean
      {
         if(this.curState == PSTATE_DISABLED || this.curState == PSTATE_CELEBRATING || this.curState == PSTATE_AWAITINGDEATH || this.curState == PSTATE_DEAD)
         {
            return false;
         }
         this.ACTION_Win();
         return true;
      }
      
      public function GenerateGraphicComponent() : EntityGraphics_Ninja
      {
         this.ninja_gfx = new EntityGraphics_Ninja(this,this.gfxColor);
         return this.ninja_gfx;
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_Ninja) : void
      {
         if(this.curState == PSTATE_DISABLED)
         {
            param1.anim = EntityGraphics_Ninja.ANIM_OFF;
         }
         else if(this.curState == PSTATE_DEAD)
         {
            param1.anim = EntityGraphics_Ninja.ANIM_DEAD;
            this.raggy.GFX_UpdateState(param1);
         }
         else
         {
            param1.pos.x = this.pos.x;
            param1.pos.y = this.pos.y;
            if(this.curState == PSTATE_WALLSLIDING)
            {
               param1.anim = EntityGraphics_Ninja.ANIM_WALLSLIDING;
               param1.orn = 0;
               param1.facing = -this.wallN.x;
               param1.vel = this.vel.y;
            }
            else
            {
               if(this.IN_AIR)
               {
                  param1.anim = EntityGraphics_Ninja.ANIM_INAIR;
                  param1.vel = this.vel.y;
                  if(this.curState == PSTATE_JUMPING)
                  {
                     param1.orn = 0;
                  }
                  else
                  {
                     param1.orn -= 0.1 * param1.orn;
                  }
               }
               else
               {
                  param1.orn = Math.atan2(this.floorN.y,this.floorN.x) + 0.5 * Math.PI;
                  if(this.curState == PSTATE_RUNNING)
                  {
                     param1.anim = EntityGraphics_Ninja.ANIM_RUNNING;
                     param1.vel = Math.abs(this.vel.x * -this.floorN.y + this.vel.y * this.floorN.x);
                  }
                  else if(this.curState == PSTATE_SKIDDING)
                  {
                     param1.anim = EntityGraphics_Ninja.ANIM_SKIDDING;
                     param1.vel = this.vel.x * -this.floorN.y + this.vel.y * this.floorN.x;
                  }
                  else if(this.curState == PSTATE_STANDING)
                  {
                     param1.anim = EntityGraphics_Ninja.ANIM_STANDING;
                  }
                  else if(this.curState == PSTATE_CELEBRATING)
                  {
                     param1.anim = EntityGraphics_Ninja.ANIM_CELEBRATING;
                  }
               }
               if(this.vel.x < -0.01)
               {
                  param1.facing = -1;
               }
               else if(this.vel.x > 0.01)
               {
                  param1.facing = 1;
               }
            }
         }
      }
      
      public function Draw(param1:SimpleRenderer) : void
      {
         var _loc2_:* = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:vec2 = null;
         var _loc6_:vec2 = null;
         if(this.curState == PSTATE_DEAD)
         {
            this.raggy.Draw(param1);
         }
         else
         {
            param1.SetStyle(0,0,20);
            param1.DrawCircle(this.oldpos.x,this.oldpos.y,this.r);
            param1.SetStyle(0,0,100);
            param1.DrawCircle(this.pos.x,this.pos.y,this.r);
            _loc2_ = PSTATE_TO_STRING[this.curState];
            if(this.curState == PSTATE_CELEBRATING)
            {
               if(this.IN_AIR)
               {
                  _loc2_ += " (in air)";
               }
               else
               {
                  _loc2_ += " (on ground)";
               }
            }
            param1.DrawStringAtPosition(_loc2_,this.pos.x + this.r,this.pos.y + this.r);
            if(!this.IN_AIR)
            {
               param1.SetStyle(0,8921634,100);
               _loc6_ = new vec2(this.pos.x - this.floorN.x * this.r,this.pos.y - this.floorN.y * this.r);
               param1.DrawSquare(_loc6_.x,_loc6_.y,2);
               param1.DrawLine(_loc6_.x,_loc6_.y,_loc6_.x + this.floorN.x * 8,_loc6_.y + this.floorN.y * 8);
            }
            _loc3_ = 0;
            _loc4_ = 1;
            if(this.curState == PSTATE_WALLSLIDING)
            {
               _loc3_ = 0;
               _loc4_ = -this.wallN.x;
            }
            else
            {
               if(this.curState == PSTATE_JUMPING)
               {
                  _loc3_ = 0;
               }
               if(this.IN_AIR)
               {
                  _loc3_ -= 0.1 * _loc3_;
               }
               else
               {
                  _loc3_ = Math.atan2(this.floorN.y,this.floorN.x) + 0.5 * Math.PI;
               }
               if(this.vel.x < 0)
               {
                  _loc4_ = -1;
               }
               else
               {
                  _loc4_ = 1;
               }
            }
            _loc5_ = new vec2(Math.cos(_loc3_),Math.sin(_loc3_));
            _loc5_.Scale(this.r * _loc4_);
            param1.SetStyle(0,0,100);
            param1.DrawLine(this.pos.x,this.pos.y,this.pos.x + _loc5_.x,this.pos.y + _loc5_.y);
         }
      }
   }
}

