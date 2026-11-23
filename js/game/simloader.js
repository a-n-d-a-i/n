/* Literal port of simulation/sim_loader.as (editor-state path). */
import { vec2, mathutils } from "./math.js";
import { Grid_Segment, Grid_Edges, Grid_Entity } from "./collision.js";
import { Segment_Linear_DoubleSided } from "./collision.js";
import { edat } from "./editorstate.js";
import { tiletypes, tiledefs } from "./tiles.js";
import { Ninja } from "./ninja.js";
import { Simulator } from "./simulator.js";
import {
  Entity_BounceBlock, Entity_Door_Locked, Entity_Door_Regular, Entity_Door_Trap,
  Entity_Drone_Chaingun, Entity_Drone_Chaser, Entity_Drone_Laser, Entity_Drone_Zap,
  Entity_ExitDoor, Entity_ExitSwitch, Entity_FloorGuard, Entity_Gold,
  Entity_Launchpad, Entity_Mine, Entity_OnewayPlatform, Entity_Rocket,
  Entity_Thwomp, Entity_Turret, entity_helpers,
} from "./entities.js";
import { InputSource_Recorder, InputSource_Playback } from "./input.js";

function initTileIDGridWithBoundaryEdges(grid, cols, rows) {
  for (let i = 0; i < cols * rows; i++) grid[i] = tiletypes.EMPTY;
  for (let c = 1; c < cols - 1; c++) {
    grid[c] = tiletypes.EDGE_BOTTOM;
    grid[c + (rows - 1) * cols] = tiletypes.EDGE_TOP;
  }
  for (let r = 1; r < rows - 1; r++) {
    grid[r * cols] = tiletypes.EDGE_RIGHT;
    grid[cols - 1 + r * cols] = tiletypes.EDGE_LEFT;
  }
  grid[0] = tiletypes.EDGE_CORNER_UL;
  grid[cols - 1] = tiletypes.EDGE_CORNER_UR;
  grid[(rows - 1) * cols] = tiletypes.EDGE_CORNER_DL;
  grid[rows * cols - 1] = tiletypes.EDGE_CORNER_DR;
}

function buildTileSegs(segGrid, half, col, row, type, neighbours) {
  const segs = tiledefs.GenerateTileSegments_Filtered(type, neighbours,
    col * edat.cell_size + half, row * edat.cell_size + half, half);
  for (const s of segs) segGrid.AddSegToCell(col, row, s);
}

