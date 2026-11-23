/* Literal port of simulation/Simulator.as */
import { vec2, mathutils } from "./math.js";
import { edat } from "./editorstate.js";
import { sim_globals, Entity_Thwomp } from "./entities.js";
import { Ninja } from "./ninja.js";

export class Simulator {
  static GRID_NUM_COLS = edat.num_cols + 2;
  static GRID_NUM_ROWS = edat.num_rows + 2;
  static GRID_CELL_SIZE = 24;
  static GRID_CELL_HALFWIDTH = 12;

  constructor(tileIDs, segGrid, edgeGrid, objGrid, objList, players) {
    this.tileIDs = tileIDs;
    this.segGrid = segGrid;
    this.edgeGrid = edgeGrid;
    this.objGrid = objGrid;
    this.objList = objList;
    this.playerList = players;
    this.frame_num = 0;
    this.num_gold_collected_during_tick = new Array(players.length).fill(0);
    this.STATEFLAG_won = false;
    this.HACKY_gfx = null;
    this.HACKY_sfx = null;
    mathutils.SetRandomSeed(1);
  }
  HACKY_SetAV(gfx, sfx) { this.HACKY_gfx = gfx; this.HACKY_sfx = sfx; }
  HACKY_GetParticleManager() { return this.HACKY_gfx.GetParticleManager(); }
  HACKY_GetSoundManager() { return this.HACKY_sfx; }
  GFX_GetEntityList() { return this.objList; }
  GFX_GetPlayerList() { return this.playerList; }
  GFX_GetTileIDs() { return this.tileIDs; }

  Tick(debugRenderer) {
    for (let i = 0; i < this.num_gold_collected_during_tick.length; i++)
      this.num_gold_collected_during_tick[i] = 0;
    for (const e of this.objList) e.Move(this);
    for (const e of this.objList) e.Think(this);
    for (const p of this.playerList) { p.Integrate(); p.PreCollision(); }
    for (let it = 0; it < 4; it++) {
      for (const p of this.playerList) p.SolveInternalConstraints();
      for (const p of this.playerList) p.CollideVsObjects(this);
      for (const p of this.playerList) p.CollideVsTiles(this);
    }
    for (const p of this.playerList) p.PostCollision(this);
    for (const p of this.playerList) p.Think(this, this.frame_num);
    this.frame_num++;
  }
  InternalEvent_KillPlayer(p, type, x, y, fx, fy) { p.SIM_Kill(type, x, y, fx, fy); }
  Event_Launchpad_HitPlayer(p, x, y) { p.SIM_Launch(x, y); }
  Event_Exit_HitPlayer(p) {
    this.STATEFLAG_won = true;
    for (const q of this.playerList) q.SIM_Win();
  }
  Event_Gold_HitPlayer(p) {
    if (!this.STATEFLAG_won) { this.num_gold_collected_during_tick[p.GetIndex()]++; return true; }
    return false;
  }
  Event_PlayerWasKilled(p, type, x, y, fx, fy) { this.InternalEvent_KillPlayer(p, type, x, y, fx, fy); }
  AreAllPlayersDead() { return this.playerList.every(p => p.IsDead()); }
  APP_Event_TimeUp() {
    for (const p of this.playerList) this.InternalEvent_KillPlayer(p, sim_globals.ENEMYTYPE_TIME, 0, 0, 0, 0);
  }
  APP_Event_Suicide(i) { this.InternalEvent_KillPlayer(this.playerList[i], sim_globals.ENEMYTYPE_SUICIDE, 0, 0, 0, 0); }
  APP_IsPlayerDead(i) { return this.playerList[i].IsDead(); }
  APP_IsGameDone() { return this.STATEFLAG_won || this.AreAllPlayersDead(); }
  APP_DidPlayerWin() { return this.APP_IsGameDone() ? this.STATEFLAG_won : false; }
  APP_EnablePlayer(i) { this.playerList[i].APP_Enable(); }
  APP_DisablePlayer(i) { this.playerList[i].APP_Disable(); }
  App_EnableAllPlayers() { for (const p of this.playerList) p.APP_Enable(); }
  App_DisableAllPlayers() { for (const p of this.playerList) p.APP_Disable(); }
  APP_GetNumGoldCollectedDuringTick(i) { return this.num_gold_collected_during_tick[i]; }
  APP_IsPlaybackFinished() { return this.playerList.every(p => p.inputsource.IsReplayFinished()); }
  APP_GetReplayData(out) { for (const p of this.playerList) out.push(p.inputsource.DumpString()); }
  APP_GetReplayBytes() { return this.playerList.map(p => p.inputsource.DumpFrames()); }
  DEBUG_SetPlayerPosVel(pos, vel) { for (const p of this.playerList) p.DEBUG_SetPosVel(pos, vel); }
  DEATHMATCH_RespawnPlayer(i) {
    if (this.playerList[i].IsDead()) this.playerList[i].DEBUG_Respawn(this.playerList[i].GetPos());
  }
  DEATHMATCH_GibPlayer(i) {
    if (!this.playerList[i].IsDead()) this.playerList[i].SIM_Kill(sim_globals.ENEMYTYPE_MINE, 0, 0, 0, 0);
  }
  DEBUG_ToggleRagdoll() {}
  DEBUG_ToggleExploded() {}
  DEBUG_GrabRagdoll() {}
  DEBUG_Draw_Tiles() {}
  DEBUG_Draw_Edges() {}
  DEBUG_Draw_objGrid() {}
  DEBUG_Draw_Grid() {}
  DEBUG_Draw_Entities() {}
}
