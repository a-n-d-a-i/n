package simulation.entities
{
   import math.vec2;
   import simpleFramework.SimpleRenderer;
   import simulation.Simulator;
   import simulation.collision.AABB;
   import simulation.collision.Grid_Edges;
   import simulation.collision.Grid_Entity;
   import simulation.collision.Grid_Segment;
   import simulation.collision.Segment;
   import simulation.collision.colutils;
   import simulation.ninja.Ninja;
   
   public class Entity_Door_Base extends Entity_Base
   {
      
      protected var trigger_pos:vec2;
      
      private var trigger_r:Number;
      
      private var seg_grid:Grid_Segment;
      
      protected var seg:Segment;
      
      private var seg_index:int;
      
      private var edge_grid:Grid_Edges;
      
      private var edge_indices:Vector.<int>;
      
      private var isHorizontal:Boolean;
      
      private var isOpen:Boolean;
      
      public function Entity_Door_Base(param1:Grid_Entity, param2:Grid_Segment, param3:int, param4:Segment, param5:Grid_Edges, param6:Vector.<int>, param7:Boolean, param8:Number, param9:Number, param10:Number, param11:Boolean)
      {
         super();
         this.trigger_pos = new vec2(param8,param9);
         this.trigger_r = param10;
         this.seg_grid = param2;
         this.edge_grid = param5;
         this.seg = param4;
         this.seg_index = param3;
         this.edge_indices = new Vector.<int>(param6.length,true);
         var _loc12_:int = 0;
         while(_loc12_ < this.edge_indices.length)
         {
            this.edge_indices[_loc12_] = param6[_loc12_];
            _loc12_++;
         }
         this.isHorizontal = param7;
         this.isOpen = param11;
         if(!this.isOpen)
         {
            this.AddDoorToWorld();
         }
         param1.ENTITY_Add(this.trigger_pos,this);
      }
      
      override public function CollideVsCircle_Logical(param1:Simulator, param2:Ninja, param3:collision_result_logical, param4:vec2, param5:vec2, param6:vec2, param7:Number, param8:Number) : Boolean
      {
         if(param2 != null)
         {
            if(colutils.Overlap_Circle_Vs_Circle(this.trigger_pos,this.trigger_r,param4,param7))
            {
               this.OnCollision(param1);
            }
         }
         return false;
      }
      
      protected function OnCollision(param1:Simulator) : void
      {
      }
      
      protected function IsDoorOpen() : Boolean
      {
         return this.isOpen;
      }
      
      protected function ChangeDoorState(param1:Boolean) : void
      {
         if(this.isOpen == param1)
         {
            trace("WARNING! ChangeDoorState() was called with the existing state as new! " + param1);
            return;
         }
         this.isOpen = param1;
         if(this.isOpen)
         {
            this.RemoveDoorFromWorld();
         }
         else
         {
            this.AddDoorToWorld();
         }
      }
      
      private function RemoveDoorFromWorld() : void
      {
         this.seg_grid.DOOR_RemoveSegment(this.seg_index,this.seg);
         var _loc1_:int = 0;
         while(_loc1_ < this.edge_indices.length)
         {
            this.edge_grid.DOOR_DecrementEdge(this.edge_indices[_loc1_],this.isHorizontal);
            _loc1_++;
         }
      }
      
      private function AddDoorToWorld() : void
      {
         this.seg_grid.DOOR_AddSegment(this.seg_index,this.seg);
         var _loc1_:int = 0;
         while(_loc1_ < this.edge_indices.length)
         {
            this.edge_grid.DOOR_IncrementEdge(this.edge_indices[_loc1_],this.isHorizontal);
            _loc1_++;
         }
      }
      
      protected function GetDoorPos() : vec2
      {
         var _loc1_:AABB = this.seg.GetAABB();
         return new vec2(0.5 * (_loc1_.min.x + _loc1_.max.x),0.5 * (_loc1_.min.y + _loc1_.max.y));
      }
      
      protected function GetDoorOrn() : Number
      {
         if(this.isHorizontal)
         {
            return 0;
         }
         return Math.PI / 2;
      }
      
      public function Debug_Draw_Base(param1:SimpleRenderer, param2:Boolean) : void
      {
         var _loc3_:AABB = null;
         var _loc4_:vec2 = null;
         if(param2)
         {
            param1.SetStyle(0,8921736,30);
            param1.DrawCircle(this.trigger_pos.x,this.trigger_pos.y,this.trigger_r);
            _loc3_ = this.seg.GetAABB();
            _loc4_ = new vec2(0.5 * (_loc3_.max.x + _loc3_.min.x),0.5 * (_loc3_.max.y + _loc3_.min.y));
            param1.DrawLine(this.trigger_pos.x,this.trigger_pos.y,_loc4_.x,_loc4_.y);
         }
         if(!this.isOpen)
         {
            param1.SetStyle(0,0,100);
            this.seg.DebugDraw_NoStyle(param1);
         }
      }
   }
}

