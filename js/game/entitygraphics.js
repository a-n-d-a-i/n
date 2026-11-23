/* Literal port of audiovisual/entitygraphics/*.as */
import { MovieClip, Sprite, ColorTransform } from "../flash.js";
import { vec2 } from "./math.js";
import { clip } from "../assets.js";

const asset_sfx_playerMC = clip("asset_sfx_playerMC");
const asset_sfx_playerLoopMC = clip("asset_sfx_playerLoopMC");
const asset_sfx_ragdollMC = clip("asset_sfx_ragdollMC");

import {
  asset_gfx_bounceblock, asset_gfx_gold, asset_gfx_mine, asset_gfx_oneway,
  asset_gfx_thwomp, asset_gfx_launchpad, asset_gfx_door_regular,
  asset_gfx_door_locked, asset_gfx_door_locked_switch, asset_gfx_door_trap,
  asset_gfx_door_trap_switch, asset_gfx_exitdoor, asset_gfx_exitswitch,
  asset_gfx_floorguard, asset_gfx_turret, asset_gfx_turret_crosshair,
  asset_gfx_drone_chaingun, asset_gfx_drone_chaingun_eye, asset_gfx_drone_eye,
  asset_gfx_drone_zap, asset_gfx_drone_chaser, asset_gfx_drone_laser,
  asset_gfx_laser_blast, asset_gfx_rocket, asset_gfx_rocket_base,
  asset_gfx_ninja, asset_gfx_ragdoll_body, asset_gfx_ragdoll_arm, asset_gfx_ragdoll_leg,
} from "../assets.js";

export class EntityGraphics {
  RegisterGraphics() {}
  UpdateState() {}
}

export class EntityGraphics_BounceBlock {
  constructor(entity) {
    this.entity = entity;
    this.mc = new asset_gfx_bounceblock();
    this.mc.cacheAsBitmap = true;
    this.pos = new vec2();
  }
  RegisterGraphics(list) { list.push(this.mc); }
  UpdateState() {
    this.entity.GFX_UpdateState(this);
    this.mc.x = this.pos.x; this.mc.y = this.pos.y;
  }
}

export class EntityGraphics_Gold {
  static ANIM_NOT_COLLECTED = 0;
  static ANIM_COLLECTED = 1;
  constructor(entity, x, y) {
    this.entity = entity;
    this.mc = new asset_gfx_gold();
    this.mc.x = x; this.mc.y = y;
    this.mc.gotoAndStop("not_collected");
    this.mc.cacheAsBitmap = true;
    this.anim = 0;
  }
  RegisterGraphics(list) { list.push(this.mc); }
  UpdateState() {
    const old = this.anim;
    this.entity.GFX_UpdateState(this);
    if (this.anim !== old && this.anim === 1) {
      this.mc.cacheAsBitmap = false;
      this.mc.gotoAndPlay("collected");
    }
  }
}

export class EntityGraphics_Mine {
  static ANIM_UNEXPLODED = 0;
  static ANIM_EXPLODED = 1;
  constructor(entity, x, y) {
    this.entity = entity;
    this.mc = new asset_gfx_mine();
    this.mc.x = x; this.mc.y = y;
    this.mc.gotoAndStop("unexploded");
    this.mc.cacheAsBitmap = true;
    this.anim = 0;
  }
  RegisterGraphics(list) { list.push(this.mc); }
  UpdateState() {
    const old = this.anim;
    this.entity.GFX_UpdateState(this);
    if (this.anim !== old && this.anim === 1) {
      this.mc.cacheAsBitmap = false;
      this.mc.gotoAndPlay("exploded");
    }
  }
}

export class EntityGraphics_OnewayPlatform {
  constructor(x, y, rot) {
    this.mc = new asset_gfx_oneway();
    this.mc.x = x; this.mc.y = y;
    this.mc.rotation = rot / Math.PI * 180;
    this.mc.cacheAsBitmap = true;
  }
  RegisterGraphics(list) { list.unshift(this.mc); }
  UpdateState() {}
}

