/* Literal port of simulation/entities/*.as */
import { vec2, mathutils } from "./math.js";
import { colutils } from "./collision.js";
import {
  EntityGraphics_BounceBlock, EntityGraphics_Gold, EntityGraphics_Mine,
  EntityGraphics_OnewayPlatform, EntityGraphics_Thwomp, EntityGraphics_Launchpad,
  EntityGraphics_Door_Regular, EntityGraphics_Door_Locked, EntityGraphics_Door_Trap,
  EntityGraphics_ExitDoor, EntityGraphics_ExitSwitch, EntityGraphics_FloorGuard,
  EntityGraphics_Turret, EntityGraphics_Rocket, EntityGraphics_Drone_Chaingun,
  EntityGraphics_Drone_Chaser, EntityGraphics_Drone_Zap, EntityGraphics_Drone_Laser,
} from "./entitygraphics.js";

export const sim_globals = {
  sim_rate: 60,
  DEATHTYPE_SUICIDE: 0, DEATHTYPE_FALL: 1, DEATHTYPE_CRUSH: 2, DEATHTYPE_TIME: 3,
  DEATHTYPE_EXPLOSIVE: 4, DEATHTYPE_LASER: 5, DEATHTYPE_ELECTRIC: 6, DEATHTYPE_BULLET: 7,
  ENEMYTYPE_SUICIDE: 0, ENEMYTYPE_FALL: 1, ENEMYTYPE_CRUSH: 2, ENEMYTYPE_TIME: 3,
  ENEMYTYPE_ZAP: 4, ENEMYTYPE_CHAINGUN: 5, ENEMYTYPE_LASER: 6, ENEMYTYPE_TURRET: 7,
  ENEMYTYPE_ROCKET: 8, ENEMYTYPE_FLOORGUARD: 9, ENEMYTYPE_THWOMP: 10,
  ENEMYTYPE_MINE: 11, ENEMYTYPE_DEBUG: 12,
  ETYPE_TO_DTYPE: [4, 1, 2, 4, 6, 7, 5, 7, 4, 6, 6, 4, 7],
};
export const ENEMYTYPE = sim_globals;

export class collision_result_logical {
  constructor() { this.Clear(); }
  Clear() { this.vec_x = 0; this.vec_y = 0; }
}
export class collision_result_physical {
  constructor() { this.Clear(); }
  Clear() { this.pen = 0; this.nx = 0; this.ny = 0; this.isHardCollision = true; }
}

export class Entity_Base {
  constructor() { this.UID = -1; this.grid_index = -1; }
  GAME_SetUID(v) { this.UID = v; }
  GetUID() { return this.UID; }
  GRID_GetGridIndex() { return this.grid_index; }
  GRID_SetGridIndex(v) { this.grid_index = v; }
  CollideVsCircle_Physical() { return false; }
  CollideVsCircle_Logical() { return false; }
  Think() {}
  Move() {}
  GenerateGraphicComponent() { return null; }
  Debug_Draw() {}
}

export class Entity_Mine extends Entity_Base {
  constructor(grid, x, y) {
    super();
    this.pos = new vec2(x, y);
    this.r = 12 * (1 / 3);
    this.isExploded = false;
    grid.ENTITY_Add(this.pos, this);
  }
  CollideVsCircle_Logical(sim, ninja, result, pos, vel, oldpos, radius, skin) {
    if (colutils.Overlap_Circle_Vs_Circle(this.pos, this.r, pos, radius)) {
      sim.HACKY_GetParticleManager().Spawn_Explosion(this.pos);
      this.isExploded = true;
      sim.objGrid.ENTITY_Remove(this);
      let dx = pos.x - this.pos.x, dy = pos.y - this.pos.y;
      const l = Math.sqrt(dx * dx + dy * dy);
      dx /= l; dy /= l;
      if (ninja === null) {
        result.vec_x = dx * 16; result.vec_y = dy * 16;
        return true;
      }
      sim.Event_PlayerWasKilled(ninja, sim_globals.ENEMYTYPE_MINE,
        pos.x - dx * radius, pos.y - dy * radius, dx * 16, dy * 16);
    }
    return false;
  }
  GenerateGraphicComponent() { return new EntityGraphics_Mine(this, this.pos.x, this.pos.y); }
  GFX_UpdateState(g) { g.anim = this.isExploded ? 1 : 0; }
  Debug_Draw() {}
}

export class Entity_Gold extends Entity_Base {
  constructor(grid, x, y) {
    super();
    this.pos = new vec2(x, y);
    this.r = 12 * 0.5;
    this.isCollected = false;
    grid.ENTITY_Add(this.pos, this);
  }
  CollideVsCircle_Logical(sim, ninja, result, pos, vel, oldpos, radius, skin) {
    if (ninja !== null && colutils.Overlap_Circle_Vs_Circle(this.pos, this.r, pos, radius)) {
      if (sim.Event_Gold_HitPlayer(ninja)) {
        this.isCollected = true;
        sim.objGrid.ENTITY_Remove(this);
        sim.HACKY_GetSoundManager().PlaySound_Gold();
      }
    }
    return false;
  }
  GenerateGraphicComponent() { return new EntityGraphics_Gold(this, this.pos.x, this.pos.y); }
  GFX_UpdateState(g) { g.anim = this.isCollected ? 1 : 0; }
  Debug_Draw() {}
}

export class Entity_Launchpad extends Entity_Base {
  constructor(grid, x, y, nx, ny) {
    super();
    this.pos = new vec2(x, y);
    this.n = new vec2(nx, ny);
    this.r = 12 * 0.5;
    this.strength = 12 * (3 / 7);
    this.gfx_triggerEvent = false;
    grid.ENTITY_Add(this.pos, this);
  }
  CollideVsCircle_Logical(sim, ninja, result, pos, vel, oldpos, radius, skin) {
    if (colutils.Overlap_Circle_Vs_Circle(this.pos, this.r, pos, radius)) {
      const dx = this.pos.x - (pos.x - this.n.x * radius);
      const dy = this.pos.y - (pos.y - this.n.y * radius);
      const s = 0.1;
      if (-s <= this.n.x * dx + this.n.y * dy) {
        let k = 1;
        if (this.n.y < 0) k += Math.abs(this.n.y);
        if (ninja === null) {
          result.vec_x = this.n.x * 12;
          result.vec_y = this.n.y * 12;
          this.gfx_triggerEvent = true;
          return true;
        }
        sim.Event_Launchpad_HitPlayer(ninja, this.n.x * this.strength, this.n.y * this.strength * k);
        this.gfx_triggerEvent = true;
      }
    }
    return false;
  }
  GenerateGraphicComponent() {
    return new EntityGraphics_Launchpad(this, this.pos.x, this.pos.y, Math.atan2(this.n.y, this.n.x));
  }
  GFX_UpdateState(g) {
    if (this.gfx_triggerEvent) { g.anim = 1; this.gfx_triggerEvent = false; }
    else g.anim = 0;
  }
  Debug_Draw() {}
}