export function LoadLevel_EditorState(actionKeys, colors, input, replay, numPlayers, state) {
  mathutils.GenerateNewRandomSeed();
  const cols = Simulator.GRID_NUM_COLS, rows = Simulator.GRID_NUM_ROWS;
  const cell = Simulator.GRID_CELL_SIZE, half = Simulator.GRID_CELL_HALFWIDTH;
  const tileIDs = new Array(cols * rows).fill(0);
  const segGrid = new Grid_Segment(cols, rows, cell);
  const edgeGrid = new Grid_Edges(cols * 2, rows * 2, cell * 0.5);
  const objGrid = new Grid_Entity(cols, rows, cell);
  const objList = [];
  const playerPositions = [];

  segGrid.Clear(); edgeGrid.Clear();
  initTileIDGridWithBoundaryEdges(tileIDs, cols, rows);
  for (let i = 0; i < state.tileIDs.length; i++) {
    const c = 1 + (i % edat.num_cols);
    const r = 1 + Math.floor(i / edat.num_cols);
    tileIDs[c + r * cols] = state.tileIDs[i];
  }
  const nb = new Array(4);
  for (let idx = 0; idx < tileIDs.length; idx++) {
    const c = idx % cols, r = Math.floor(idx / cols);
    nb[0] = c === 0 ? tiletypes.EMPTY : tileIDs[idx - 1];
    nb[2] = c === cols - 1 ? tiletypes.EMPTY : tileIDs[idx + 1];
    nb[3] = r === 0 ? tiletypes.EMPTY : tileIDs[idx - cols];
    nb[1] = r === rows - 1 ? tiletypes.EMPTY : tileIDs[idx + cols];
    buildTileSegs(segGrid, half, c, r, tileIDs[idx], nb);
    edgeGrid.GAME_LoadTileEdges(c, r, tileIDs[idx]);
  }

  loadEntities(state.entities, segGrid, edgeGrid, objGrid, objList, playerPositions);

  if (playerPositions.length === 0) playerPositions.push(new vec2(32, 32));
  while (playerPositions.length < numPlayers) playerPositions.push(playerPositions[0].Clone());
  while (playerPositions.length > numPlayers) playerPositions.pop();
  if (numPlayers === 2) {
    playerPositions[0].x -= 4;
    playerPositions[1].x += 4;
  }
  const ninjas = [];
  for (let i = 0; i < playerPositions.length; i++) {
    let src;
    if (replay === null) {
      src = new InputSource_Recorder(input,
        actionKeys[(i * 3) % actionKeys.length],
        actionKeys[(i * 3 + 1) % actionKeys.length],
        actionKeys[(i * 3 + 2) % actionKeys.length]);
    } else {
      src = new InputSource_Playback(replay);
    }
    ninjas.push(new Ninja(i, src, playerPositions[i].x, playerPositions[i].y, colors[i]));
  }
  return new Simulator(tileIDs, segGrid, edgeGrid, objGrid, objList, ninjas);
}

function registerEntity(list, e) {
  e.GAME_SetUID(list.length);
  list.push(e);
}