export class EntityGraphics_Thwomp {
  constructor(entity, rot) {
    this.entity = entity;
    this.mc = new asset_gfx_thwomp();
    this.mc.rotation = rot / Math.PI * 180;
    this.mc.cacheAsBitmap = true;
    this.pos = new vec2();
  }
  RegisterGraphics(list) { list.push(this.mc); }
  UpdateState() {
    this.entity.GFX_UpdateState(this);
    this.mc.x = this.pos.x; this.mc.y = this.pos.y;
  }
}

export class EntityGraphics_Launchpad {
  static ANIM_IDLE = 0;
  static ANIM_LAUNCH = 1;
  constructor(entity, x, y, rot) {
    this.entity = entity;
    this.mc = new asset_gfx_launchpad();
    this.mc.x = x; this.mc.y = y;
    this.mc.rotation = rot / Math.PI * 180;
    this.mc.gotoAndStop("idle");
    this.mc.cacheAsBitmap = true;
    this.anim = 0;
  }
  RegisterGraphics(list) { list.unshift(this.mc); }
  UpdateState() {
    const old = this.anim;
    this.entity.GFX_UpdateState(this);
    if (this.anim !== old && this.anim === 1) this.mc.gotoAndPlay("launch");
  }
}

export class EntityGraphics_Door_Regular {
  static ANIM_CLOSE = 0;
  static ANIM_OPEN = 1;
  constructor(entity, x, y, rot) {
    this.entity = entity;
    this.mc_door = new asset_gfx_door_regular();
    this.mc_door.x = x; this.mc_door.y = y;
    this.mc_door.rotation = rot / Math.PI * 180;
    this.mc_door.gotoAndStop("closed");
    this.anim = 0;
  }
  RegisterGraphics(list) { list.push(this.mc_door); }
  UpdateState() {
    const old = this.anim;
    this.entity.GFX_UpdateState(this);
    if (this.anim !== old) {
      if (this.anim === 0) this.mc_door.gotoAndPlay("close");
      else if (this.anim === 1) this.mc_door.gotoAndPlay("open");
    }
  }
}

export class EntityGraphics_Door_Locked {
  static ANIM_CLOSE = 0;
  static ANIM_OPEN = 1;
  constructor(entity, x, y, rot, sx, sy) {
    this.entity = entity;
    this.mc_door = new asset_gfx_door_locked();
    this.mc_switch = new asset_gfx_door_locked_switch();
    this.mc_door.x = x; this.mc_door.y = y;
    this.mc_door.rotation = rot / Math.PI * 180;
    this.mc_door.gotoAndStop("closed");
    this.mc_switch.x = sx; this.mc_switch.y = sy;
    this.mc_switch.gotoAndStop("closed");
    this.mc_switch.cacheAsBitmap = true;
    this.anim = 0;
  }
  RegisterGraphics(list) { list.push(this.mc_door); list.unshift(this.mc_switch); }
  UpdateState() {
    const old = this.anim;
    this.entity.GFX_UpdateState(this);
    if (this.anim !== old && this.anim === 1) {
      this.mc_door.gotoAndPlay("open");
      this.mc_switch.gotoAndPlay("open");
    }
  }
}

export class EntityGraphics_Door_Trap {
  static ANIM_CLOSE = 0;
  static ANIM_OPEN = 1;
  constructor(entity, x, y, rot, sx, sy) {
    this.entity = entity;
    this.mc_door = new asset_gfx_door_trap();
    this.mc_switch = new asset_gfx_door_trap_switch();
    this.mc_door.x = x; this.mc_door.y = y;
    this.mc_door.rotation = rot / Math.PI * 180;
    this.mc_door.gotoAndStop("opened");
    this.mc_switch.x = sx; this.mc_switch.y = sy;
    this.mc_switch.gotoAndStop("open");
    this.mc_switch.cacheAsBitmap = true;
    this.anim = 1;
  }
  RegisterGraphics(list) { list.push(this.mc_door); list.unshift(this.mc_switch); }
  UpdateState() {
    const old = this.anim;
    this.entity.GFX_UpdateState(this);
    if (this.anim !== old && this.anim === 0) {
      this.mc_door.gotoAndPlay("close");
      this.mc_switch.gotoAndPlay("closed");
    }
  }
}

