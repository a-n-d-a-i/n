package simulation.entities
{
   import audiovisual.entitygraphics.EntityGraphics;
   import audiovisual.entitygraphics.EntityGraphics_Mine;
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.Grid_Entity;
   import simulation.collision.colutils;
   import simulation.ninja.Ninja;
   import simulation.sim_globals;
   
   public class Entity_Mine extends Entity_Base
   {
      
      private var pos:vec2;
      
      private var r:Number;
      
      private var isExploded:Boolean;
      
      public function Entity_Mine(param1:Grid_Entity, param2:Number, param3:Number)
      {
         super();
         this.pos = new vec2(param2,param3);
         this.r = 12 * (1 / 3);
         this.isExploded = false;
         param1.ENTITY_Add(this.pos,this);
      }
      
      override public function CollideVsCircle_Logical(param1:Simulator, param2:Ninja, param3:collision_result_logical, param4:vec2, param5:vec2, param6:vec2, param7:Number, param8:Number) : Boolean
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(colutils.Overlap_Circle_Vs_Circle(this.pos,this.r,param4,param7))
         {
            param1.HACKY_GetParticleManager().Spawn_Explosion(this.pos);
            this.isExploded = true;
            param1.objGrid.ENTITY_Remove(this);
            _loc9_ = param4.x - this.pos.x;
            _loc10_ = param4.y - this.pos.y;
            _loc11_ = Math.sqrt(_loc9_ * _loc9_ + _loc10_ * _loc10_);
            _loc9_ /= _loc11_;
            _loc10_ /= _loc11_;
            if(param2 == null)
            {
               param3.vec_x = _loc9_ * 16;
               param3.vec_y = _loc10_ * 16;
               return true;
            }
            param1.Event_PlayerWasKilled(param2,sim_globals.ENEMYTYPE_MINE,param4.x - _loc9_ * param7,param4.y - _loc10_ * param7,_loc9_ * 16,_loc10_ * 16);
         }
         return false;
      }
      
      override public function GenerateGraphicComponent() : EntityGraphics
      {
         return new EntityGraphics_Mine(this,this.pos.x,this.pos.y);
      }
      
      public function GFX_UpdateState(param1:EntityGraphics_Mine) : void
      {
         if(this.isExploded)
         {
            param1.anim = EntityGraphics_Mine.ANIM_EXPLODED;
         }
         else
         {
            param1.anim = EntityGraphics_Mine.ANIM_UNEXPLODED;
         }
      }
      
      override public function Debug_Draw(param1:SimpleRenderer) : void
      {
         if(this.isExploded)
         {
            param1.SetStyle(0,0,30);
         }
         else
         {
            param1.SetStyle(0,0,100);
         }
         param1.DrawCross(this.pos.x,this.pos.y,this.r);
         param1.DrawCircle(this.pos.x,this.pos.y,this.r);
      }
   }
}