export class Entity_BounceBlock extends Entity_Base {
  constructor(grid, x, y) {
    super();
    this.pos = new vec2(x, y);
    this.vel = new vec2(0, 0);
    this.anchor = new vec2(x, y);
    this.r = 0.8 * 12;
    this.stiff = 0.05 * (40 / sim_globals.sim_rate) * (40 / sim_globals.sim_rate);
    this.damp = sim_globals.sim_rate === 60 ? 0.98 : 0.99;
    this.mass = 0.2;
    this.isSleeping = true;
    this.n = new vec2();
    grid.ENTITY_Add(this.pos, this);
  }
  CollideVsCircle_Physical(result, pos, vel, oldpos, radius) {
    this.n.x = 0; this.n.y = 0;
    const pen = colutils.Penetration_Square_vs_Point(this.pos, this.r + radius, pos, this.n);
    if (pen !== 0) {
      const move = (1 - this.mass) * pen;
      this.pos.x -= move * this.n.x;
      this.vel.x -= move * this.n.x;
      this.pos.y -= move * this.n.y;
      this.vel.y -= move * this.n.y;
      result.isHardCollision = false;
      result.nx = this.n.x; result.ny = this.n.y;
      result.pen = this.mass * pen;
      return true;
    }
    return false;
  }
  CollideVsCircle_Logical(sim, ninja, result, pos, vel, oldpos, radius, skin) {
    if (ninja !== null) {
      this.n.x = 0; this.n.y = 0;
      const pen = colutils.Penetration_Square_vs_Point(this.pos, skin + this.r + radius, pos, this.n);
      if (pen !== 0) { result.vec_x = this.n.x; result.vec_y = this.n.y; return true; }
    }
    return false;
  }
  Think() {
    if (!this.isSleeping) {
      const dx = this.anchor.x - this.pos.x;
      const dy = this.anchor.y - this.pos.y;
      const d2 = dx * dx + dy * dy;
      if (this.vel.LenSq() < 0.05 && d2 < 0.05) {
        this.pos.Copy(this.anchor);
        this.vel.x = 0; this.vel.y = 0;
        this.isSleeping = true;
      }
    }
  }
  Move(sim) {
    this.vel.Scale(this.damp);
    this.pos.x += this.vel.x;
    this.pos.y += this.vel.y;
    let dx = this.anchor.x - this.pos.x;
    let dy = this.anchor.y - this.pos.y;
    dx *= this.stiff; dy *= this.stiff;
    this.pos.x += dx; this.pos.y += dy;
    this.vel.x += dx; this.vel.y += dy;
    sim.objGrid.ENTITY_Move(this.pos, this);
  }
  GenerateGraphicComponent() { return new EntityGraphics_BounceBlock(this); }
  GFX_UpdateState(g) { g.pos.x = this.pos.x; g.pos.y = this.pos.y; }
  Debug_Draw() {}
}

export class Entity_OnewayPlatform extends Entity_Base {
  constructor(grid, x, y, nx, ny) {
    super();
    this.pos = new vec2(x, y);
    this.n = new vec2(nx, ny);
    this.r = 12;
    grid.ENTITY_Add(this.pos, this);
  }
  CollideVsCircle_Physical(result, pos, vel, oldpos, radius) {
    const pen = this.CalculatePenetration(pos, vel, oldpos, radius, 0);
    if (pen >= 0) {
      result.isHardCollision = true;
      result.nx = this.n.x; result.ny = this.n.y;
      result.pen = pen;
      return true;
    }
    return false;
  }
  CollideVsCircle_Logical(sim, ninja, result, pos, vel, oldpos, radius, skin) {
    if (ninja !== null) {
      const pen = this.CalculatePenetration(pos, vel, oldpos, radius, skin);
      if (pen >= 0) { result.vec_x = this.n.x; result.vec_y = this.n.y; return true; }
    }
    return false;
  }
  CalculatePenetration(pos, vel, oldpos, radius, skin) {
    const dx = pos.x - this.pos.x, dy = pos.y - this.pos.y;
    const across = this.r + radius - Math.abs(-this.n.y * dx + this.n.x * dy);
    if (across > 0) {
      const along = radius + skin - Math.abs(this.n.x * dx + this.n.y * dy);
      if (along > 0) {
        const vn = this.n.x * vel.x + this.n.y * vel.y;
        if (vn <= 0) {
          const ox = oldpos.x - this.pos.x, oy = oldpos.y - this.pos.y;
          const oldAlong = radius - (this.n.x * ox + this.n.y * oy);
          if (oldAlong <= 1.1) {
            const pen = radius - (this.n.x * dx + this.n.y * dy);
            if (pen < 0) return -1;
            return pen;
          }
        }
      }
    }
    return -1;
  }
  GenerateGraphicComponent() {
    return new EntityGraphics_OnewayPlatform(this.pos.x, this.pos.y, Math.atan2(this.n.y, this.n.x));
  }
  Debug_Draw() {}
}

export class Entity_FloorGuard extends Entity_Base {
  constructor(grid, x, y) {
    super();
    this.pos = new vec2(x, y);
    this.r = 12 * 0.5;
    this.speed = 12 * (3 / 7) * (40 / sim_globals.sim_rate);
    this.CUR_STATE = 0;
    this.margin = 0;
    grid.ENTITY_Add(this.pos, this);
  }
  CollideVsCircle_Logical(sim, ninja, result, pos, vel, oldpos, radius, skin) {
    if (colutils.Overlap_Circle_Vs_Circle(this.pos, this.r, pos, radius)) {
      let dx = pos.x - this.pos.x, dy = pos.y - this.pos.y;
      const l = Math.sqrt(dx * dx + dy * dy);
      dx /= l; dy /= l;
      sim.HACKY_GetParticleManager().Spawn_Zap(this.pos.x + dx * this.r, this.pos.y + dy * this.r,
        Math.atan2(dy, dx) / Math.PI * 180);
      if (ninja === null) {
        result.vec_x = dx * 10; result.vec_y = dy * 10;
        return true;
      }
      sim.Event_PlayerWasKilled(ninja, sim_globals.ENEMYTYPE_FLOORGUARD,
        pos.x - dx * radius, pos.y - dy * radius, dx * 10, dy * 10);
    }
    return false;
  }
  Think(sim) {
    if (this.CUR_STATE !== 0) return;
    const grid = sim.edgeGrid;
    for (let i = 0; i < sim.playerList.length; i++) {
      const n = sim.playerList[i];
      if (n.IsDead()) continue;
      const p = n.GetPos();
      const top = this.pos.y + this.r;
      const bot = top - 24;
      if (p.y >= bot && p.y <= top) {
        const pc = grid.GetGridCoordinateFromWorldspace_1D(p.x);
        const gc = grid.GetGridCoordinateFromWorldspace_1D(this.pos.x);
        const gr = grid.GetGridCoordinateFromWorldspace_1D(this.pos.y);
        let dir = 0;
        if (grid.ScanHorizontal(gr, gr, gc, pc)) dir = p.x < this.pos.x ? -1 : 1;
        if (dir !== 0) { this.CUR_STATE = dir; break; }
      }
    }
  }
  Move(sim) {
    if (this.CUR_STATE === 0) return;
    const grid = sim.edgeGrid;
    const margin = this.r + this.margin;
    let nx = this.pos.x + this.CUR_STATE * this.speed;
    const off = this.CUR_STATE * margin;
    const c0 = grid.GetGridCoordinateFromWorldspace_1D(this.pos.x + off);
    const c1 = grid.GetGridCoordinateFromWorldspace_1D(nx + off);
    if (c0 !== c1) {
      const r = grid.GetGridCoordinateFromWorldspace_1D(this.pos.y);
      if (!grid.IsEmpty(c0, r, this.CUR_STATE, 0) || !grid.IsSolid_IgnoreDoors(c1, r, 0, 1)) {
        nx = grid.GetWorldspaceCoordinateFromGridEdge_1D(c0, this.CUR_STATE) - this.CUR_STATE * (margin + 0.01);
        this.CUR_STATE = 0;
      }
    }
    this.pos.x = nx;
    sim.objGrid.ENTITY_Move(this.pos, this);
  }
  GenerateGraphicComponent() { return new EntityGraphics_FloorGuard(this); }
  GFX_UpdateState(g) {
    g.pos.x = this.pos.x; g.pos.y = this.pos.y;
    if (this.CUR_STATE === 0) g.anim = 0;
    else if (this.CUR_STATE === -1) g.anim = -1;
    else g.anim = 1;
  }
  Debug_Draw() {}
}

export class Entity_ExitDoor extends Entity_Base {
  constructor(x, y) {
    super();
    this.pos = new vec2(x, y);
    this.r = 12;
    this.isOpen = false;
  }
  CollideVsCircle_Logical(sim, ninja, result, pos, vel, oldpos, radius, skin) {
    if (ninja !== null && colutils.Overlap_Circle_Vs_Circle(this.pos, this.r, pos, radius)) {
      sim.Event_Exit_HitPlayer(ninja);
    }
    return false;
  }
  SWITCH_OpenTheExit(grid) { this.isOpen = true; grid.ENTITY_Add(this.pos, this); }
  SWITCH_IsOpen() { return this.isOpen; }
  GenerateGraphicComponent() { return new EntityGraphics_ExitDoor(this, this.pos.x, this.pos.y); }
  GFX_UpdateState(g) { g.anim = this.isOpen ? 1 : 0; }
  Debug_Draw() {}
}