export class EntityGraphics_ExitDoor {
  static ANIM_CLOSED = 0;
  static ANIM_OPEN = 1;
  constructor(entity, x, y) {
    this.entity = entity;
    this.mc = new asset_gfx_exitdoor();
    this.mc.x = x; this.mc.y = y;
    this.mc.gotoAndStop("closed");
    this.anim = 0;
  }
  RegisterGraphics(list) { list.unshift(this.mc); }
  UpdateState() {
    const old = this.anim;
    this.entity.GFX_UpdateState(this);
    if (this.anim !== old && this.anim === 1) this.mc.gotoAndPlay("open");
  }
}

export class EntityGraphics_ExitSwitch {
  static ANIM_CLOSED = 0;
  static ANIM_OPEN = 1;
  constructor(entity, x, y) {
    this.entity = entity;
    this.mc = new asset_gfx_exitswitch();
    this.mc.x = x; this.mc.y = y;
    this.mc.gotoAndStop("closed");
    this.anim = 0;
  }
  RegisterGraphics(list) { list.unshift(this.mc); }
  UpdateState() {
    const old = this.anim;
    this.entity.GFX_UpdateState(this);
    if (this.anim !== old && this.anim === 1) this.mc.gotoAndStop("open");
  }
}

export class EntityGraphics_FloorGuard {
  static ANIM_IDLE = 0;
  static ANIM_CHASE_L = -1;
  static ANIM_CHASE_R = 1;
  constructor(entity) {
    this.entity = entity;
    this.mc = new asset_gfx_floorguard();
    this.mc.cacheAsBitmap = true;
    this.pos = new vec2();
    this.anim = 0;
  }
  RegisterGraphics(list) { list.push(this.mc); }
  UpdateState() {
    const old = this.anim;
    this.entity.GFX_UpdateState(this);
    this.mc.x = this.pos.x; this.mc.y = this.pos.y;
    if (this.anim !== old) {
      if (this.anim === 1 || this.anim === -1) this.mc.gotoAndPlay("chase");
      else if (this.anim === 0) this.mc.gotoAndStop("idle");
    }
  }
}

export class EntityGraphics_Drone_Chaingun {
  static ANIM_MOVE = 0; static ANIM_PREFIRE = 1; static ANIM_FIRING = 2; static ANIM_POSTFIRE = 3;
  constructor(entity) {
    this.entity = entity;
    this.mc_body = new asset_gfx_drone_chaingun();
    this.mc_eye = new asset_gfx_drone_chaingun_eye();
    this.mc_body.addChild(this.mc_eye);
    this.pos = new vec2(); this.orn = 0; this.anim = 0;
    this.mc_body.gotoAndStop("move");
  }
  RegisterGraphics(list) { list.push(this.mc_body); }
  UpdateState() {
    const old = this.anim;
    this.entity.GFX_UpdateState(this);
    this.mc_body.x = this.pos.x; this.mc_body.y = this.pos.y;
    this.mc_eye.rotation = this.orn / Math.PI * 180;
    if (this.anim !== old) {
      if (this.anim === 0) this.mc_body.gotoAndStop("move");
      else if (this.anim === 1) this.mc_body.gotoAndPlay("prefire");
      else if (this.anim === 3) this.mc_body.gotoAndPlay("postfire");
      else if (this.anim === 2) this.mc_body.gotoAndStop("fire");
    }
  }
}

export class EntityGraphics_Drone_Chaser {
  static ANIM_IDLE = 0; static ANIM_CHASE = 1;
  constructor(entity) {
    this.entity = entity;
    this.mc_body = new asset_gfx_drone_chaser();
    this.mc_eye = new asset_gfx_drone_eye();
    this.mc_body.cacheAsBitmap = true;
    this.pos = new vec2(); this.orn = 0; this.anim = 0;
    this.mc_body.gotoAndStop("idle");
  }
  RegisterGraphics(list) { list.push(this.mc_body); list.push(this.mc_eye); }
  UpdateState() {
    this.entity.GFX_UpdateState(this);
    this.mc_body.x = this.pos.x; this.mc_body.y = this.pos.y;
    this.mc_eye.x = this.pos.x; this.mc_eye.y = this.pos.y;
    this.mc_eye.rotation = this.orn / Math.PI * 180;
    if (this.anim === 1) { this.mc_body.gotoAndPlay("chase"); this.anim = 0; }
    else if (this.anim === 0) this.mc_body.gotoAndStop("idle");
  }
}

