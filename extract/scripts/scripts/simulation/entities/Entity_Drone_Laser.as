package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_Drone_Laser;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Entity;
   import simulation.collision.colutils;
   import simulation.sim_globals;
   
   public class Entity_Drone_Laser extends Entity_Drone_Shooter_Base
   {
      
      private var laser_duration:int = 80;
      
      private var laser_timer:int;
      
      private var laser_dir:vec2;
      
      private var laser_hit_pos:vec2;
      
      private var laser_hit_n:vec2;
      
      public function Entity_Drone_Laser(param1:Grid_Entity, param2:Number, param3:Number, param4:uint, param5:uint)
      {
         var _loc6_:Number = 12 * (1 / 14) * 0.5 * (40 / sim_globals.sim_rate);
         var _loc7_:int = 30 * (sim_globals.sim_rate / 40);
         var _loc8_:int = 40 * (sim_globals.sim_rate / 40);
         super(param1,param2,param3,_loc6_,param4,param5,_loc7_,_loc8_);
         this.laser_timer = 0;
         this.laser_dir = new vec2(0,0);
         this.laser_hit_pos = new vec2();
         this.laser_hit_n = new vec2();
      }
      
      override protected function Start_Prefiring(param1:Simulator, param2:vec2) : void
      {
         this.laser_dir.x = param2.x - pos.x;
         this.laser_dir.y = param2.y - pos.y;
         this.laser_dir.Normalize();
         var _loc3_:Number = param1.segGrid.GetRaycastDistance(pos.x,pos.y,this.laser_dir.x,this.laser_dir.y,this.laser_hit_pos,this.laser_hit_n);
      }
      
      override protected function Update_Prefiring(param1:Simulator, param2:vec2) : void
      {
         var _loc3_:Number = param1.segGrid.GetRaycastDistance(pos.x,pos.y,this.laser_dir.x,this.laser_dir.y,this.laser_hit_pos,this.laser_hit_n);
         param1.HACKY_GetParticleManager().Spawn_LaserCharge(pos);
      }
      
      override protected function Start_Firing(param1:Simulator, param2:vec2, param3:vec2) : void
      {
         this.laser_timer = 0;
      }
      
      override protected function Update_Firing(param1:Simulator) : Boolean
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc2_:Number = param1.segGrid.GetRaycastDistance(pos.x,pos.y,this.laser_dir.x,this.laser_dir.y,this.laser_hit_pos,this.laser_hit_n);
         param1.HACKY_GetParticleManager().Spawn_LaserCharge(pos);
         var _loc3_:int = 0;
         while(_loc3_ < param1.playerList.length)
         {
            if(!param1.playerList[_loc3_].IsDead())
            {
               if(colutils.Overlap_Circle_Vs_Segment(param1.playerList[_loc3_].GetPos(),param1.playerList[_loc3_].GetRadius(),pos,this.laser_hit_pos,_loc2_))
               {
                  _loc4_ = param1.playerList[_loc3_].GetPos().x - pos.x;
                  _loc5_ = param1.playerList[_loc3_].GetPos().y - pos.y;
                  _loc6_ = this.laser_dir.x * _loc4_ + this.laser_dir.y * _loc5_;
                  _loc7_ = pos.x + _loc6_ * this.laser_dir.x;
                  _loc8_ = pos.y + _loc6_ * this.laser_dir.y;
                  param1.Event_PlayerWasKilled(param1.playerList[_loc3_],sim_globals.ENEMYTYPE_LASER,_loc7_,_loc8_,this.laser_dir.x * 6,this.laser_dir.y * 6);
               }
            }
            _loc3_++;
         }
         ++this.laser_timer;
         if(this.laser_duration <= this.laser_timer)
         {
            return true;
         }
         return false;
      }
      
      override protected function Start_Postfiring(param1:Simulator) : void
      {
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         return new EntityGraphics_Drone_Laser(this);
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_Drone_Laser) : void
      {
         param1.pos.x = pos.x;
         param1.pos.y = pos.y;
         param1.orn = gfxorn;
         var _loc2_:int = GetFiringState();
         if(_loc2_ == FIRING_STATE_IDLE)
         {
            param1.anim = EntityGraphics_Drone_Laser.ANIM_MOVE;
         }
         else if(_loc2_ == FIRING_STATE_PREFIRING)
         {
            param1.anim = EntityGraphics_Drone_Laser.ANIM_PREFIRE;
            param1.blast_pos.x = this.laser_hit_pos.x;
            param1.blast_pos.y = this.laser_hit_pos.y;
         }
         else if(_loc2_ == FIRING_STATE_POSTFIRING)
         {
            param1.anim = EntityGraphics_Drone_Laser.ANIM_POSTFIRE;
         }
         else if(_loc2_ == FIRING_STATE_FIRING)
         {
            param1.anim = EntityGraphics_Drone_Laser.ANIM_FIRING;
            param1.blast_scale = 30 + 200 * (this.laser_timer / this.laser_duration);
         }
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         super.Debug_Draw(param1);
         param1.SetStyle(4,8921634,50);
         param1.DrawCircle(pos.x,pos.y,r / 2);
         var _loc2_:int = GetFiringState();
         if(_loc2_ == FIRING_STATE_PREFIRING)
         {
            param1.SetStyle(0,8921634,20);
            param1.DrawLine(pos.x,pos.y,this.laser_hit_pos.x,this.laser_hit_pos.y);
            param1.DrawLine(this.laser_hit_pos.x,this.laser_hit_pos.y,this.laser_hit_pos.x + this.laser_hit_n.x * 4,this.laser_hit_pos.y + this.laser_hit_n.y * 4);
         }
         else if(_loc2_ == FIRING_STATE_FIRING)
         {
            param1.SetStyle(2,8921634,80);
            param1.DrawLine(pos.x,pos.y,this.laser_hit_pos.x,this.laser_hit_pos.y);
            param1.DrawLine(this.laser_hit_pos.x,this.laser_hit_pos.y,this.laser_hit_pos.x + this.laser_hit_n.x * 4,this.laser_hit_pos.y + this.laser_hit_n.y * 4);
         }
      }
   }
}