export class Entity_ExitSwitch extends Entity_Base {
  constructor(grid, x, y, door) {
    super();
    this.pos = new vec2(x, y);
    this.r = 12 * 0.5;
    this.door = door;
    grid.ENTITY_Add(this.pos, this);
  }
  CollideVsCircle_Logical(sim, ninja, result, pos, vel, oldpos, radius, skin) {
    if (ninja !== null && colutils.Overlap_Circle_Vs_Circle(this.pos, this.r, pos, radius)) {
      this.door.SWITCH_OpenTheExit(sim.objGrid);
      sim.objGrid.ENTITY_Remove(this);
    }
    return false;
  }
  GenerateGraphicComponent() { return new EntityGraphics_ExitSwitch(this, this.pos.x, this.pos.y); }
  GFX_UpdateState(g) { g.anim = this.door.SWITCH_IsOpen() ? 1 : 0; }
  Debug_Draw() {}
}

export class Entity_Door_Base extends Entity_Base {
  constructor(grid, segGrid, segIndex, seg, edgeGrid, edgeIndices, horizontal, tx, ty, tr, open) {
    super();
    this.trigger_pos = new vec2(tx, ty);
    this.trigger_r = tr;
    this.seg_grid = segGrid;
    this.edge_grid = edgeGrid;
    this.seg = seg;
    this.seg_index = segIndex;
    this.edge_indices = edgeIndices.slice();
    this.isHorizontal = horizontal;
    this.isOpen = open;
    if (!this.isOpen) this.AddDoorToWorld();
    grid.ENTITY_Add(this.trigger_pos, this);
  }
  CollideVsCircle_Logical(sim, ninja, result, pos, vel, oldpos, radius, skin) {
    if (ninja !== null && colutils.Overlap_Circle_Vs_Circle(this.trigger_pos, this.trigger_r, pos, radius)) {
      this.OnCollision(sim);
    }
    return false;
  }
  OnCollision() {}
  IsDoorOpen() { return this.isOpen; }
  ChangeDoorState(open) {
    if (this.isOpen === open) return;
    this.isOpen = open;
    if (this.isOpen) this.RemoveDoorFromWorld(); else this.AddDoorToWorld();
  }
  RemoveDoorFromWorld() {
    this.seg_grid.DOOR_RemoveSegment(this.seg_index, this.seg);
    for (const idx of this.edge_indices) this.edge_grid.DOOR_DecrementEdge(idx, this.isHorizontal);
  }
  AddDoorToWorld() {
    this.seg_grid.DOOR_AddSegment(this.seg_index, this.seg);
    for (const idx of this.edge_indices) this.edge_grid.DOOR_IncrementEdge(idx, this.isHorizontal);
  }
  GetDoorPos() {
    const b = this.seg.GetAABB();
    return new vec2(0.5 * (b.min.x + b.max.x), 0.5 * (b.min.y + b.max.y));
  }
  GetDoorOrn() { return this.isHorizontal ? 0 : Math.PI / 2; }
  Debug_Draw_Base() {}
}

export class Entity_Door_Regular extends Entity_Door_Base {
  constructor(grid, sg, si, seg, eg, ei, horizontal, tx, ty) {
    super(grid, sg, si, seg, eg, ei, horizontal, tx, ty, 12 * (5 / 6), false);
    this.close_timer = 0;
  }
  OnCollision() {
    this.close_timer = 0;
    if (!this.IsDoorOpen()) this.ChangeDoorState(true);
  }
  Think() {
    if (this.IsDoorOpen()) {
      this.close_timer++;
      if (this.close_timer > 5) this.ChangeDoorState(false);
    }
  }
  GenerateGraphicComponent() {
    const p = this.GetDoorPos();
    return new EntityGraphics_Door_Regular(this, p.x, p.y, this.GetDoorOrn());
  }
  GFX_UpdateState(g) { g.anim = this.IsDoorOpen() ? 1 : 0; }
  Debug_Draw() {}
}

export class Entity_Door_Locked extends Entity_Door_Base {
  constructor(grid, sg, si, seg, eg, ei, horizontal, tx, ty) {
    super(grid, sg, si, seg, eg, ei, horizontal, tx, ty, 12 * (5 / 12), false);
  }
  OnCollision(sim) {
    sim.objGrid.ENTITY_Remove(this);
    this.ChangeDoorState(true);
  }
  GenerateGraphicComponent() {
    const p = this.GetDoorPos();
    return new EntityGraphics_Door_Locked(this, p.x, p.y, this.GetDoorOrn(), this.trigger_pos.x, this.trigger_pos.y);
  }
  GFX_UpdateState(g) { g.anim = this.IsDoorOpen() ? 1 : 0; }
  Debug_Draw() {}
}

export class Entity_Door_Trap extends Entity_Door_Base {
  constructor(grid, sg, si, seg, eg, ei, horizontal, tx, ty) {
    super(grid, sg, si, seg, eg, ei, horizontal, tx, ty, 12 * (5 / 12), true);
  }
  OnCollision(sim) {
    sim.objGrid.ENTITY_Remove(this);
    this.ChangeDoorState(false);
  }
  GenerateGraphicComponent() {
    const p = this.GetDoorPos();
    return new EntityGraphics_Door_Trap(this, p.x, p.y, this.GetDoorOrn(), this.trigger_pos.x, this.trigger_pos.y);
  }
  GFX_UpdateState(g) { g.anim = this.IsDoorOpen() ? 1 : 0; }
  Debug_Draw() {}
}

