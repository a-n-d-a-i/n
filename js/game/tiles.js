/* Literal port of tiles/tiletypes.as, tiles/tiledefs.as, tiles/edgedefs.as */
import { Segment_Linear, Segment_Circular,
         setEdgeStateX, setEdgeStateY, copyEdgeStates,
         rotateEdgeStates90, rotateEdgeStates180, rotateEdgeStates270 } from "./collision.js";

export const tiletypes = {
  EMPTY: 0, FULL: 1, HALF_TOP: 2, HALF_RIGHT: 3, HALF_BOTTOM: 4, HALF_LEFT: 5,
  MED_PP: 6, MED_NP: 7, MED_NN: 8, MED_PN: 9,
  CONVEX_PP: 10, CONVEX_NP: 11, CONVEX_NN: 12, CONVEX_PN: 13,
  CONCAVE_PP: 14, CONCAVE_NP: 15, CONCAVE_NN: 16, CONCAVE_PN: 17,
  SMALL_22_PP: 18, SMALL_22_NP: 19, SMALL_22_NN: 20, SMALL_22_PN: 21,
  LARGE_22_PP: 22, LARGE_22_NP: 23, LARGE_22_NN: 24, LARGE_22_PN: 25,
  SMALL_67_PP: 26, SMALL_67_NP: 27, SMALL_67_NN: 28, SMALL_67_PN: 29,
  LARGE_67_PP: 30, LARGE_67_NP: 31, LARGE_67_NN: 32, LARGE_67_PN: 33,
  EDGE_TOP: 34, EDGE_RIGHT: 35, EDGE_BOTTOM: 36, EDGE_LEFT: 37,
  EDGE_CORNER_UL: 38, EDGE_CORNER_UR: 39, EDGE_CORNER_DL: 40, EDGE_CORNER_DR: 41,
  num_tile_types: 42, num_ingame_tile_types: 34,
};

const T = tiletypes;

class TileEdgeArchetype_Linear {
  constructor(x0, y0, x1, y1) { this.x0 = x0; this.y0 = y0; this.x1 = x1; this.y1 = y1; }
  GeneratePerpArchetype() {
    return new TileEdgeArchetype_Linear(-this.y0, this.x0, -this.y1, this.x1);
  }
  GenerateCollisionSegment(x, y, half) {
    return new Segment_Linear(x + this.x0 * half, y + this.y0 * half,
                              x + this.x1 * half, y + this.y1 * half);
  }
}
class TileEdgeArchetype_Circular {
  constructor(x0, y0, x1, y1, x2, y2) {
    this.x0 = x0; this.y0 = y0; this.x1 = x1; this.y1 = y1; this.x2 = x2; this.y2 = y2;
  }
  GeneratePerpArchetype() {
    return new TileEdgeArchetype_Circular(-this.y0, this.x0, -this.y1, this.x1, -this.y2, this.x2);
  }
  GenerateCollisionSegment(x, y, half) {
    return new Segment_Circular(x + this.x2 * half, y + this.y2 * half,
                                x + this.x0 * half, y + this.y0 * half,
                                x + this.x1 * half, y + this.y1 * half);
  }
}

const segdefs = new Array(T.num_tile_types).fill(null);
const boundaryflags = new Array(T.num_tile_types);
for (let i = 0; i < T.num_tile_types; i++) boundaryflags[i] = new Array(8).fill(false);
const boundarydefs = new Array(12);
const perpindex = [2, 3, 5, 4, 6, 7, 1, 0];

