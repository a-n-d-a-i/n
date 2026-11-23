/* Custom WebGL2 renderer for the Flash display list.  No third-party libs. */
import { STAGE_W, STAGE_H, MovieClip, TextField, Shape } from "./flash.js";

const PAD = 2;

const VS = `#version 300 es
precision highp float;
layout(location=0) in vec2 a_pos;
layout(location=1) in vec2 a_uv;
layout(location=2) in vec4 a_mult;
layout(location=3) in vec3 a_add;
uniform mat4 u_proj;
out vec2 v_uv;
out vec4 v_mult;
out vec3 v_add;
void main() {
  v_uv = a_uv;
  v_mult = a_mult;
  v_add = a_add;
  gl_Position = u_proj * vec4(a_pos, 0.0, 1.0);
}`;
const FS = `#version 300 es
precision highp float;
in vec2 v_uv;
in vec4 v_mult;
in vec3 v_add;
uniform sampler2D u_tex;
out vec4 outColor;
void main() {
  vec4 t = texture(u_tex, v_uv);
  vec3 rgb = t.rgb * v_mult.rgb + v_add;
  float a = t.a * v_mult.a;
  outColor = vec4(rgb * a, a);
}`;

function mulMatrix(m, p) {
  return {
    a: m.a * p.a + m.b * p.c, b: m.a * p.b + m.b * p.d,
    c: m.c * p.a + m.d * p.c, d: m.c * p.b + m.d * p.d,
    tx: m.tx * p.a + m.ty * p.c + p.tx,
    ty: m.tx * p.b + m.ty * p.d + p.ty,
  };
}
const IDENTITY = { a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0 };

export class Renderer {
  constructor(canvas, lib) {
    this.canvas = canvas;
    this.lib = lib;
    this.dpr = Math.min(window.devicePixelRatio || 1, 2.5);
    this.gl = canvas.getContext("webgl2", { alpha: false, antialias: false, premultipliedAlpha: true });
    if (!this.gl) throw new Error("WebGL2 is required");
    this._initGL();
    this._initTextures();
    this._bindTextures();
    this._resizeHandler = () => this.resize();
    window.addEventListener("resize", this._resizeHandler);
    this.resize();
  }