export class Entity_Turret extends Entity_Base {
  static STATE_IDLE = 0; static STATE_TARGETTING = 1; static STATE_PREFIRE = 2; static STATE_POSTFIRE = 3;
  constructor(grid, x, y) {
    super();
    this.timer_firetime = 60 * (sim_globals.sim_rate / 40);
    this.prefire_delay = 10 * (sim_globals.sim_rate / 40);
    this.postfire_delay = 10 * (sim_globals.sim_rate / 40);
    this.threshold2 = [9216, 1764, 576];
    this.aimspeed = [0.03, 0.035, 0.05, 0.05].map(v => v * (40 / sim_globals.sim_rate));
    this.timerstep = [0, 0.5, 1.5, 3.5];
    this.prediction_scale = sim_globals.sim_rate / 40;
    this.pos = new vec2(x, y);
    this.aim_pos = new vec2(x, y);
    this.aim_region = 0;
    this.shot_timer = 0;
    this.CUR_STATE = 0;
    this.targetIndex = -1;
    this.gfx_triggerEvent = false;
    this.HACKY_drawtimer = 0;
    this.HACKY_hit_pos = new vec2();
    this.HACKY_hit_n = new vec2();
    this.TEMP_hit_pos = new vec2();
    this.TEMP_hit_n = new vec2();
  }
  Think(sim) {
    this.TEMP_hit_pos.x = 0; this.TEMP_hit_pos.y = 0;
    this.TEMP_hit_n.x = 0; this.TEMP_hit_n.y = 0;
    if (this.CUR_STATE === 0) {
      const t = entity_helpers.TryToAquireTarget(this.pos, sim.playerList, sim.segGrid);
      if (t >= 0) this.Event_StartTargetting(t);
      return;
    }
    if (this.targetIndex < 0) return;
    if (this.CUR_STATE === 1) {
      if (!this.IsCurrentTargetVisible(sim, this.TEMP_hit_pos, this.TEMP_hit_n)) this.Event_StartIdling();
      else {
        this.UpdateAim(sim.playerList[this.targetIndex].GetPos(), sim.playerList[this.targetIndex].GetVel());
        if (this.shot_timer > this.timer_firetime) this.Event_StartFiring();
      }
    } else if (this.CUR_STATE === 2) {
      this.shot_timer++;
      if (this.shot_timer >= this.prefire_delay) {
        if (!sim.playerList[this.targetIndex].IsDead()) {
          let dx = this.aim_pos.x - this.pos.x, dy = this.aim_pos.y - this.pos.y;
          const l = Math.sqrt(dx * dx + dy * dy);
          dx /= l; dy /= l;
          const dist = sim.segGrid.GetRaycastDistance(this.pos.x, this.pos.y, dx, dy,
            this.HACKY_hit_pos, this.HACKY_hit_n);
          for (let i = 0; i < sim.playerList.length; i++) {
            if (!sim.playerList[i].IsDead()) {
              const p = sim.playerList[i].GetPos();
              const r = sim.playerList[i].GetRadius();
              if (colutils.Overlap_Circle_Vs_Segment(p, r, this.pos, this.HACKY_hit_pos, dist)) {
                const ox = p.x - this.pos.x, oy = p.y - this.pos.y;
                const t = dx * ox + dy * oy;
                this.HACKY_hit_pos.x = this.pos.x + t * dx;
                this.HACKY_hit_pos.y = this.pos.y + t * dy;
                this.HACKY_hit_n.x = 0; this.HACKY_hit_n.y = 0;
                sim.Event_PlayerWasKilled(sim.playerList[i], sim_globals.ENEMYTYPE_TURRET,
                  this.HACKY_hit_pos.x, this.HACKY_hit_pos.y, dx * 8, dy * 8);
              }
              this.HACKY_drawtimer = 10;
            }
          }
          sim.HACKY_GetParticleManager().Spawn_TurretBullet(this.pos, this.HACKY_hit_pos);
          this.gfx_triggerEvent = true;
        }
        this.Event_StopFiring();
      }
    } else if (this.CUR_STATE === 3) {
      this.shot_timer++;
      if (this.shot_timer >= this.postfire_delay) {
        if (this.IsCurrentTargetVisible(sim, this.TEMP_hit_pos, this.TEMP_hit_n)) this.Event_ResumeTargetting();
        else this.Event_StartIdling();
      }
    }
  }
  Event_StartIdling() { this.CUR_STATE = 0; this.targetIndex = -1; }
  Event_StartTargetting(i) { this.aim_pos.Copy(this.pos); this.shot_timer = 0; this.CUR_STATE = 1; this.targetIndex = i; }
  Event_ResumeTargetting() { this.shot_timer = 0; this.CUR_STATE = 1; }
  Event_StartFiring() { this.shot_timer = 0; this.CUR_STATE = 2; }
  Event_StopFiring() { this.shot_timer = 0; this.CUR_STATE = 3; }
  IsCurrentTargetVisible(sim, hitP, hitN) {
    const n = sim.playerList[this.targetIndex];
    if (n.IsDead()) return false;
    return sim.segGrid.RaycastVsPlayer(this.pos, n.GetPos(), n.GetRadius(), hitP, hitN);
  }
  UpdateAim(pos, vel) {
    const px = pos.x + vel.x * this.prediction_scale;
    const py = pos.y + vel.y * this.prediction_scale;
    const dx = px - this.aim_pos.x, dy = py - this.aim_pos.y;
    const d2 = dx * dx + dy * dy;
    this.aim_region = 0;
    for (let i = 0; i < this.threshold2.length; i++) {
      if (d2 > this.threshold2[i]) break;
      this.aim_region++;
    }
    this.shot_timer += this.timerstep[this.aim_region];
    const k = this.aimspeed[this.aim_region];
    this.aim_pos.x += k * dx;
    this.aim_pos.y += k * dy;
  }
  GenerateGraphicComponent() { return new EntityGraphics_Turret(this, this.pos.x, this.pos.y); }
  GFX_UpdateState(g) {
    g.pos_crosshair.x = this.aim_pos.x;
    g.pos_crosshair.y = this.aim_pos.y;
    if (this.gfx_triggerEvent) { g.anim_base = 2; this.gfx_triggerEvent = false; }
    else if (this.CUR_STATE === 0) { g.anim_base = 0; g.anim_crosshair = 0; }
    else if (this.CUR_STATE === 2) { g.anim_base = 1; g.anim_crosshair = 4; }
    else if (this.CUR_STATE === 3) { g.anim_base = 3; g.anim_crosshair = 5; }
    else if (this.CUR_STATE === 1) {
      if (this.aim_region === 0) g.anim_crosshair = 1;
      else if (this.aim_region === 1) g.anim_crosshair = 2;
      else if (this.aim_region === 2) g.anim_crosshair = 3;
    }
  }
  Debug_Draw() {}
}