function genPerp(a) { return a.GeneratePerpArchetype(); }
segdefs[T.HALF_TOP] = new TileEdgeArchetype_Linear(-1, 0, 1, 0);
segdefs[T.HALF_RIGHT] = genPerp(segdefs[T.HALF_TOP]);
segdefs[T.HALF_BOTTOM] = genPerp(segdefs[T.HALF_RIGHT]);
segdefs[T.HALF_LEFT] = genPerp(segdefs[T.HALF_BOTTOM]);
segdefs[T.MED_PP] = new TileEdgeArchetype_Linear(-1, 1, 1, -1);
segdefs[T.MED_NP] = genPerp(segdefs[T.MED_PP]);
segdefs[T.MED_NN] = genPerp(segdefs[T.MED_NP]);
segdefs[T.MED_PN] = genPerp(segdefs[T.MED_NN]);
segdefs[T.CONVEX_PP] = new TileEdgeArchetype_Circular(-1, 1, 1, -1, -1, -1);
segdefs[T.CONVEX_NP] = genPerp(segdefs[T.CONVEX_PP]);
segdefs[T.CONVEX_NN] = genPerp(segdefs[T.CONVEX_NP]);
segdefs[T.CONVEX_PN] = genPerp(segdefs[T.CONVEX_NN]);
segdefs[T.CONCAVE_PP] = new TileEdgeArchetype_Circular(-1, 1, 1, -1, 1, 1);
segdefs[T.CONCAVE_NP] = genPerp(segdefs[T.CONCAVE_PP]);
segdefs[T.CONCAVE_NN] = genPerp(segdefs[T.CONCAVE_NP]);
segdefs[T.CONCAVE_PN] = genPerp(segdefs[T.CONCAVE_NN]);
segdefs[T.SMALL_22_PP] = new TileEdgeArchetype_Linear(-1, 0, 1, -1);
segdefs[T.SMALL_67_NP] = genPerp(segdefs[T.SMALL_22_PP]);
segdefs[T.SMALL_22_NN] = genPerp(segdefs[T.SMALL_67_NP]);
segdefs[T.SMALL_67_PN] = genPerp(segdefs[T.SMALL_22_NN]);
segdefs[T.SMALL_67_PP] = new TileEdgeArchetype_Linear(-1, 1, 0, -1);
segdefs[T.SMALL_22_NP] = genPerp(segdefs[T.SMALL_67_PP]);
segdefs[T.SMALL_67_NN] = genPerp(segdefs[T.SMALL_22_NP]);
segdefs[T.SMALL_22_PN] = genPerp(segdefs[T.SMALL_67_NN]);
segdefs[T.LARGE_22_PP] = new TileEdgeArchetype_Linear(-1, 1, 1, 0);
segdefs[T.LARGE_67_NP] = genPerp(segdefs[T.LARGE_22_PP]);
segdefs[T.LARGE_22_NN] = genPerp(segdefs[T.LARGE_67_NP]);
segdefs[T.LARGE_67_PN] = genPerp(segdefs[T.LARGE_22_NN]);
segdefs[T.LARGE_67_PP] = new TileEdgeArchetype_Linear(0, 1, 1, -1);
segdefs[T.LARGE_22_NP] = genPerp(segdefs[T.LARGE_67_PP]);
segdefs[T.LARGE_67_NN] = genPerp(segdefs[T.LARGE_22_NP]);
segdefs[T.LARGE_22_PN] = genPerp(segdefs[T.LARGE_67_NN]);

function setFlags(type, pairs) { for (const [i, v] of pairs) boundaryflags[type][i] = v; }
function setFlagsPerp(src, dst) {
  for (let i = 0; i < 8; i++) boundaryflags[dst][i] = boundaryflags[src][perpindex[i]];
}
function copyFlags(src, dst) { for (let i = 0; i < 8; i++) boundaryflags[dst][i] = boundaryflags[src][i]; }

