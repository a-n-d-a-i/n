package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_Drone_Chaingun;
   import math.mathutils;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Entity;
   import simulation.collision.colutils;
   import simulation.sim_globals;
   
   public class Entity_Drone_Chaingun extends Entity_Drone_Shooter_Base
   {
      
      private static const chaingun_maxbullets:int = 6;
      
      private static const chaingun_spread:Number = 0.3;
      
      private var chaingun_rate:Number = 6 * (sim_globals.sim_rate / 40);
      
      private var chaingun_count:int;
      
      private var chaingun_timer:int;
      
      private var chaingun_dir:vec2;
      
      private var chaingun_sweep:vec2;
      
      private var chaingun_HACKY_hitmode:int;
      
      private var chaingun_hit_pos:vec2;
      
      private var chaingun_hit_n:vec2;
      
      public function Entity_Drone_Chaingun(param1:Grid_Entity, param2:Number, param3:Number, param4:uint, param5:uint)
      {
         var _loc6_:Number = 12 * (1 / 14) * 0.75 * (40 / sim_globals.sim_rate);
         var _loc7_:int = 35 * (sim_globals.sim_rate / 40);
         var _loc8_:int = 60 * (sim_globals.sim_rate / 40);
         super(param1,param2,param3,_loc6_,param4,param5,_loc7_,_loc8_);
         this.chaingun_count = 0;
         this.chaingun_timer = 0;
         this.chaingun_dir = new vec2();
         this.chaingun_sweep = new vec2();
         this.chaingun_HACKY_hitmode = 0;
         this.chaingun_hit_pos = new vec2();
         this.chaingun_hit_n = new vec2();
      }
      
      override protected function Start_Prefiring(param1:Simulator, param2:vec2) : void
      {
      }
      
      override protected function Update_Prefiring(param1:Simulator, param2:vec2) : void
      {
         var _loc3_:Number = param2.x - pos.x;
         var _loc4_:Number = param2.y - pos.y;
         var _loc5_:Number = mathutils.WrapAngle_Shortest(Math.atan2(_loc4_,_loc3_) - gfxorn);
         gfxorn += 0.2 * _loc5_;
      }
      
      override protected function Start_Firing(param1:Simulator, param2:vec2, param3:vec2) : void
      {
         var _loc7_:Number = NaN;
         this.chaingun_count = 0;
         this.chaingun_timer = 0;
         this.chaingun_HACKY_hitmode = 0;
         var _loc4_:Number = param2.x - pos.x;
         var _loc5_:Number = param2.y - pos.y;
         var _loc6_:Number = Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
         if(_loc6_ == 0)
         {
            _loc6_ = param3.Len();
            if(_loc6_ == 0)
            {
               this.chaingun_dir.x = 1;
               this.chaingun_dir.y = 0;
               this.chaingun_sweep.x = 0;
               this.chaingun_sweep.y = 0;
            }
            else
            {
               this.chaingun_dir.x = param3.x / _loc6_;
               this.chaingun_dir.y = param3.y / _loc6_;
               this.chaingun_sweep.x = 0;
               this.chaingun_sweep.y = 0;
            }
         }
         else
         {
            this.chaingun_dir.x = _loc4_ / _loc6_;
            this.chaingun_dir.y = _loc5_ / _loc6_;
            _loc7_ = -this.chaingun_dir.y * param3.x + this.chaingun_dir.x * param3.y;
            if(_loc7_ < 0)
            {
               this.chaingun_sweep.x = this.chaingun_dir.y;
               this.chaingun_sweep.y = -this.chaingun_dir.x;
            }
            else
            {
               this.chaingun_sweep.x = -this.chaingun_dir.y;
               this.chaingun_sweep.y = this.chaingun_dir.x;
            }
         }
      }
      
      override protected function Update_Firing(param1:Simulator) : Boolean
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         ++this.chaingun_timer;
         if(this.chaingun_rate <= this.chaingun_timer)
         {
            this.chaingun_timer = 0;
            if(chaingun_maxbullets < this.chaingun_count)
            {
               return true;
            }
            ++this.chaingun_count;
            _loc2_ = (this.chaingun_count / chaingun_maxbullets - 0.5) * chaingun_spread;
            _loc3_ = this.chaingun_dir.x + _loc2_ * this.chaingun_sweep.x;
            _loc4_ = this.chaingun_dir.y + _loc2_ * this.chaingun_sweep.y;
            _loc5_ = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
            _loc3_ /= _loc5_;
            _loc4_ /= _loc5_;
            gfxorn = Math.atan2(_loc4_,_loc3_);
            _loc6_ = param1.segGrid.GetRaycastDistance(pos.x,pos.y,_loc3_,_loc4_,this.chaingun_hit_pos,this.chaingun_hit_n);
            param1.HACKY_GetParticleManager().Spawn_ChainBullet(pos,this.chaingun_hit_pos);
            _loc7_ = 0;
            while(_loc7_ < param1.playerList.length)
            {
               if(!param1.playerList[_loc7_].IsDead())
               {
                  if(colutils.Overlap_Circle_Vs_Segment(param1.playerList[_loc7_].GetPos(),param1.playerList[_loc7_].GetRadius(),pos,this.chaingun_hit_pos,_loc6_))
                  {
                     _loc8_ = param1.playerList[_loc7_].GetPos().x - pos.x;
                     _loc9_ = param1.playerList[_loc7_].GetPos().y - pos.y;
                     _loc10_ = _loc3_ * _loc8_ + _loc4_ * _loc9_;
                     this.chaingun_hit_pos.x = pos.x + _loc10_ * _loc3_;
                     this.chaingun_hit_pos.y = pos.y + _loc10_ * _loc4_;
                     param1.Event_PlayerWasKilled(param1.playerList[_loc7_],sim_globals.ENEMYTYPE_CHAINGUN,this.chaingun_hit_pos.x,this.chaingun_hit_pos.y,_loc3_ * 5,_loc4_ * 5);
                  }
               }
               _loc7_++;
            }
            this.chaingun_HACKY_hitmode = 1;
         }
         return false;
      }
      
      override protected function Start_Postfiring(param1:Simulator) : void
      {
         if(this.chaingun_HACKY_hitmode < 2)
         {
            this.chaingun_HACKY_hitmode = 0;
         }
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         return new EntityGraphics_Drone_Chaingun(this);
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_Drone_Chaingun) : void
      {
         param1.pos.x = pos.x;
         param1.pos.y = pos.y;
         param1.orn = gfxorn;
         var _loc2_:int = GetFiringState();
         if(_loc2_ == FIRING_STATE_IDLE)
         {
            param1.anim = EntityGraphics_Drone_Chaingun.ANIM_MOVE;
         }
         else if(_loc2_ == FIRING_STATE_PREFIRING)
         {
            param1.anim = EntityGraphics_Drone_Chaingun.ANIM_PREFIRE;
         }
         else if(_loc2_ == FIRING_STATE_POSTFIRING)
         {
            param1.anim = EntityGraphics_Drone_Chaingun.ANIM_POSTFIRE;
         }
         else if(_loc2_ == FIRING_STATE_FIRING)
         {
            param1.anim = EntityGraphics_Drone_Chaingun.ANIM_FIRING;
         }
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         super.Debug_Draw(param1);
         param1.SetStyle(4,8947848,50);
         param1.DrawCircle(pos.x,pos.y,r / 2);
         if(this.chaingun_HACKY_hitmode == 1)
         {
            param1.SetStyle(0,8947848,100 * (1 - Number(this.chaingun_timer) / Number(this.chaingun_rate)));
            param1.DrawLine(pos.x,pos.y,this.chaingun_hit_pos.x,this.chaingun_hit_pos.y);
            param1.DrawLine(this.chaingun_hit_pos.x,this.chaingun_hit_pos.y,this.chaingun_hit_pos.x + 4 * this.chaingun_hit_n.x,this.chaingun_hit_pos.y + 4 * this.chaingun_hit_n.y);
         }
      }
   }
}

