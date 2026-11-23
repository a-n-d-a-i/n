package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_Rocket;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Entity;
   import simulation.collision.Segment;
   import simulation.collision.colutils;
   import simulation.ninja.Ninja;
   import simulation.sim_globals;
   
   public class Entity_Rocket extends Entity_Base
   {
      
      private static const STATE_IDLE:int = 0;
      
      private static const STATE_PREFIRE:int = 1;
      
      private static const STATE_HOMING:int = 2;
      
      private var maxspeed:Number;
      
      private var accel_start:Number;
      
      private var accel_rate:Number;
      
      private var turn_rate:Number;
      
      private var prefire_delay:Number;
      
      private var prediction_scale:Number;
      
      private var gfx_PREV_STATE:int;
      
      private var pos:vec2;
      
      private var rocket_pos:vec2;
      
      private var rocket_dir:vec2;
      
      private var rocket_speed:Number;
      
      private var rocket_accel:Number;
      
      private var shot_timer:Number;
      
      private var CUR_STATE:int;
      
      private var targetIndex:int;
      
      private var nearSegs:Vector.<Segment>;
      
      private var old_pos:vec2;
      
      private var rocket_vel:vec2;
      
      private var hit_pos:vec2;
      
      private var hit_n:vec2;
      
      public function Entity_Rocket(param1:Grid_Entity, param2:Number, param3:Number)
      {
         super();
         this.accel_start = 0.1 * (40 / sim_globals.sim_rate) * (40 / sim_globals.sim_rate);
         this.maxspeed = 12 * (2 / 7) * (40 / sim_globals.sim_rate);
         this.accel_rate = Math.pow(1.1,40 / sim_globals.sim_rate);
         this.turn_rate = 0.1 * (40 / sim_globals.sim_rate);
         this.prefire_delay = 10 * (sim_globals.sim_rate / 40);
         this.prediction_scale = sim_globals.sim_rate / 40;
         this.pos = new vec2(param2,param3);
         this.rocket_pos = new vec2(param2,param3);
         this.rocket_dir = new vec2(1,0);
         this.rocket_speed = 0;
         this.rocket_accel = this.accel_start;
         this.shot_timer = 0;
         this.CUR_STATE = STATE_IDLE;
         this.targetIndex = -1;
         this.gfx_PREV_STATE = this.CUR_STATE;
         this.nearSegs = new Vector.<Segment>();
         this.old_pos = new vec2();
         this.rocket_vel = new vec2();
         this.hit_pos = new vec2();
         this.hit_n = new vec2();
      }
      
      override public function CollideVsCircle_Logical(param1:Simulator, param2:Ninja, param3:collision_result_logical, param4:vec2, param5:vec2, param6:vec2, param7:Number, param8:Number) : Boolean
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         if(this.CUR_STATE != STATE_HOMING)
         {
            trace("WARNING! rocket.CollideVsPlayer() was called with a rocket that\'s not active.. this should be impossible, the rocket shouldn\'t be in the grid?! " + this.CUR_STATE);
            return false;
         }
         if(colutils.Overlap_Circle_Vs_Circle(this.rocket_pos,0,param4,param7))
         {
            this.Event_Explode(param1);
            _loc9_ = param4.x - this.rocket_pos.x;
            _loc10_ = param4.y - this.rocket_pos.y;
            if(param2 == null)
            {
               param3.vec_x = _loc9_ * 4;
               param3.vec_y = _loc10_ * 4;
               return true;
            }
            param1.Event_PlayerWasKilled(param2,sim_globals.ENEMYTYPE_ROCKET,this.rocket_pos.x,this.rocket_pos.y,_loc9_,_loc10_);
         }
         return false;
      }
      
      override public function Think(param1:Simulator) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:Segment = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
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
         this.gfx_PREV_STATE = this.CUR_STATE;
         if(this.CUR_STATE == STATE_IDLE)
         {
            _loc2_ = entity_helpers.TryToAquireTarget(this.pos,param1.playerList,param1.segGrid);
            if(0 <= _loc2_)
            {
               this.shot_timer = 0;
               this.CUR_STATE = STATE_PREFIRE;
               this.targetIndex = _loc2_;
            }
         }
         else if(this.CUR_STATE == STATE_PREFIRE)
         {
            if(param1.playerList[this.targetIndex].IsDead())
            {
               this.CUR_STATE = STATE_IDLE;
            }
            else
            {
               ++this.shot_timer;
               if(this.prefire_delay <= this.shot_timer)
               {
                  this.rocket_pos.Copy(this.pos);
                  this.rocket_accel = this.accel_start;
                  this.rocket_speed = 0;
                  _loc3_ = param1.playerList[this.targetIndex].GetPos().x - this.pos.x;
                  _loc4_ = param1.playerList[this.targetIndex].GetPos().y - this.pos.y;
                  _loc5_ = _loc3_ * _loc3_ + _loc4_ * _loc4_;
                  if(_loc5_ != 0)
                  {
                     _loc3_ /= Math.sqrt(_loc5_);
                     _loc4_ /= Math.sqrt(_loc5_);
                     this.rocket_dir.x = _loc3_;
                     this.rocket_dir.y = _loc4_;
                  }
                  else
                  {
                     trace("WARNING! rocket.Think() found a player coincident with the rocket about to be launched!: " + _loc3_ + "," + _loc4_);
                     this.rocket_dir.x = 1;
                     this.rocket_dir.y = 0;
                  }
                  param1.objGrid.ENTITY_Add(this.rocket_pos,this);
                  this.CUR_STATE = STATE_HOMING;
               }
            }
         }
         else if(this.CUR_STATE == STATE_HOMING)
         {
            if(this.rocket_speed < this.maxspeed)
            {
               this.rocket_accel *= this.accel_rate;
               this.rocket_speed += this.rocket_accel;
            }
            else
            {
               this.rocket_speed = this.maxspeed;
            }
            this.old_pos.Copy(this.rocket_pos);
            this.rocket_vel.x = this.rocket_speed * this.rocket_dir.x;
            this.rocket_vel.y = this.rocket_speed * this.rocket_dir.y;
            this.rocket_pos.x += this.rocket_vel.x;
            this.rocket_pos.y += this.rocket_vel.y;
            param1.objGrid.ENTITY_Move(this.rocket_pos,this);
            param1.segGrid.GatherCellContentsFromWorldspaceRegion(Math.min(this.old_pos.x,this.rocket_pos.x),Math.min(this.old_pos.y,this.rocket_pos.y),Math.max(this.old_pos.x,this.rocket_pos.x),Math.max(this.old_pos.y,this.rocket_pos.y),this.nearSegs);
            this.hit_pos.x = 0;
            this.hit_pos.y = 0;
            this.hit_n.x = 0;
            this.hit_n.y = 0;
            _loc6_ = 2;
            _loc7_ = 0;
            while(_loc7_ < this.nearSegs.length)
            {
               _loc8_ = this.nearSegs[_loc7_];
               _loc9_ = _loc8_.IntersectWithRay(this.old_pos,this.rocket_vel,0,this.hit_pos,this.hit_n);
               if(_loc9_ == -1)
               {
                  this.Event_Explode(param1);
                  return;
               }
               if(_loc9_ < _loc6_)
               {
                  _loc6_ = _loc9_;
               }
               _loc7_++;
            }
            if(_loc6_ < 2)
            {
               this.Event_Explode(param1);
               return;
            }
            if(!param1.playerList[this.targetIndex].IsDead())
            {
               _loc10_ = this.rocket_vel.x * this.prediction_scale;
               _loc11_ = this.rocket_vel.y * this.prediction_scale;
               _loc12_ = param1.playerList[this.targetIndex].GetVel().x * this.prediction_scale;
               _loc13_ = param1.playerList[this.targetIndex].GetVel().y * this.prediction_scale;
               _loc14_ = this.rocket_pos.x + _loc10_;
               _loc15_ = this.rocket_pos.y + _loc11_;
               _loc16_ = param1.playerList[this.targetIndex].GetPos().x + _loc12_;
               _loc17_ = param1.playerList[this.targetIndex].GetPos().y + _loc13_;
               _loc18_ = _loc16_ - _loc14_;
               _loc19_ = _loc17_ - _loc15_;
               _loc20_ = _loc18_ * _loc18_ + _loc19_ * _loc19_;
               if(_loc20_ == 0)
               {
                  return;
               }
               _loc18_ /= Math.sqrt(_loc20_);
               _loc19_ /= Math.sqrt(_loc20_);
               _loc21_ = -this.rocket_dir.y;
               _loc22_ = this.rocket_dir.x;
               _loc23_ = _loc21_ * _loc18_ + _loc22_ * _loc19_;
               this.rocket_dir.x += this.turn_rate * _loc23_ * _loc21_;
               this.rocket_dir.y += this.turn_rate * _loc23_ * _loc22_;
               _loc24_ = this.rocket_dir.Len();
               if(_loc24_ == 0)
               {
                  this.rocket_dir.x = 0;
                  this.rocket_dir.y = 0;
               }
               else
               {
                  this.rocket_dir.Scale(1 / _loc24_);
               }
            }
            param1.HACKY_GetParticleManager().Spawn_RocketSmoke(this.rocket_pos,Math.atan2(this.rocket_dir.y,this.rocket_dir.x) / Math.PI * 180);
         }
      }
      
      private function Event_Explode(param1:Simulator) : void
      {
         param1.objGrid.ENTITY_Remove(this);
         this.CUR_STATE = STATE_IDLE;
         this.targetIndex = -1;
         param1.HACKY_GetParticleManager().Spawn_Explosion(this.rocket_pos);
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         return new EntityGraphics_Rocket(this,this.pos.x,this.pos.y);
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_Rocket) : void
      {
         if(this.gfx_PREV_STATE == STATE_PREFIRE && this.CUR_STATE == STATE_HOMING)
         {
            param1.anim_base = EntityGraphics_Rocket.ANIM_FIRE;
         }
         else if(this.gfx_PREV_STATE == STATE_HOMING && this.CUR_STATE != STATE_HOMING)
         {
            param1.is_rocket_active = false;
            param1.anim_base = EntityGraphics_Rocket.ANIM_EXPLODE;
         }
         else if(this.CUR_STATE == STATE_PREFIRE || this.CUR_STATE == STATE_IDLE)
         {
            param1.is_rocket_active = false;
            param1.anim_base = EntityGraphics_Rocket.ANIM_IDLE;
         }
         if(this.CUR_STATE == STATE_HOMING)
         {
            param1.is_rocket_active = true;
            param1.pos_rocket.x = this.rocket_pos.x;
            param1.pos_rocket.y = this.rocket_pos.y;
            param1.orn_rocket = Math.atan2(this.rocket_dir.y,this.rocket_dir.x);
         }
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         param1.SetStyle(0,0,100);
         param1.DrawCircle(this.pos.x,this.pos.y,4);
         if(this.CUR_STATE == STATE_PREFIRE)
         {
            param1.DrawSquare(this.pos.x,this.pos.y,4);
         }
         else
         {
            param1.DrawSquare(this.pos.x,this.pos.y,2);
            if(this.CUR_STATE == STATE_HOMING)
            {
               param1.DrawLine(this.rocket_pos.x,this.rocket_pos.y,this.rocket_pos.x - 4 * this.rocket_dir.x,this.rocket_pos.y - 4 * this.rocket_dir.y);
            }
         }
      }
   }
}