export class EntityGraphics_Drone_Zap {
  constructor(entity) {
    this.entity = entity;
    this.mc_body = new asset_gfx_drone_zap();
    this.mc_eye = new asset_gfx_drone_eye();
    this.mc_body.cacheAsBitmap = true;
    this.pos = new vec2(); this.orn = 0;
  }
  RegisterGraphics(list) { list.push(this.mc_body); list.push(this.mc_eye); }
  UpdateState() {
    this.entity.GFX_UpdateState(this);
    this.mc_body.x = this.pos.x; this.mc_body.y = this.pos.y;
    this.mc_eye.x = this.pos.x; this.mc_eye.y = this.pos.y;
    this.mc_eye.rotation = this.orn / Math.PI * 180;
  }
}

export class EntityGraphics_Drone_Laser {
  static ANIM_MOVE = 0; static ANIM_PREFIRE = 1; static ANIM_FIRING = 2; static ANIM_POSTFIRE = 3;
  constructor(entity) {
    this.entity = entity;
    this.mc_body = new asset_gfx_drone_laser();
    this.mc_eye = new asset_gfx_drone_eye();
    this.mc_blast = new asset_gfx_laser_blast();
    this.mc_beam = new Sprite();
    this.pos = new vec2(); this.orn = 0; this.anim = 0;
    this.mc_body.gotoAndStop("move");
    this.blast_pos = new vec2(); this.blast_scale = 0;
  }
  RegisterGraphics(list) {
    list.push(this.mc_beam); list.push(this.mc_body); list.push(this.mc_eye); list.push(this.mc_blast);
  }
  UpdateState() {
    const old = this.anim;
    this.entity.GFX_UpdateState(this);
    this.mc_body.x = this.pos.x; this.mc_body.y = this.pos.y;
    this.mc_eye.x = this.pos.x; this.mc_eye.y = this.pos.y;
    this.mc_eye.rotation = this.orn / Math.PI * 180;
    if (this.anim !== old) {
      if (this.anim === 0) this.mc_body.gotoAndStop("move");
      else if (this.anim === 1) {
        this.mc_body.gotoAndPlay("prefire");
        this.mc_beam.visible = true;
        this.mc_beam.graphics.clear();
        this.mc_beam.graphics.lineStyle(0, 13334137);
        this.mc_beam.graphics.moveTo(this.pos.x, this.pos.y);
        this.mc_beam.graphics.lineTo(this.blast_pos.x, this.blast_pos.y);
      } else if (this.anim === 3) {
        this.mc_body.gotoAndPlay("postfire");
        this.mc_beam.visible = false;
        this.mc_blast.visible = false;
        this.mc_blast.gotoAndStop(1);
      } else if (this.anim === 2) {
        this.mc_body.gotoAndStop("firing");
        this.mc_beam.graphics.clear();
        this.mc_beam.graphics.lineStyle(3, 8921634);
        this.mc_beam.graphics.moveTo(this.pos.x, this.pos.y);
        this.mc_beam.graphics.lineTo(this.blast_pos.x, this.blast_pos.y);
        this.mc_blast.visible = true;
        this.mc_blast.gotoAndPlay(1);
        this.mc_blast.x = this.blast_pos.x;
        this.mc_blast.y = this.blast_pos.y;
        this.mc_blast.scaleX = this.mc_blast.scaleY = 0;
      }
    }
    if (this.anim === 2) {
      this.mc_blast.scaleX = this.mc_blast.scaleY = this.blast_scale / 100;
    }
  }
}