function loadEntities(entities, segGrid, edgeGrid, objGrid, objList, players) {
  objGrid.Clear();
  objList.length = 0;
  players.length = 0;
  for (let i = 0; i < entities.length; i++) {
    const e = entities[i];
    const type = e[edat.EPROP_TYPE];
    const x = e[edat.EPROP_X] * edat.quantize_step_size;
    const y = e[edat.EPROP_Y] * edat.quantize_step_size;
    let dir = 0, move = 0;
    if (e.length > 3) {
      dir = e[edat.EPROP_DIR];
      if (e.length > 4) move = e[edat.EPROP_MOVE];
    }
    if (type === edat.ETYPE_BOUNCEBLOCK) {
      registerEntity(objList, new Entity_BounceBlock(objGrid, x, y));
    } else if (type === edat.ETYPE_CHAINGUN) {
      registerEntity(objList, new Entity_Drone_Chaingun(objGrid, x, y, Math.floor(dir / 2), Math.min(3, move)));
    } else if (type === edat.ETYPE_CHASER) {
      registerEntity(objList, new Entity_Drone_Chaser(objGrid, x, y, Math.floor(dir / 2), Math.min(3, move)));
    } else if (type === edat.ETYPE_DOOR_LOCKED || type === edat.ETYPE_DOOR_REGULAR || type === edat.ETYPE_DOOR_TRAP) {
      const dvec = edat.MAP_DIR_TO_VEC(dir);
      const gc = Math.floor((x - dvec.x * 12) / 24);
      const gr = Math.floor((y - dvec.y * 12) / 24);
      const segIndex = segGrid.DOOR_GetCellIndexFromGridspacePosition(gc, gr);
      const horizontal = dir === 0;
      const edgeIdx = horizontal
        ? [edgeGrid.DOOR_GetCellIndexFromGridspacePosition(gc * 2 + 1, gr * 2),
           edgeGrid.DOOR_GetCellIndexFromGridspacePosition(gc * 2 + 1, gr * 2 + 1)]
        : [edgeGrid.DOOR_GetCellIndexFromGridspacePosition(gc * 2, gr * 2 + 1),
           edgeGrid.DOOR_GetCellIndexFromGridspacePosition(gc * 2 + 1, gr * 2 + 1)];
      const center = new vec2(x, y);
      const perp = dvec.Perp(); perp.Scale(12);
      const p0 = center.Plus(perp), p1 = center.Minus(perp);
      const seg = new Segment_Linear_DoubleSided(p0.x, p0.y, p1.x, p1.y);
      if (type === edat.ETYPE_DOOR_REGULAR) {
        registerEntity(objList, new Entity_Door_Regular(objGrid, segGrid, segIndex, seg, edgeGrid,
          edgeIdx, horizontal, x, y));
      } else {
        const sw = entities[i + 1];
        const sx = sw[edat.EPROP_X] * edat.quantize_step_size;
        const sy = sw[edat.EPROP_Y] * edat.quantize_step_size;
        if (type === edat.ETYPE_DOOR_LOCKED) {
          registerEntity(objList, new Entity_Door_Locked(objGrid, segGrid, segIndex, seg, edgeGrid,
            edgeIdx, horizontal, sx, sy));
        } else {
          registerEntity(objList, new Entity_Door_Trap(objGrid, segGrid, segIndex, seg, edgeGrid,
            edgeIdx, horizontal, sx, sy));
        }
      }
    } else if (type === edat.ETYPE_EXIT_DOOR) {
      const door = new Entity_ExitDoor(x, y);
      registerEntity(objList, door);
      const sw = entities[i + 1];
      const sx = sw[edat.EPROP_X] * edat.quantize_step_size;
      const sy = sw[edat.EPROP_Y] * edat.quantize_step_size;
      registerEntity(objList, new Entity_ExitSwitch(objGrid, sx, sy, door));
    } else if (type === edat.ETYPE_EXIT_SWITCH) {
      continue;
    } else if (type === edat.ETYPE_FLOORGUARD) {
      registerEntity(objList, new Entity_FloorGuard(objGrid, x, y));
    } else if (type === edat.ETYPE_GOLD) {
      registerEntity(objList, new Entity_Gold(objGrid, x, y));
    } else if (type === edat.ETYPE_LASER) {
      registerEntity(objList, new Entity_Drone_Laser(objGrid, x, y, Math.floor(dir / 2), Math.min(3, move)));
    } else if (type === edat.ETYPE_LAUNCHPAD) {
      const d = edat.MAP_DIR_TO_VEC(dir);
      registerEntity(objList, new Entity_Launchpad(objGrid, x, y, d.x, d.y));
    } else if (type === edat.ETYPE_MINE) {
      registerEntity(objList, new Entity_Mine(objGrid, x, y));
    } else if (type === edat.ETYPE_ONEWAY) {
      const d = edat.MAP_DIR_TO_VEC(dir);
      registerEntity(objList, new Entity_OnewayPlatform(objGrid, x, y, d.x, d.y));
    } else if (type === edat.ETYPE_PLAYER) {
      players.push(new vec2(x, y));
    } else if (type === edat.ETYPE_ROCKET) {
      registerEntity(objList, new Entity_Rocket(objGrid, x, y));
    } else if (type === edat.ETYPE_SWITCH_LOCKED) {
      continue;
    } else if (type === edat.ETYPE_SWITCH_TRAP) {
      continue;
    } else if (type === edat.ETYPE_THWOMP) {
      const d = edat.MAP_DIR_TO_VEC(dir);
      let fd = 0, horizontal = false;
      if (d.y === 0) { fd = d.x; horizontal = true; }
      else fd = d.y;
      registerEntity(objList, new Entity_Thwomp(objGrid, x, y, fd, horizontal));
    } else if (type === edat.ETYPE_TURRET) {
      registerEntity(objList, new Entity_Turret(objGrid, x, y));
    } else if (type === edat.ETYPE_ZAP) {
      registerEntity(objList, new Entity_Drone_Zap(objGrid, x, y, Math.floor(dir / 2), Math.min(3, move)));
    }
  }
}