setFlags(T.FULL, [[0, true], [1, true], [2, true], [3, true], [4, true], [5, true], [6, true], [7, true]]);
setFlags(T.EDGE_TOP, [[6, true], [7, true]]);
setFlagsPerp(T.EDGE_TOP, T.EDGE_RIGHT);
setFlagsPerp(T.EDGE_RIGHT, T.EDGE_BOTTOM);
setFlagsPerp(T.EDGE_BOTTOM, T.EDGE_LEFT);
setFlags(T.HALF_TOP, [[0, true], [4, true], [6, true], [7, true]]);
setFlagsPerp(T.HALF_TOP, T.HALF_RIGHT);
setFlagsPerp(T.HALF_RIGHT, T.HALF_BOTTOM);
setFlagsPerp(T.HALF_BOTTOM, T.HALF_LEFT);
setFlags(T.MED_PP, [[0, true], [1, true], [6, true], [7, true]]);
setFlagsPerp(T.MED_PP, T.MED_NP);
setFlagsPerp(T.MED_NP, T.MED_NN);
setFlagsPerp(T.MED_NN, T.MED_PN);
copyFlags(T.MED_PP, T.CONVEX_PP); copyFlags(T.MED_NP, T.CONVEX_NP);
copyFlags(T.MED_NN, T.CONVEX_NN); copyFlags(T.MED_PN, T.CONVEX_PN);
copyFlags(T.MED_PP, T.CONCAVE_PP); copyFlags(T.MED_NP, T.CONCAVE_NP);
copyFlags(T.MED_NN, T.CONCAVE_NN); copyFlags(T.MED_PN, T.CONCAVE_PN);
setFlags(T.SMALL_22_PP, [[0, true], [6, true], [7, true]]);
setFlagsPerp(T.SMALL_22_PP, T.SMALL_67_NP);
setFlagsPerp(T.SMALL_67_NP, T.SMALL_22_NN);
setFlagsPerp(T.SMALL_22_NN, T.SMALL_67_PN);
setFlags(T.SMALL_67_PP, [[0, true], [1, true], [6, true]]);
setFlagsPerp(T.SMALL_67_PP, T.SMALL_22_NP);
setFlagsPerp(T.SMALL_22_NP, T.SMALL_67_NN);
setFlagsPerp(T.SMALL_67_NN, T.SMALL_22_PN);
setFlags(T.LARGE_22_PP, [[0, true], [1, true], [4, true], [6, true], [7, true]]);
setFlagsPerp(T.LARGE_22_PP, T.LARGE_67_NP);
setFlagsPerp(T.LARGE_67_NP, T.LARGE_22_NN);
setFlagsPerp(T.LARGE_22_NN, T.LARGE_67_PN);
setFlags(T.LARGE_67_PP, [[0, true], [1, true], [2, true], [6, true], [7, true]]);
setFlagsPerp(T.LARGE_67_PP, T.LARGE_22_NP);
setFlagsPerp(T.LARGE_22_NP, T.LARGE_67_NN);
setFlagsPerp(T.LARGE_67_NN, T.LARGE_22_PN);

boundarydefs[0] = new TileEdgeArchetype_Linear(-1, -1, -1, 0);
boundarydefs[1] = new TileEdgeArchetype_Linear(-1, 0, -1, 1);
boundarydefs[2] = new TileEdgeArchetype_Linear(-1, -1, -1, 1);
boundarydefs[9] = genPerp(boundarydefs[1]);
boundarydefs[10] = genPerp(boundarydefs[0]);
boundarydefs[11] = genPerp(boundarydefs[2]);
boundarydefs[7] = genPerp(boundarydefs[10]);
boundarydefs[6] = genPerp(boundarydefs[9]);
boundarydefs[8] = genPerp(boundarydefs[11]);
boundarydefs[4] = genPerp(boundarydefs[6]);
boundarydefs[3] = genPerp(boundarydefs[7]);
boundarydefs[5] = genPerp(boundarydefs[8]);

export const tiledefs = {
  GenerateTileSegments_Filtered(type, neighbours, x, y, half) {
    const out = [];
    for (let i = 0; i < 4; i++) {
      const a = boundaryflags[type][i * 2] && !boundaryflags[neighbours[i]][(i * 2 + 4) % 8];
      const b = boundaryflags[type][i * 2 + 1] && !boundaryflags[neighbours[i]][(i * 2 + 1 + 4) % 8];
      if (a) out.push(boundarydefs[i * 3 + 2].GenerateCollisionSegment(x, y, half));
      else if (b) out.push(boundarydefs[i * 3 + 1].GenerateCollisionSegment(x, y, half));
      if (a && !b) out[out.length - 1] = boundarydefs[i * 3].GenerateCollisionSegment(x, y, half);
    }
    const sd = segdefs[type];
    if (sd) out.push(sd.GenerateCollisionSegment(x, y, half));
    return out;
  },
};