export class EntityGraphics_Turret {
  static ANIM_IDLE = 0; static ANIM_PREFIRE = 1; static ANIM_FIRING = 2; static ANIM_POSTFIRE = 3;
  static CROSSHAIR_OFF = 0; static CROSSHAIR_FAR = 1; static CROSSHAIR_MID = 2;
  static CROSSHAIR_NEAR = 3; static CROSSHAIR_PREFIRE = 4; static CROSSHAIR_POSTFIRE = 5;
  constructor(entity, x, y) {
    this.entity = entity;
    this.mc_base = new asset_gfx_turret();
    this.mc_base.x = x; this.mc_base.y = y;
    this.mc_base.gotoAndStop("idle");
    this.anim_base = 0;
    this.mc_base.cacheAsBitmap = true;
    this.mc_crosshair = new asset_gfx_turret_crosshair();
    this.mc_crosshair.gotoAndStop("aim_off");
    this.anim_crosshair = 0;
    this.pos_crosshair = new vec2();
  }
  RegisterGraphics(list) { list.unshift(this.mc_base); list.push(this.mc_crosshair); }
  UpdateState() {
    const oldB = this.anim_base, oldC = this.anim_crosshair;
    this.entity.GFX_UpdateState(this);
    if (this.anim_base !== oldB) {
      if (this.anim_base === 0) this.mc_base.gotoAndStop("idle");
      else if (this.anim_base === 1) this.mc_base.gotoAndPlay("prefire");
      else if (this.anim_base === 3) this.mc_base.gotoAndPlay("postfire");
      else if (this.anim_base === 2) this.mc_base.gotoAndPlay("firing");
    }
    this.mc_crosshair.x = this.pos_crosshair.x;
    this.mc_crosshair.y = this.pos_crosshair.y;
    if (this.anim_crosshair !== oldC) {
      if (this.anim_crosshair === 0) this.mc_crosshair.gotoAndStop("aim_off");
      else if (this.anim_crosshair === 1) this.mc_crosshair.gotoAndStop("aim_far");
      else if (this.anim_crosshair === 2) this.mc_crosshair.gotoAndStop("aim_mid");
      else if (this.anim_crosshair === 3) this.mc_crosshair.gotoAndStop("aim_near");
      else if (this.anim_crosshair === 4) this.mc_crosshair.gotoAndStop("prefire");
      else if (this.anim_crosshair === 5) this.mc_crosshair.gotoAndStop("postfire");
    }
  }
}

export class EntityGraphics_Rocket {
  static ANIM_IDLE = 0; static ANIM_FIRE = 1; static ANIM_EXPLODE = 2;
  constructor(entity, x, y) {
    this.entity = entity;
    this.mc_base = new asset_gfx_rocket_base();
    this.mc_base.x = x; this.mc_base.y = y;
    this.mc_base.gotoAndStop("idle");
    this.anim_base = 0;
    this.mc_base.cacheAsBitmap = true;
    this.mc_rocket = new asset_gfx_rocket();
    this.mc_rocket.visible = false;
    this.pos_rocket = new vec2(); this.orn_rocket = 0;
    this.is_rocket_active = false;
  }
  RegisterGraphics(list) { list.unshift(this.mc_base); list.push(this.mc_rocket); }
  UpdateState() {
    const old = this.anim_base;
    this.entity.GFX_UpdateState(this);
    if (this.anim_base !== old) {
      if (this.anim_base === 0) this.mc_base.gotoAndStop("idle");
      else if (this.anim_base === 1) this.mc_base.gotoAndPlay("fire");
      else if (this.anim_base === 2) this.mc_base.gotoAndPlay("explode");
    }
    if (this.is_rocket_active) {
      this.mc_rocket.visible = true;
      this.mc_rocket.x = this.pos_rocket.x;
      this.mc_rocket.y = this.pos_rocket.y;
      this.mc_rocket.rotation = this.orn_rocket / Math.PI * 180;
    } else this.mc_rocket.visible = false;
  }
}

export class EntityGraphics_Ninja {
  static ANIM_STANDING = 0; static ANIM_RUNNING = 1; static ANIM_SKIDDING = 2;
  static ANIM_INAIR = 3; static ANIM_WALLSLIDING = 4; static ANIM_DEAD = 5;
  static ANIM_CELEBRATING = 6; static ANIM_OFF = 7;
  static RAGDOLL_BODY = 0; static RAGDOLL_ARM_R = 1; static RAGDOLL_ARM_L = 2;
  static RAGDOLL_LEG_R = 3; static RAGDOLL_LEG_L = 4;