export class Entity_Rocket extends Entity_Base {
  static STATE_IDLE = 0; static STATE_PREFIRE = 1; static STATE_HOMING = 2;
  constructor(grid, x, y) {
    super();
    this.accel_start = 0.1 * (40 / sim_globals.sim_rate) * (40 / sim_globals.sim_rate);
    this.maxspeed = 12 * (2 / 7) * (40 / sim_globals.sim_rate);
    this.accel_rate = Math.pow(1.1, 40 / sim_globals.sim_rate);
    this.turn_rate = 0.1 * (40 / sim_globals.sim_rate);
    this.prefire_delay = 10 * (sim_globals.sim_rate / 40);
    this.prediction_scale = sim_globals.sim_rate / 40;
    this.pos = new vec2(x, y);
    this.rocket_pos = new vec2(x, y);
    this.rocket_dir = new vec2(1, 0);
    this.rocket_speed = 0;
    this.rocket_accel = this.accel_start;
    this.shot_timer = 0;
    this.CUR_STATE = 0;
    this.targetIndex = -1;
    this.gfx_PREV_STATE = 0;
    this.nearSegs = [];
    this.old_pos = new vec2();
    this.rocket_vel = new vec2();
    this.hit_pos = new vec2();
    this.hit_n = new vec2();
  }
  CollideVsCircle_Logical(sim, ninja, result, pos, vel, oldpos, radius, skin) {
    if (this.CUR_STATE !== 2) return false;
    if (colutils.Overlap_Circle_Vs_Circle(this.rocket_pos, 0, pos, radius)) {
      this.Event_Explode(sim);
      const dx = pos.x - this.rocket_pos.x, dy = pos.y - this.rocket_pos.y;
      if (ninja === null) { result.vec_x = dx * 4; result.vec_y = dy * 4; return true; }
      sim.Event_PlayerWasKilled(ninja, sim_globals.ENEMYTYPE_ROCKET, this.rocket_pos.x, this.rocket_pos.y, dx, dy);
    }
    return false;
  }
  Think(sim) {
    this.gfx_PREV_STATE = this.CUR_STATE;
    if (this.CUR_STATE === 0) {
      const t = entity_helpers.TryToAquireTarget(this.pos, sim.playerList, sim.segGrid);
      if (t >= 0) { this.shot_timer = 0; this.CUR_STATE = 1; this.targetIndex = t; }
    } else if (this.CUR_STATE === 1) {
      if (sim.playerList[this.targetIndex].IsDead()) this.CUR_STATE = 0;
      else {
        this.shot_timer++;
        if (this.shot_timer >= this.prefire_delay) {
          this.rocket_pos.Copy(this.pos);
          this.rocket_accel = this.accel_start;
          this.rocket_speed = 0;
          let dx = sim.playerList[this.targetIndex].GetPos().x - this.pos.x;
          let dy = sim.playerList[this.targetIndex].GetPos().y - this.pos.y;
          const d2 = dx * dx + dy * dy;
          if (d2 !== 0) {
            dx /= Math.sqrt(d2); dy /= Math.sqrt(d2);
            this.rocket_dir.x = dx; this.rocket_dir.y = dy;
          } else { this.rocket_dir.x = 1; this.rocket_dir.y = 0; }
          sim.objGrid.ENTITY_Add(this.rocket_pos, this);
          this.CUR_STATE = 2;
        }
      }
    } else if (this.CUR_STATE === 2) {
      if (this.rocket_speed < this.maxspeed) {
        this.rocket_accel *= this.accel_rate;
        this.rocket_speed += this.rocket_accel;
      } else this.rocket_speed = this.maxspeed;
      this.old_pos.Copy(this.rocket_pos);
      this.rocket_vel.x = this.rocket_speed * this.rocket_dir.x;
      this.rocket_vel.y = this.rocket_speed * this.rocket_dir.y;
      this.rocket_pos.x += this.rocket_vel.x;
      this.rocket_pos.y += this.rocket_vel.y;
      sim.objGrid.ENTITY_Move(this.rocket_pos, this);
      sim.segGrid.GatherCellContentsFromWorldspaceRegion(
        Math.min(this.old_pos.x, this.rocket_pos.x), Math.min(this.old_pos.y, this.rocket_pos.y),
        Math.max(this.old_pos.x, this.rocket_pos.x), Math.max(this.old_pos.y, this.rocket_pos.y),
        this.nearSegs);
      this.hit_pos.x = 0; this.hit_pos.y = 0;
      this.hit_n.x = 0; this.hit_n.y = 0;
      let tbest = 2;
      for (const s of this.nearSegs) {
        const t = s.IntersectWithRay(this.old_pos, this.rocket_vel, 0, this.hit_pos, this.hit_n);
        if (t === -1) { this.Event_Explode(sim); return; }
        if (t < tbest) tbest = t;
      }
      if (tbest < 2) { this.Event_Explode(sim); return; }
      if (!sim.playerList[this.targetIndex].IsDead()) {
        const pv = sim.playerList[this.targetIndex].GetVel();
        const rx = this.rocket_pos.x + this.rocket_vel.x * this.prediction_scale;
        const ry = this.rocket_pos.y + this.rocket_vel.y * this.prediction_scale;
        const px = sim.playerList[this.targetIndex].GetPos().x + pv.x * this.prediction_scale;
        const py = sim.playerList[this.targetIndex].GetPos().y + pv.y * this.prediction_scale;
        let dx = px - rx, dy = py - ry;
        const d2 = dx * dx + dy * dy;
        if (d2 === 0) return;
        dx /= Math.sqrt(d2); dy /= Math.sqrt(d2);
        const px2 = -this.rocket_dir.y, py2 = this.rocket_dir.x;
        const cross = px2 * dx + py2 * dy;
        this.rocket_dir.x += this.turn_rate * cross * px2;
        this.rocket_dir.y += this.turn_rate * cross * py2;
        const l = this.rocket_dir.Len();
        if (l === 0) { this.rocket_dir.x = 0; this.rocket_dir.y = 0; }
        else this.rocket_dir.Scale(1 / l);
      }
      sim.HACKY_GetParticleManager().Spawn_RocketSmoke(this.rocket_pos,
        Math.atan2(this.rocket_dir.y, this.rocket_dir.x) / Math.PI * 180);
    }
  }
  Event_Explode(sim) {
    sim.objGrid.ENTITY_Remove(this);
    this.CUR_STATE = 0;
    this.targetIndex = -1;
    sim.HACKY_GetParticleManager().Spawn_Explosion(this.rocket_pos);
  }
  GenerateGraphicComponent() { return new EntityGraphics_Rocket(this, this.pos.x, this.pos.y); }
  GFX_UpdateState(g) {
    if (this.gfx_PREV_STATE === 1 && this.CUR_STATE === 2) g.anim_base = 1;
    else if (this.gfx_PREV_STATE === 2 && this.CUR_STATE !== 2) {
      g.is_rocket_active = false; g.anim_base = 2;
    } else if (this.CUR_STATE === 1 || this.CUR_STATE === 0) {
      g.is_rocket_active = false; g.anim_base = 0;
    }
    if (this.CUR_STATE === 2) {
      g.is_rocket_active = true;
      g.pos_rocket.x = this.rocket_pos.x; g.pos_rocket.y = this.rocket_pos.y;
      g.orn_rocket = Math.atan2(this.rocket_dir.y, this.rocket_dir.x);
    }
  }
  Debug_Draw() {}
}

export class Entity_Thwomp extends Entity_Base {
  constructor(grid, x, y, falldir, horizontal) {
    super();
    this.pos = new vec2(x, y);
    this.anchor = new vec2(x, y);
    this.r = 12 * (3 / 4);
    this.fallspeed = 12 * (5 / 14) * (40 / sim_globals.sim_rate);
    this.raisespeed = 12 * (1 / 7) * (40 / sim_globals.sim_rate);
    this.CUR_STATE = 0;
    this.falldir = falldir;
    this.isHorizontal = horizontal;
    this.n = new vec2();
    grid.ENTITY_Add(this.pos, this);
  }
  CollideVsCircle_Physical(result, pos, vel, oldpos, radius) {
    this.n.x = 0; this.n.y = 0;
    const pen = colutils.Penetration_Square_vs_Point(this.pos, this.r + radius, pos, this.n);
    if (pen !== 0) {
      result.isHardCollision = false;
      result.nx = this.n.x; result.ny = this.n.y;
      result.pen = pen;
      return true;
    }
    return false;
  }
  CollideVsCircle_Logical(sim, ninja, result, pos, vel, oldpos, radius, skin) {
    skin = 0.1;
    this.n.x = 0; this.n.y = 0;
    const pen = colutils.Penetration_Square_vs_Point(this.pos, skin + this.r + radius, pos, this.n);
    if (pen !== 0) {
      const dangerous = (this.isHorizontal && this.n.x * this.falldir > 0) ||
                        (!this.isHorizontal && this.n.y * this.falldir > 0);
      if (dangerous) {
        if (this.isHorizontal) sim.HACKY_GetParticleManager().Spawn_ZapThwompH(this.pos, this.r * this.falldir, this.r);
        else sim.HACKY_GetParticleManager().Spawn_ZapThwompV(this.pos, this.r, this.r * this.falldir);
        if (ninja === null) {
          result.vec_x = this.n.x * 8; result.vec_y = this.n.y * 8 - 4;
          return true;
        }
        sim.Event_PlayerWasKilled(ninja, sim_globals.ENEMYTYPE_THWOMP,
          pos.x - this.n.x * radius, pos.y - this.n.y * radius,
          this.n.x * 8, this.n.y * 8 - 4);
      } else if (ninja !== null) {
        result.vec_x = this.n.x; result.vec_y = this.n.y;
        return true;
      }
    }
    return false;
  }
  Think(sim) {
    if (this.CUR_STATE !== 0) return;
    const grid = sim.edgeGrid;
    for (let i = 0; i < sim.playerList.length; i++) {
      const n = sim.playerList[i];
      if (n.IsDead()) continue;
      const p = n.GetPos();
      const r = n.GetRadius();
      const dx = p.x - this.pos.x, dy = p.y - this.pos.y;
      const lim = 2 * (this.r + r);
      if (this.isHorizontal) {
        if (Math.abs(dy) < lim) {
          const c0 = grid.GetGridCoordinateFromWorldspace_1D(this.pos.x - this.falldir * this.r);
          const r0 = grid.GetGridCoordinateFromWorldspace_1D(this.pos.y - this.r);
          const r1 = grid.GetGridCoordinateFromWorldspace_1D(this.pos.y + this.r);
          const c1 = grid.SweepHorizontal(r0, r1, c0, this.falldir);
          const pc = grid.GetGridCoordinateFromWorldspace_1D(p.x);
          if (!(pc < Math.min(c0, c1) || pc > Math.max(c0, c1))) { this.CUR_STATE = 1; break; }
        }
      } else if (Math.abs(dx) < lim) {
        const r0 = grid.GetGridCoordinateFromWorldspace_1D(this.pos.y - this.falldir * this.r);
        const c0 = grid.GetGridCoordinateFromWorldspace_1D(this.pos.x - this.r);
        const c1 = grid.GetGridCoordinateFromWorldspace_1D(this.pos.x + this.r);
        const r1 = grid.SweepVertical(c0, c1, r0, this.falldir);
        const pr = grid.GetGridCoordinateFromWorldspace_1D(p.y);
        if (!(pr < Math.min(r0, r1) || pr > Math.max(r0, r1))) { this.CUR_STATE = 1; break; }
      }
    }
  }
  Move(sim) {
    if (this.CUR_STATE === 0) return;
    const grid = sim.edgeGrid;
    const dir = this.falldir * this.CUR_STATE;
    const off = dir * this.r;
    let speed = this.fallspeed;
    if (this.CUR_STATE === -1) speed = this.raisespeed;
    if (this.isHorizontal) {
      let nx = this.pos.x + dir * speed;
      if (this.CUR_STATE === -1 && (this.pos.x - this.anchor.x) * (nx - this.anchor.x) <= 0) nx = this.anchor.x;
      const c0 = grid.GetGridCoordinateFromWorldspace_1D(this.pos.x + off);
      const c1 = grid.GetGridCoordinateFromWorldspace_1D(nx + off);
      if (c0 !== c1) {
        const r0 = grid.GetGridCoordinateFromWorldspace_1D(this.pos.y - this.r);
        const r1 = grid.GetGridCoordinateFromWorldspace_1D(this.pos.y + this.r);
        if (!grid.IsEmpty_Column(c0, r0, r1, dir)) {
          if (this.CUR_STATE !== -1) this.CUR_STATE = -1;
          return;
        }
      }
      this.pos.x = nx;
      sim.objGrid.ENTITY_Move(this.pos, this);
      if (this.CUR_STATE === -1 && this.pos.x === this.anchor.x) this.CUR_STATE = 0;
    } else {
      let ny = this.pos.y + dir * speed;
      if (this.CUR_STATE === -1 && (this.pos.y - this.anchor.y) * (ny - this.anchor.y) <= 0) ny = this.anchor.y;
      const r0 = grid.GetGridCoordinateFromWorldspace_1D(this.pos.y + off);
      const r1 = grid.GetGridCoordinateFromWorldspace_1D(ny + off);
      if (r0 !== r1) {
        const c0 = grid.GetGridCoordinateFromWorldspace_1D(this.pos.x - this.r);
        const c1 = grid.GetGridCoordinateFromWorldspace_1D(this.pos.x + this.r);
        if (!grid.IsEmpty_Row(r0, c0, c1, dir)) {
          if (this.CUR_STATE !== -1) this.CUR_STATE = -1;
          return;
        }
      }
      this.pos.y = ny;
      sim.objGrid.ENTITY_Move(this.pos, this);
      if (this.CUR_STATE === -1 && this.pos.y === this.anchor.y) this.CUR_STATE = 0;
    }
  }
  GenerateGraphicComponent() {
    let rot = 0;
    if (this.isHorizontal) { if (this.falldir < 0) rot = Math.PI; }
    else if (this.falldir < 0) rot = 1.5 * Math.PI;
    else rot = 0.5 * Math.PI;
    return new EntityGraphics_Thwomp(this, rot);
  }
  GFX_UpdateState(g) { g.pos.x = this.pos.x; g.pos.y = this.pos.y; }
  Debug_Draw() {}
}