// ---------------------------------------------------------------- edgedefs
function initEdges() {
  const X = (t, a, b, c, d, e, f) => setEdgeStateX(t, a, b, c, d, e, f);
  const Y = (t, a, b, c, d, e, f) => setEdgeStateY(t, a, b, c, d, e, f);
  X(T.FULL, 2, 0, 2, 2, 0, 2); Y(T.FULL, 2, 0, 2, 2, 0, 2);
  Y(T.EDGE_BOTTOM, 0, 0, 2, 0, 0, 2);
  rotateEdgeStates90(T.EDGE_BOTTOM, T.EDGE_LEFT);
  rotateEdgeStates180(T.EDGE_BOTTOM, T.EDGE_TOP);
  rotateEdgeStates270(T.EDGE_BOTTOM, T.EDGE_RIGHT);
  X(T.HALF_BOTTOM, 0, 0, 0, 2, 0, 2); Y(T.HALF_BOTTOM, 0, 2, 2, 0, 2, 2);
  rotateEdgeStates90(T.HALF_BOTTOM, T.HALF_LEFT);
  rotateEdgeStates180(T.HALF_BOTTOM, T.HALF_TOP);
  rotateEdgeStates270(T.HALF_BOTTOM, T.HALF_RIGHT);
  X(T.CONCAVE_PP, 2, 0, 1, 2, 1, 0); Y(T.CONCAVE_PP, 2, 0, 1, 2, 1, 0);
  rotateEdgeStates90(T.CONCAVE_PP, T.CONCAVE_NP);
  rotateEdgeStates180(T.CONCAVE_PP, T.CONCAVE_NN);
  rotateEdgeStates270(T.CONCAVE_PP, T.CONCAVE_PN);
  X(T.CONVEX_PP, 2, 0, 1, 2, 0, 1); Y(T.CONVEX_PP, 2, 0, 1, 2, 0, 1);
  rotateEdgeStates90(T.CONVEX_PP, T.CONVEX_NP);
  rotateEdgeStates180(T.CONVEX_PP, T.CONVEX_NN);
  rotateEdgeStates270(T.CONVEX_PP, T.CONVEX_PN);
  copyEdgeStates(T.CONCAVE_PP, T.MED_PP); copyEdgeStates(T.CONCAVE_NP, T.MED_NP);
  copyEdgeStates(T.CONCAVE_NN, T.MED_NN); copyEdgeStates(T.CONCAVE_PN, T.MED_PN);
  X(T.SMALL_22_PP, 2, 0, 1, 0, 0, 0); Y(T.SMALL_22_PP, 2, 1, 0, 2, 1, 0);
  rotateEdgeStates90(T.SMALL_22_PP, T.SMALL_67_NP);
  rotateEdgeStates180(T.SMALL_22_PP, T.SMALL_22_NN);
  rotateEdgeStates270(T.SMALL_22_PP, T.SMALL_67_PN);
  X(T.SMALL_67_PP, 2, 1, 0, 2, 1, 0); Y(T.SMALL_67_PP, 2, 0, 1, 0, 0, 0);
  rotateEdgeStates90(T.SMALL_67_PP, T.SMALL_22_NP);
  rotateEdgeStates180(T.SMALL_67_PP, T.SMALL_67_NN);
  rotateEdgeStates270(T.SMALL_67_PP, T.SMALL_22_PN);
  X(T.LARGE_22_PP, 2, 0, 2, 2, 0, 1); Y(T.LARGE_22_PP, 2, 0, 1, 2, 0, 1);
  rotateEdgeStates90(T.LARGE_22_PP, T.LARGE_67_NP);
  rotateEdgeStates180(T.LARGE_22_PP, T.LARGE_22_NN);
  rotateEdgeStates270(T.LARGE_22_PP, T.LARGE_67_PN);
  X(T.LARGE_67_PP, 2, 0, 1, 2, 0, 1); Y(T.LARGE_67_PP, 2, 0, 2, 2, 0, 1);
  rotateEdgeStates90(T.LARGE_67_PP, T.LARGE_22_NP);
  rotateEdgeStates180(T.LARGE_67_PP, T.LARGE_67_NN);
  rotateEdgeStates270(T.LARGE_67_PP, T.LARGE_22_PN);
}
initEdges();