  constructor(entity, color) {
    this.sndLoopMC = new asset_sfx_playerLoopMC();
    this.sndMC = new asset_sfx_playerMC();
    this.sndLoopMC._alwaysTick = true;
    this.sndMC._alwaysTick = true;
    this.entity = entity;
    this.mc_sprite = new asset_gfx_ninja();
    this.mc_sprite.gotoAndPlay("STAND");
    this.pos = new vec2(); this.vel = 0; this.orn = 0; this.facing = 1;
    this.anim = 0; this.run_anim_leftovers = 0; this.scaling_factor = 0.2;
    this.prev_frame = 1;
    this.ragdoll_mcList = [];
    this.ragdoll_mcList[0] = new asset_gfx_ragdoll_body();
    this.ragdoll_mcList[1] = new asset_gfx_ragdoll_arm();
    this.ragdoll_mcList[2] = new asset_gfx_ragdoll_arm();
    this.ragdoll_mcList[3] = new asset_gfx_ragdoll_leg();
    this.ragdoll_mcList[4] = new asset_gfx_ragdoll_leg();
    this.ragdoll_posList = [new vec2(), new vec2(), new vec2(), new vec2(), new vec2()];
    this.ragdoll_lenList = [0, 0, 0, 0, 0];
    this.ragdoll_ornList = [0, 0, 0, 0, 0];
    this.ragdoll_flipList = [-1, 1, 1, -1, -1];
    const ct = new ColorTransform();
    ct.color = color;
    this.mc_sprite.transform.colorTransform = ct;
    for (const mc of this.ragdoll_mcList) mc.transform.colorTransform = ct;
  }
  HACKY_PlayOneshotSound(label) { this.sndMC.gotoAndPlay(label); }
  dispose() {
    if (this.sndMC) this.sndMC.dispose();
    if (this.sndLoopMC) this.sndLoopMC.dispose();
  }
  get hasValidPose() {
    return !!(this.mc_sprite.shoulder && this.mc_sprite.pelvis &&
              this.mc_sprite.handR && this.mc_sprite.handL &&
              this.mc_sprite.footR && this.mc_sprite.footL);
  }
  NINJA_GetCurrentPose(pose, delta) {
    const mc = this.mc_sprite;
    const cur = mc.currentFrame;
    pose[0] = new vec2(mc.shoulder.x, mc.shoulder.y);
    pose[1] = new vec2(mc.pelvis.x, mc.pelvis.y);
    pose[2] = new vec2(mc.handR.x, mc.handR.y);
    pose[3] = new vec2(mc.handL.x, mc.handL.y);
    pose[4] = new vec2(mc.footR.x, mc.footR.y);
    pose[5] = new vec2(mc.footL.x, mc.footL.y);
    mc.gotoAndStop(this.prev_frame);
    delta[0] = new vec2(pose[0].x - mc.shoulder.x, pose[0].y - mc.shoulder.y);
    delta[1] = new vec2(pose[1].x - mc.pelvis.x, pose[1].y - mc.pelvis.y);
    delta[2] = new vec2(pose[2].x - mc.handR.x, pose[2].y - mc.handR.y);
    delta[3] = new vec2(pose[3].x - mc.handL.x, pose[3].y - mc.handL.y);
    delta[4] = new vec2(pose[4].x - mc.footR.x, pose[4].y - mc.footR.y);
    delta[5] = new vec2(pose[5].x - mc.footL.x, pose[5].y - mc.footL.y);
    for (let i = 0; i < 6; i++) {
      pose[i].Scale(this.scaling_factor);
      delta[i].Scale(this.scaling_factor);
    }
  }
  RegisterGraphics(list) {
    list.push(this.mc_sprite);
    for (const mc of this.ragdoll_mcList) list.push(mc);
  }
  Hide() {
    this.mc_sprite.visible = false;
    for (const mc of this.ragdoll_mcList) mc.visible = false;
  }
  UpdateState() {
    const oldAnim = this.anim;
    this.entity.GFX_UpdateState(this);
    if (this.anim === EntityGraphics_Ninja.ANIM_OFF) {
      this.mc_sprite.visible = false;
      for (const mc of this.ragdoll_mcList) mc.visible = false;
    } else if (this.anim === EntityGraphics_Ninja.ANIM_DEAD) {
      this.sndLoopMC.gotoAndPlay("wallslide_stop");
      this.sndLoopMC.gotoAndPlay("skid_stop");
      this.mc_sprite.visible = false;
      for (let i = 0; i < this.ragdoll_mcList.length; i++) {
        const mc = this.ragdoll_mcList[i];
        mc.visible = true;
        mc.x = this.ragdoll_posList[i].x;
        mc.y = this.ragdoll_posList[i].y;
        mc.scaleX = this.scaling_factor;
        mc.scaleY = this.ragdoll_flipList[i] * this.facing * this.scaling_factor;
        mc.rotation = this.ragdoll_ornList[i] / Math.PI * 180;
        mc.gotoAndStop(1 + Math.floor(100 * this.ragdoll_lenList[i]));
      }
    } else {
      this.prev_frame = this.mc_sprite.currentFrame;
      this.mc_sprite.visible = true;
      for (const mc of this.ragdoll_mcList) mc.visible = false;
      this.mc_sprite.x = this.pos.x;
      this.mc_sprite.y = this.pos.y;
      this.mc_sprite.scaleX = this.facing * this.scaling_factor;
      this.mc_sprite.scaleY = this.scaling_factor;
      this.mc_sprite.rotation = this.orn / Math.PI * 180;
      if (this.anim !== oldAnim) {
        if (oldAnim === EntityGraphics_Ninja.ANIM_WALLSLIDING) this.sndLoopMC.gotoAndPlay("wallslide_stop");
        else if (oldAnim === EntityGraphics_Ninja.ANIM_SKIDDING) this.sndLoopMC.gotoAndPlay("skid_stop");
        if (this.anim === EntityGraphics_Ninja.ANIM_STANDING) this.mc_sprite.gotoAndPlay("STAND");
        else if (this.anim === EntityGraphics_Ninja.ANIM_SKIDDING) {
          this.mc_sprite.gotoAndStop("SKID");
          this.sndLoopMC.soundTransform.volume = 0;
          this.sndLoopMC.gotoAndPlay("skid_start");
        } else if (this.anim === EntityGraphics_Ninja.ANIM_WALLSLIDING) {
          this.mc_sprite.gotoAndStop("WALLSLIDE");
          this.sndLoopMC.soundTransform.volume = 0;
          this.sndLoopMC.gotoAndPlay("wallslide_start");
        } else if (this.anim === EntityGraphics_Ninja.ANIM_RUNNING) {
          this.mc_sprite.gotoAndStop("RUN");
        } else if (this.anim === EntityGraphics_Ninja.ANIM_CELEBRATING) {
          const r = Math.floor(Math.random() * 999) % 9 + 1;
          this.mc_sprite.gotoAndPlay("CELEBRATE_NEW" + r);
        }
      }
      if (this.anim === EntityGraphics_Ninja.ANIM_WALLSLIDING) {
        this.sndLoopMC.soundTransform.volume = Math.min(1, Math.abs(this.vel * 0.7));
      } else if (this.anim === EntityGraphics_Ninja.ANIM_SKIDDING) {
        this.sndLoopMC.soundTransform.volume = Math.min(1, Math.abs(this.vel));
      }
      if (this.anim === EntityGraphics_Ninja.ANIM_INAIR) {
        const base = 94;
        const neg = -1 * (40 / 60);
        const posv = 2.5 * (40 / 60);
        let k;
        if (this.vel < 0) k = this.vel < neg ? -1 : -(this.vel / neg);
        else if (this.vel > posv) k = 1;
        else k = Math.sqrt(this.vel / posv);
        this.mc_sprite.gotoAndStop(base + Math.floor(k * 9));
      } else if (this.anim === EntityGraphics_Ninja.ANIM_RUNNING) {
        const v = this.vel;
        const base = 13;
        const total = 72;
        const rate = 0.9;
        const cur = this.mc_sprite.currentFrame - base;
        let f = v / rate + this.run_anim_leftovers;
        const whole = Math.floor(f);
        this.run_anim_leftovers = f - whole;
        const frame = (cur + whole) % total;
        this.mc_sprite.gotoAndStop(base + frame);
      }
    }
  }
}