// ------------------------------------------------------------------ drones
const DIR_TO_VEC2 = [new vec2(1, 0), new vec2(0, 1), new vec2(-1, 0), new vec2(0, -1)];
const DIR_TO_RAD = [0, 0.5 * Math.PI, Math.PI, 1.5 * Math.PI];
const MOVELIST = [
  [1, 0, 3, 2],
  [3, 0, 1, 2],
  [0, 1, 3, 2],
  [0, 3, 1, 2],
];

export class Entity_Drone_Base extends Entity_Base {
  constructor(grid, x, y, speed, facing, moveType) {
    super();
    this.pos = new vec2(x, y);
    this.r = 12 * (3 / 4);
    this.speed = speed;
    this.step_size = 24;
    this.next_goal = this.pos.Clone();
    this.facing_DIR = facing;
    this.move_TYPE = moveType;
    this.gfxorn = DIR_TO_RAD[this.facing_DIR];
    grid.ENTITY_Add(this.pos, this);
  }
  Move(sim) {
    this.Move_Forward(sim.edgeGrid, sim.segGrid, sim.objGrid, sim.playerList);
    const target = DIR_TO_RAD[this.facing_DIR];
    const d = mathutils.WrapAngle_Shortest(target - this.gfxorn);
    this.gfxorn = mathutils.WrapAngle_Pos(this.gfxorn + 0.3 * d);
  }
  Move_Forward(edgeGrid, segGrid, objGrid, players) {
    const v = DIR_TO_VEC2[this.facing_DIR];
    const vx = v.x * this.speed, vy = v.y * this.speed;
    const nx = this.pos.x + vx, ny = this.pos.y + vy;
    const gx = this.next_goal.x - this.pos.x, gy = this.next_goal.y - this.pos.y;
    const rx = this.next_goal.x - nx, ry = this.next_goal.y - ny;
    const gl = Math.sqrt(gx * gx + gy * gy);
    const dot = gx * rx + gy * ry;
    if (gl < 0.000001 || dot < 0) {
      this.pos.Copy(this.next_goal);
      if (this.ChooseNextDirAndGoal(edgeGrid, players)) {
        const extra = Math.max(0, this.speed - gl);
        const nv = DIR_TO_VEC2[this.facing_DIR];
        this.pos.x += nv.x * extra;
        this.pos.y += nv.y * extra;
      }
    } else {
      this.pos.x += vx; this.pos.y += vy;
    }
    objGrid.ENTITY_Move(this.pos, this);
  }
  ChooseNextDirAndGoal(edgeGrid, players) {
    for (let i = 0; i < 4; i++) {
      const dir = (this.facing_DIR + MOVELIST[this.move_TYPE][i]) % 4;
      if (this.ChooseNextDirAndGoal_HELPER_TestDir(edgeGrid, dir, this.next_goal)) {
        this.facing_DIR = dir;
        return true;
      }
    }
    return false;
  }
  ChooseNextDirAndGoal_HELPER_TestDir(edgeGrid, dir, out) {
    const v = DIR_TO_VEC2[dir];
    const nx = this.pos.x + v.x * this.step_size;
    const ny = this.pos.y + v.y * this.step_size;
    if (v.y === 0) {
      const c0 = edgeGrid.GetGridCoordinateFromWorldspace_1D(this.pos.x + v.x * this.r);
      const c1 = edgeGrid.GetGridCoordinateFromWorldspace_1D(nx + v.x * this.r);
      const r0 = edgeGrid.GetGridCoordinateFromWorldspace_1D(this.pos.y - this.r);
      const r1 = edgeGrid.GetGridCoordinateFromWorldspace_1D(this.pos.y + this.r);
      if (!edgeGrid.ScanHorizontal_Directed(r0, r1, c0, c1, v.x)) return false;
    } else {
      if (v.x !== 0) return false;
      const r0 = edgeGrid.GetGridCoordinateFromWorldspace_1D(this.pos.y + v.y * this.r);
      const r1 = edgeGrid.GetGridCoordinateFromWorldspace_1D(ny + v.y * this.r);
      const c0 = edgeGrid.GetGridCoordinateFromWorldspace_1D(this.pos.x - this.r);
      const c1 = edgeGrid.GetGridCoordinateFromWorldspace_1D(this.pos.x + this.r);
      if (!edgeGrid.ScanVertical_Directed(c0, c1, r0, r1, v.y)) return false;
    }
    out.x = nx; out.y = ny;
    return true;
  }
  Debug_Draw() {}
}

export class Entity_Drone_Zap extends Entity_Drone_Base {
  constructor(grid, x, y, facing, moveType) {
    super(grid, x, y, 12 * (1 / 14) * 2 * (40 / sim_globals.sim_rate), facing, moveType);
  }
  CollideVsCircle_Logical(sim, ninja, result, pos, vel, oldpos, radius, skin) {
    if (colutils.Overlap_Circle_Vs_Circle(this.pos, this.r, pos, radius)) {
      let dx = pos.x - this.pos.x, dy = pos.y - this.pos.y;
      const l = Math.sqrt(dx * dx + dy * dy);
      dx /= l; dy /= l;
      sim.HACKY_GetParticleManager().Spawn_Zap(this.pos.x + dx * this.r, this.pos.y + dy * this.r,
        Math.atan2(dy, dx) / Math.PI * 180);
      if (ninja === null) {
        result.vec_x = dx * 12; result.vec_y = dy * 12 - 4;
        return true;
      }
      sim.Event_PlayerWasKilled(ninja, sim_globals.ENEMYTYPE_ZAP,
        pos.x - dx * radius, pos.y - dy * radius, dx * 12, dy * 12 - 4);
    }
    return false;
  }
  GenerateGraphicComponent() { return new EntityGraphics_Drone_Zap(this); }
  GFX_UpdateState(g) { g.pos.x = this.pos.x; g.pos.y = this.pos.y; g.orn = this.gfxorn; }
  Debug_Draw() {}
}