  _initGL() {
    const gl = this.gl;
    const sh = (type, src) => {
      const s = gl.createShader(type);
      gl.shaderSource(s, src); gl.compileShader(s);
      if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) throw new Error(gl.getShaderInfoLog(s));
      return s;
    };
    const p = gl.createProgram();
    gl.attachShader(p, sh(gl.VERTEX_SHADER, VS));
    gl.attachShader(p, sh(gl.FRAGMENT_SHADER, FS));
    gl.linkProgram(p);
    if (!gl.getProgramParameter(p, gl.LINK_STATUS)) throw new Error(gl.getProgramInfoLog(p));
    this.program = p;
    this.uProj = gl.getUniformLocation(p, "u_proj");
    this.uTex = gl.getUniformLocation(p, "u_tex");
    this.vbo = gl.createBuffer();
    this.vao = gl.createVertexArray();
    gl.bindVertexArray(this.vao);
    gl.bindBuffer(gl.ARRAY_BUFFER, this.vbo);
    const stride = 11 * 4;
    gl.enableVertexAttribArray(0); gl.vertexAttribPointer(0, 2, gl.FLOAT, false, stride, 0);
    gl.enableVertexAttribArray(1); gl.vertexAttribPointer(1, 2, gl.FLOAT, false, stride, 8);
    gl.enableVertexAttribArray(2); gl.vertexAttribPointer(2, 4, gl.FLOAT, false, stride, 16);
    gl.enableVertexAttribArray(3); gl.vertexAttribPointer(3, 3, gl.FLOAT, false, stride, 32);
    gl.bindVertexArray(null);
    this.verts = new Float32Array(11 * 6 * 4096);
    this.nverts = 0;
    this.curTex = null;
    this.proj = new Float32Array(16);
  }

  _initTextures() {
    const gl = this.gl;
    this.atlasTex = [];
    for (const img of this.lib.textures) {
      const t = gl.createTexture();
      gl.bindTexture(gl.TEXTURE_2D, t);
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
      this.atlasTex.push(t);
    }
    // 1x1 white for solid geometry
    const wt = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, wt);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, new Uint8Array([255, 255, 255, 255]));
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    this.whiteTex = wt;
  }

  _bindTextures() {
    const gl = this.gl;
    gl.useProgram(this.program);
    gl.uniform1i(this.uTex, 0);
  }

  resize() {
    const c = this.canvas;
    const cssW = c.clientWidth || window.innerWidth;
    const cssH = c.clientHeight || window.innerHeight;
    const w = Math.max(1, Math.floor(cssW * this.dpr));
    const h = Math.max(1, Math.floor(cssH * this.dpr));
    if (c.width !== w || c.height !== h) { c.width = w; c.height = h; }
    // letterbox
    const scale = Math.min(w / STAGE_W, h / STAGE_H);
    this.viewW = STAGE_W * scale;
    this.viewH = STAGE_H * scale;
    this.viewX = (w - this.viewW) / 2;
    this.viewY = (h - this.viewH) / 2;
    this.scale = scale;
    // ortho projection mapping logical stage coords to clip space
    const sx = 2 / STAGE_W, sy = -2 / STAGE_H;
    this.proj.fill(0);
    this.proj[0] = sx; this.proj[5] = sy; this.proj[10] = 1; this.proj[15] = 1;
    this.proj[12] = -1; this.proj[13] = 1;
  }

  begin() {
    const gl = this.gl;
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    gl.viewport(this.viewX, this.viewY, this.viewW, this.viewH);
    gl.disable(gl.SCISSOR_TEST);
    gl.clearColor(0xca / 255, 0xca / 255, 0xd0 / 255, 1);
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.enable(gl.SCISSOR_TEST);
    gl.scissor(this.viewX, this.viewY, this.viewW, this.viewH);
    gl.enable(gl.BLEND);
    gl.blendFuncSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE_MINUS_SRC_ALPHA);
    gl.useProgram(this.program);
    gl.uniformMatrix4fv(this.uProj, false, this.proj);
    gl.activeTexture(gl.TEXTURE0);
    this.nverts = 0;
    this.curTex = null;
  }

  end() { this.flush(); }

  flush() {
    if (!this.nverts) return;
    const gl = this.gl;
    gl.bindVertexArray(this.vao);
    gl.bindBuffer(gl.ARRAY_BUFFER, this.vbo);
    gl.bufferData(gl.ARRAY_BUFFER, this.verts.subarray(0, this.nverts * 11), gl.STREAM_DRAW);
    if (this.curTex !== null) gl.bindTexture(gl.TEXTURE_2D, this.curTex);
    gl.drawArrays(gl.TRIANGLES, 0, this.nverts);
    gl.bindVertexArray(null);
    this.nverts = 0;
  }

  setTexture(t) {
    if (t === this.curTex) return;
    this.flush();
    this.curTex = t;
    const gl = this.gl;
    gl.bindTexture(gl.TEXTURE_2D, t);
  }

  // geometry in logical stage coordinates, uv in textel coords/texSize
  _quad(tex, x, y, w, h, u0, v0, u1, v1, mult, add) {
    this.setTexture(tex);
    if ((this.nverts + 6) * 11 > this.verts.length) this.flush();
    const v = this.verts;
    let o = this.nverts * 11;
    const [mr, mg, mb, ma] = mult;
    const [ar, ag, ab] = add;
    const push = (px, py, u, vv) => {
      v[o++] = px; v[o++] = py; v[o++] = u; v[o++] = vv;
      v[o++] = mr; v[o++] = mg; v[o++] = mb; v[o++] = ma;
      v[o++] = ar; v[o++] = ag; v[o++] = ab;
    };
    push(x, y, u0, v0); push(x + w, y, u1, v0); push(x, y + h, u0, v1);
    push(x + w, y, u1, v0); push(x + w, y + h, u1, v1); push(x, y + h, u0, v1);
    this.nverts += 6;
  }

  _transformedQuad(tex, m, x, y, w, h, u0, v0, u1, v1, mult, add) {
    this.setTexture(tex);
    if ((this.nverts + 6) * 11 > this.verts.length) this.flush();
    const v = this.verts;
    let o = this.nverts * 11;
    const [mr, mg, mb, ma] = mult;
    const [ar, ag, ab] = add;
    const push = (px, py, u, vv) => {
      const X = m.a * px + m.c * py + m.tx;
      const Y = m.b * px + m.d * py + m.ty;
      v[o++] = X; v[o++] = Y; v[o++] = u; v[o++] = vv;
      v[o++] = mr; v[o++] = mg; v[o++] = mb; v[o++] = ma;
      v[o++] = ar; v[o++] = ag; v[o++] = ab;
    };
    push(x, y, u0, v0); push(x + w, y, u1, v0); push(x, y + h, u0, v1);
    push(x + w, y, u1, v0); push(x + w, y + h, u1, v1); push(x, y + h, u0, v1);
    this.nverts += 6;
  }

  _textTexture(tf) {
    if (tf._textDirty || !tf._texture) {
      tf._rasterize();
      const gl = this.gl;
      if (!tf._texture) tf._texture = gl.createTexture();
      gl.bindTexture(gl.TEXTURE_2D, tf._texture);
      gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, false);
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, tf._canvas);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    }
    return tf._texture;
  }

  render(stage) {
    this.begin();
    const ct = { m: [1, 1, 1, 1], a: [0, 0, 0] };
    for (const child of stage.children) this._draw(child, IDENTITY, ct, 1);
    this.end();
  }

  _draw(obj, parentM, ct, parentAlpha) {
    if (obj.visible === false || obj.alpha === 0) return;
    const lm = obj._localMatrix ? obj._localMatrix() : IDENTITY;
    const m = mulMatrix(lm, parentM);
    const my = obj.transform && obj.transform.colorTransform;
    let mult = ct.m.slice(), add = ct.a.slice();
    if (my) {
      mult[0] *= my.redMultiplier; mult[1] *= my.greenMultiplier;
      mult[2] *= my.blueMultiplier; mult[3] *= my.alphaMultiplier;
      add[0] = add[0] * my.redMultiplier + my.redOffset / 255;
      add[1] = add[1] * my.greenMultiplier + my.greenOffset / 255;
      add[2] = add[2] * my.blueMultiplier + my.blueOffset / 255;
    }
    const alpha = parentAlpha * (obj.alpha == null ? 1 : obj.alpha);
    mult[3] *= obj.alpha == null ? 1 : obj.alpha;

    if (obj._customDraw) {
      obj._customDraw(this, m, mult, add);
      if (!obj.children || obj.children.length === 0) return;
    }
    if (obj instanceof MovieClip) {
      const fr = obj.graphicFrame;
      if (fr && fr.p >= 0 && fr.p < this.atlasTex.length) {
        const tex = this.atlasTex[fr.p];
        const img = this.lib.textures[fr.p];
        const iw = img.width, ih = img.height;
        const u0 = (fr.sx + PAD) / iw, v0 = (fr.sy + PAD) / ih;
        const u1 = (fr.sx + PAD + fr.w) / iw, v1 = (fr.sy + PAD + fr.h) / ih;
        this._transformedQuad(tex, m, fr.qx, fr.qy, fr.w, fr.h, u0, v0, u1, v1, mult, add);
      }
    } else if (obj instanceof TextField) {
      const tex = this._textTexture(obj);
      if (tex) {
        const w = obj._canvas.width, h = obj._canvas.height;
        this._transformedQuad(tex, m, 0, 0, w, h, 0, 0, 1, 1, [1, 1, 1, mult[3]], [0, 0, 0]);
        return;
      }
    } else if (obj._imageMeta) {
      this.drawFrameQuad(obj._imageMeta, m, mult, add);
      return;
    } else if (obj.graphics) {
      this._drawGraphics(obj.graphics, m, mult);
    }
    if (obj.children) {
      for (const child of obj.children) this._draw(child, m, { m: mult, a: add }, alpha);
    }
  }

  drawFrameQuad(fr, m, mult, add, clipW = null, offX = 0) {
    if (!fr || fr.p < 0 || fr.p >= this.atlasTex.length) return;
    const tex = this.atlasTex[fr.p];
    const img = this.lib.textures[fr.p];
    const iw = img.width, ih = img.height;
    const w = clipW == null ? fr.w : Math.min(fr.w, clipW);
    if (w <= 0) return;
    const u0 = (fr.sx + PAD) / iw, v0 = (fr.sy + PAD) / ih;
    const u1 = (fr.sx + PAD + w) / iw, v1 = (fr.sy + PAD + fr.h) / ih;
    this._transformedQuad(tex, m, fr.qx + offX, fr.qy, w, fr.h, u0, v0, u1, v1, mult, add);
  }

  drawSolidQuad(m, x, y, w, h, r, g, b, a) {
    this._quadWhite(m, { x, y }, { x: x + w, y }, { x: x + w, y: y + h }, { x, y: y + h }, [r, g, b, a]);
  }

  _drawGraphics(g, m, mult) {
    const gl = this.gl;
    // solid quads use the white texture and the style colour as tint
    const lineQuad = (x0, y0, x1, y1, width, color, alpha) => {
      const dx = x1 - x0, dy = y1 - y0;
      const len = Math.hypot(dx, dy);
      if (len < 1e-9) return;
      const nx = -dy / len * Math.max(width, 1) / 2, ny = dx / len * Math.max(width, 1) / 2;
      const col = [(color >> 16 & 255) / 255, (color >> 8 & 255) / 255, (color & 255) / 255, alpha * mult[3]];
      const a0 = { x: x0 + nx, y: y0 + ny }, a1 = { x: x0 - nx, y: y0 - ny };
      const b0 = { x: x1 + nx, y: y1 + ny }, b1 = { x: x1 - nx, y: y1 - ny };
      this._quadWhite(m, a0, b0, b1, a1, col);
    };
    const fillTri = (a, b, c, color, alpha) => {
      const col = [(color >> 16 & 255) / 255, (color >> 8 & 255) / 255, (color & 255) / 255, alpha * mult[3]];
      this._triWhite(m, a, b, c, col);
    };
    let cx = 0, cy = 0;
    for (const c of g.commands) {
      if (c.op === "m") { cx = c.x; cy = c.y; }
      else if (c.op === "l") {
        lineQuad(cx, cy, c.x, c.y, c.w, c.c, c.a);
        cx = c.x; cy = c.y;
      } else if (c.op === "q") {
        lineQuad(cx, cy, c.x, c.y, g.lineWidth, g.lineColor, g.lineAlpha);
        cx = c.x; cy = c.y;
      } else if (c.op === "rect") {
        const x0 = c.x, y0 = c.y, x1 = c.x + c.w, y1 = c.y + c.h;
        fillTri({ x: x0, y: y0 }, { x: x1, y: y0 }, { x: x1, y: y1 }, c.c, c.a);
        fillTri({ x: x0, y: y0 }, { x: x1, y: y1 }, { x: x0, y: y1 }, c.c, c.a);
      } else if (c.op === "rline") {
        const x0 = c.x, y0 = c.y, x1 = c.x + c.w, y1 = c.y + c.h;
        if (c.lw || c.a) {
          lineQuad(x0, y0, x1, y0, c.lw, c.c, c.a); lineQuad(x1, y0, x1, y1, c.lw, c.c, c.a);
          lineQuad(x1, y1, x0, y1, c.lw, c.c, c.a); lineQuad(x0, y1, x0, y0, c.lw, c.c, c.a);
        }
      } else if (c.op === "circle") {
        const n = 24;
        let prev = null, first = null;
        for (let i = 0; i <= n; i++) {
          const a = i / n * Math.PI * 2;
          const pt = { x: c.x + Math.cos(a) * c.r, y: c.y + Math.sin(a) * c.r };
          if (first == null) first = pt;
          if (prev) fillTri({ x: c.x, y: c.y }, prev, pt, c.c, c.a);
          prev = pt;
        }
      } else if (c.op === "cline") {
        if (c.lw || c.a) {
          const n = 24; let prev = null, first = null;
          for (let i = 0; i <= n; i++) {
            const a = i / n * Math.PI * 2;
            const pt = { x: c.x + Math.cos(a) * c.r, y: c.y + Math.sin(a) * c.r };
            if (first == null) first = pt;
            if (prev) lineQuad(prev.x, prev.y, pt.x, pt.y, c.lw, c.c, c.a);
            prev = pt;
          }
        }
      }
    }
  }

  _triWhite(m, a, b, c, col) {
    this.setTexture(this.whiteTex);
    if ((this.nverts + 3) * 11 > this.verts.length) this.flush();
    const v = this.verts;
    let o = this.nverts * 11;
    const push = (p) => {
      const X = m.a * p.x + m.c * p.y + m.tx;
      const Y = m.b * p.x + m.d * p.y + m.ty;
      v[o++] = X; v[o++] = Y; v[o++] = 0.5; v[o++] = 0.5;
      v[o++] = col[0]; v[o++] = col[1]; v[o++] = col[2]; v[o++] = col[3];
      v[o++] = 0; v[o++] = 0; v[o++] = 0;
    };
    push(a); push(b); push(c);
    this.nverts += 3;
  }

  _quadWhite(m, a, b, c, d, col) {
    this.setTexture(this.whiteTex);
    if ((this.nverts + 6) * 11 > this.verts.length) this.flush();
    const v = this.verts;
    let o = this.nverts * 11;
    const push = (p) => {
      const X = m.a * p.x + m.c * p.y + m.tx;
      const Y = m.b * p.x + m.d * p.y + m.ty;
      v[o++] = X; v[o++] = Y; v[o++] = 0.5; v[o++] = 0.5;
      v[o++] = col[0]; v[o++] = col[1]; v[o++] = col[2]; v[o++] = col[3];
      v[o++] = 0; v[o++] = 0; v[o++] = 0;
    };
    push(a); push(b); push(c);
    push(a); push(c); push(d);
    this.nverts += 6;
  }
}