export class Entity_Drone_Chaser extends Entity_Drone_Zap {
  constructor(grid, x, y, facing, moveType) {
    super(grid, x, y, facing, moveType);
    this.isChasing = false;
    this.speed_regular = this.speed;
    this.speed_chasing = this.speed_regular * 2;
    this.gfx_startedChasing = false;
    this.old_chase_DIR = -1;
  }
  Think() {}
  StartChasing(dir) { this.facing_DIR = dir; this.speed = this.speed_chasing; this.isChasing = true; this.gfx_startedChasing = true; }
  StopChasing(dir) { this.old_chase_DIR = this.facing_DIR; this.facing_DIR = dir; this.speed = this.speed_regular; this.isChasing = false; }
  ChooseNextDirAndGoal(edgeGrid, players) {
    if (this.isChasing) {
      if (this.ChooseNextDirAndGoal_HELPER_TestDir(edgeGrid, this.facing_DIR, this.next_goal)) return true;
      const back = (this.facing_DIR - MOVELIST[this.move_TYPE][0] + 4) % 4;
      this.StopChasing(back);
    }
    let baseDir = this.facing_DIR;
    if (this.old_chase_DIR !== -1) {
      baseDir = this.old_chase_DIR;
      this.old_chase_DIR = -1;
    }
    for (let i = 0; i < players.length; i++) {
      if (players[i].IsDead()) continue;
      const p = players[i].GetPos();
      for (let k = -1; k <= 1; k++) {
        const dir = ((baseDir + k + 4) % 4);
        const v = DIR_TO_VEC2[dir];
        const dx = p.x - this.pos.x, dy = p.y - this.pos.y;
        if (v.x * dx + v.y * dy > 0 && Math.abs(-v.y * dx + v.x * dy) <= 12) {
          let horiz = true;
          let sgn = 1;
          if (dir % 2 === 1) horiz = false;
          if (dir >= 2) sgn = -1;
          if (horiz) {
            const c0 = edgeGrid.GetGridCoordinateFromWorldspace_1D(this.pos.x);
            const r0 = edgeGrid.GetGridCoordinateFromWorldspace_1D(this.pos.y);
            const c1 = edgeGrid.SweepHorizontal(r0, r0, c0, sgn);
            const pc = edgeGrid.GetGridCoordinateFromWorldspace_1D(p.x);
            if (pc < Math.min(c0, c1) || pc > Math.max(c0, c1)) continue;
          } else {
            const r0 = edgeGrid.GetGridCoordinateFromWorldspace_1D(this.pos.y);
            const c0 = edgeGrid.GetGridCoordinateFromWorldspace_1D(this.pos.x);
            const r1 = edgeGrid.SweepVertical(c0, c0, r0, sgn);
            const pr = edgeGrid.GetGridCoordinateFromWorldspace_1D(p.y);
            if (pr < Math.min(r0, r1) || pr > Math.max(r0, r1)) continue;
          }
          if (this.ChooseNextDirAndGoal_HELPER_TestDir(edgeGrid, dir, this.next_goal)) {
            this.StartChasing(dir);
            return true;
          }
        }
      }
    }
    return super.ChooseNextDirAndGoal(edgeGrid, players);
  }
  GenerateGraphicComponent() { return new EntityGraphics_Drone_Chaser(this); }
  GFX_UpdateState(g) {
    g.pos.x = this.pos.x; g.pos.y = this.pos.y; g.orn = this.gfxorn;
    if (this.gfx_startedChasing) { this.gfx_startedChasing = false; g.anim = 1; }
    else g.anim = 0;
  }
  Debug_Draw() {}
}

export class Entity_Drone_Shooter_Base extends Entity_Drone_Base {
  static IDLE = 0; static PREFIRING = 1; static FIRING = 2; static POSTFIRING = 3;
  constructor(grid, x, y, speed, facing, moveType, prefire, postfire) {
    super(grid, x, y, speed, facing, moveType);
    this.CUR_FIRING_STATE = 0;
    this.firing_timer = 0;
    this.prefire_delay = prefire;
    this.postfire_delay = postfire;
    this.targetIndex = -1;
  }
  Move(sim) { if (this.CUR_FIRING_STATE === 0) super.Move(sim); }
  GetFiringState() { return this.CUR_FIRING_STATE; }
  Think(sim) {
    if (this.CUR_FIRING_STATE === 0) {
      const t = entity_helpers.TryToAquireTarget(this.pos, sim.playerList, sim.segGrid);
      if (t >= 0) { this.Internal_StartPrefiring(sim, t, sim.playerList[t].GetPos()); return; }
    } else {
      if (this.targetIndex < 0) return;
      if (this.CUR_FIRING_STATE === 1) {
        if (sim.playerList[this.targetIndex].IsDead()) this.Internal_StartPostfiring(sim);
        else {
          this.Update_Prefiring(sim, sim.playerList[this.targetIndex].GetPos());
          this.firing_timer++;
          if (this.firing_timer >= this.prefire_delay)
            this.Internal_StartFiring(sim, sim.playerList[this.targetIndex].GetPos(), sim.playerList[this.targetIndex].GetVel());
        }
      } else if (this.CUR_FIRING_STATE === 2) {
        if (this.Update_Firing(sim)) this.Internal_StartPostfiring(sim);
      } else if (this.CUR_FIRING_STATE === 3) {
        this.firing_timer++;
        if (this.firing_timer >= this.postfire_delay) {
          for (let i = 0; i < sim.playerList.length; i++) {
            if (!sim.playerList[i].IsDead() &&
                sim.segGrid.RaycastVsPlayer(this.pos, sim.playerList[i].GetPos(), sim.playerList[i].GetRadius(), zero_vec, zero_vec)) {
              this.Internal_StartPrefiring(sim, i, sim.playerList[i].GetPos());
              return;
            }
          }
          this.Internal_StartIdling();
        }
      }
    }
  }
  Internal_StartPrefiring(sim, idx, p) { this.firing_timer = 0; this.CUR_FIRING_STATE = 1; this.targetIndex = idx; this.Start_Prefiring(sim, p); }
  Internal_StartFiring(sim, p, v) { this.CUR_FIRING_STATE = 2; this.Start_Firing(sim, p, v); }
  Internal_StartPostfiring(sim) { this.firing_timer = 0; this.CUR_FIRING_STATE = 3; this.Start_Postfiring(sim); }
  Internal_StartIdling() { this.CUR_FIRING_STATE = 0; this.targetIndex = -1; }
  Start_Prefiring() {}
  Update_Prefiring() {}
  Start_Firing() {}
  Update_Firing() { return true; }
  Start_Postfiring() {}
  Debug_Draw() {}
}
const zero_vec = new vec2();

export class Entity_Drone_Laser extends Entity_Drone_Shooter_Base {
  constructor(grid, x, y, facing, moveType) {
    super(grid, x, y, 12 * (1 / 14) * 0.5 * (40 / sim_globals.sim_rate), facing, moveType,
      30 * (sim_globals.sim_rate / 40), 40 * (sim_globals.sim_rate / 40));
    this.laser_duration = 80;
    this.laser_timer = 0;
    this.laser_dir = new vec2(0, 0);
    this.laser_hit_pos = new vec2();
    this.laser_hit_n = new vec2();
  }
  Start_Prefiring(sim, p) {
    this.laser_dir.x = p.x - this.pos.x;
    this.laser_dir.y = p.y - this.pos.y;
    this.laser_dir.Normalize();
    sim.segGrid.GetRaycastDistance(this.pos.x, this.pos.y, this.laser_dir.x, this.laser_dir.y,
      this.laser_hit_pos, this.laser_hit_n);
  }
  Update_Prefiring(sim) {
    sim.segGrid.GetRaycastDistance(this.pos.x, this.pos.y, this.laser_dir.x, this.laser_dir.y,
      this.laser_hit_pos, this.laser_hit_n);
    sim.HACKY_GetParticleManager().Spawn_LaserCharge(this.pos);
  }
  Start_Firing() { this.laser_timer = 0; }
  Update_Firing(sim) {
    const dist = sim.segGrid.GetRaycastDistance(this.pos.x, this.pos.y, this.laser_dir.x, this.laser_dir.y,
      this.laser_hit_pos, this.laser_hit_n);
    sim.HACKY_GetParticleManager().Spawn_LaserCharge(this.pos);
    for (let i = 0; i < sim.playerList.length; i++) {
      if (sim.playerList[i].IsDead()) continue;
      const p = sim.playerList[i].GetPos();
      if (colutils.Overlap_Circle_Vs_Segment(p, sim.playerList[i].GetRadius(), this.pos, this.laser_hit_pos, dist)) {
        const dx = p.x - this.pos.x, dy = p.y - this.pos.y;
        const t = this.laser_dir.x * dx + this.laser_dir.y * dy;
        sim.Event_PlayerWasKilled(sim.playerList[i], sim_globals.ENEMYTYPE_LASER,
          this.pos.x + t * this.laser_dir.x, this.pos.y + t * this.laser_dir.y,
          this.laser_dir.x * 6, this.laser_dir.y * 6);
      }
    }
    this.laser_timer++;
    return this.laser_timer >= this.laser_duration;
  }
  Start_Postfiring() {}
  GenerateGraphicComponent() { return new EntityGraphics_Drone_Laser(this); }
  GFX_UpdateState(g) {
    g.pos.x = this.pos.x; g.pos.y = this.pos.y; g.orn = this.gfxorn;
    const st = this.GetFiringState();
    if (st === 0) g.anim = 0;
    else if (st === 1) { g.anim = 1; g.blast_pos.x = this.laser_hit_pos.x; g.blast_pos.y = this.laser_hit_pos.y; }
    else if (st === 3) g.anim = 3;
    else if (st === 2) { g.anim = 2; g.blast_scale = 30 + 200 * (this.laser_timer / this.laser_duration); }
  }
  Debug_Draw() {}
}

export class Entity_Drone_Chaingun extends Entity_Drone_Shooter_Base {
  constructor(grid, x, y, facing, moveType) {
    // AS3 declares the prefire delay as an int local, so 52.5 truncates to 52.
    super(grid, x, y, 12 * (1 / 14) * 0.75 * (40 / sim_globals.sim_rate), facing, moveType,
      Math.trunc(35 * (sim_globals.sim_rate / 40)), 60 * (sim_globals.sim_rate / 40));
    this.chaingun_rate = 6 * (sim_globals.sim_rate / 40);
    this.chaingun_count = 0;
    this.chaingun_timer = 0;
    this.chaingun_dir = new vec2();
    this.chaingun_sweep = new vec2();
    this.chaingun_HACKY_hitmode = 0;
    this.chaingun_hit_pos = new vec2();
    this.chaingun_hit_n = new vec2();
  }
  Start_Prefiring() {}
  Update_Prefiring(sim, p) {
    const dx = p.x - this.pos.x, dy = p.y - this.pos.y;
    const d = mathutils.WrapAngle_Shortest(Math.atan2(dy, dx) - this.gfxorn);
    this.gfxorn += 0.2 * d;
  }
  Start_Firing(sim, p, vel) {
    this.chaingun_count = 0; this.chaingun_timer = 0; this.chaingun_HACKY_hitmode = 0;
    const dx = p.x - this.pos.x, dy = p.y - this.pos.y;
    let l = Math.sqrt(dx * dx + dy * dy);
    if (l === 0) {
      l = vel.Len();
      if (l === 0) { this.chaingun_dir.x = 1; this.chaingun_dir.y = 0; this.chaingun_sweep.x = 0; this.chaingun_sweep.y = 0; }
      else { this.chaingun_dir.x = vel.x / l; this.chaingun_dir.y = vel.y / l; this.chaingun_sweep.x = 0; this.chaingun_sweep.y = 0; }
    } else {
      this.chaingun_dir.x = dx / l; this.chaingun_dir.y = dy / l;
      const cross = -this.chaingun_dir.y * vel.x + this.chaingun_dir.x * vel.y;
      if (cross < 0) { this.chaingun_sweep.x = this.chaingun_dir.y; this.chaingun_sweep.y = -this.chaingun_dir.x; }
      else { this.chaingun_sweep.x = -this.chaingun_dir.y; this.chaingun_sweep.y = this.chaingun_dir.x; }
    }
  }
  Update_Firing(sim) {
    this.chaingun_timer++;
    if (this.chaingun_timer >= this.chaingun_rate) {
      this.chaingun_timer = 0;
      if (this.chaingun_count > 6) return true;
      this.chaingun_count++;
      const spread = (this.chaingun_count / 6 - 0.5) * 0.3;
      let dx = this.chaingun_dir.x + spread * this.chaingun_sweep.x;
      let dy = this.chaingun_dir.y + spread * this.chaingun_sweep.y;
      const l = Math.sqrt(dx * dx + dy * dy);
      dx /= l; dy /= l;
      this.gfxorn = Math.atan2(dy, dx);
      const dist = sim.segGrid.GetRaycastDistance(this.pos.x, this.pos.y, dx, dy,
        this.chaingun_hit_pos, this.chaingun_hit_n);
      sim.HACKY_GetParticleManager().Spawn_ChainBullet(this.pos, this.chaingun_hit_pos);
      for (let i = 0; i < sim.playerList.length; i++) {
        if (sim.playerList[i].IsDead()) continue;
        const p = sim.playerList[i].GetPos();
        if (colutils.Overlap_Circle_Vs_Segment(p, sim.playerList[i].GetRadius(), this.pos, this.chaingun_hit_pos, dist)) {
          const ox = p.x - this.pos.x, oy = p.y - this.pos.y;
          const t = dx * ox + dy * oy;
          this.chaingun_hit_pos.x = this.pos.x + t * dx;
          this.chaingun_hit_pos.y = this.pos.y + t * dy;
          sim.Event_PlayerWasKilled(sim.playerList[i], sim_globals.ENEMYTYPE_CHAINGUN,
            this.chaingun_hit_pos.x, this.chaingun_hit_pos.y, dx * 5, dy * 5);
        }
      }
      this.chaingun_HACKY_hitmode = 1;
    }
    return false;
  }
  Start_Postfiring() { if (this.chaingun_HACKY_hitmode < 2) this.chaingun_HACKY_hitmode = 0; }
  GenerateGraphicComponent() { return new EntityGraphics_Drone_Chaingun(this); }
  GFX_UpdateState(g) {
    g.pos.x = this.pos.x; g.pos.y = this.pos.y; g.orn = this.gfxorn;
    const st = this.GetFiringState();
    if (st === 0) g.anim = 0;
    else if (st === 1) g.anim = 1;
    else if (st === 3) g.anim = 3;
    else if (st === 2) g.anim = 2;
  }
  Debug_Draw() {}
}

export const entity_helpers = {
  potentialList: [],
  TryToAquireTarget(pos, players, segGrid) {
    const list = this.potentialList;
    list.length = 0;
    for (let i = 0; i < players.length; i++) {
      if (!players[i].IsDead() &&
          segGrid.RaycastVsPlayer(pos, players[i].GetPos(), players[i].GetRadius(), zero_vec, zero_vec))
        list.push(i);
    }
    if (list.length === 0) return -1;
    let best = 0;
    let p = players[list[0]].GetPos();
    let bd = (p.x - pos.x) * (p.x - pos.x) + (p.y - pos.y) * (p.y - pos.y);
    for (let i = 1; i < list.length; i++) {
      p = players[list[i]].GetPos();
      const d = (p.x - pos.x) * (p.x - pos.x) + (p.y - pos.y) * (p.y - pos.y);
      if (d < bd) best = i;
    }
    return list[best];
  },
};
