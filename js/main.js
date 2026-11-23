import { AssetLibrary } from "./assets.js";
import { Renderer } from "./renderer.js";
import { Stage, MovieClip, Sprite, disposeDisplayTree } from "./flash.js";
import { GameApp } from "./app.js";
import { PreloaderScreen } from "./ui.js";

const loading = document.getElementById("loading");
const bar = document.querySelector("#bar > div");
const err = document.getElementById("err");

async function boot() {
  try {
    globalThis.trace = (...a) => console.warn(...a);
    const lib = new AssetLibrary();
    await lib.load(p => { bar.style.width = (p * 100).toFixed(0) + "%"; });
    const canvas = document.getElementById("game");
    const stage = new Stage();
    const renderer = new Renderer(canvas, lib);
    globalThis.stage = stage;
    globalThis.renderer = renderer;
    globalThis.lib = lib;

    const gameLayer = new Sprite();
    const uiLayer = new Sprite();
    const menuLayer = new Sprite();
    menuLayer.x = 4;
    stage.addChild(gameLayer);
    stage.addChild(uiLayer);
    stage.addChild(menuLayer);

    const app = new GameApp(stage, lib, gameLayer, uiLayer, menuLayer);
    globalThis.app = app;
    app.installInput(canvas, renderer);

    // Preload screen: the SWF's first frame.
    let pre = null;
    const preStart = performance.now();
    if (lib.sprites["asset_ui_preloader"]) {
      pre = new PreloaderScreen(lib);
      menuLayer.addChild(pre);
    }
    loading.style.display = "none";
    let preDone = !pre;
    if (preDone) app.showMainMenu();

    const STEP = 1000 / 60;
    let last = performance.now();
    let acc = 0;
    function frame(now) {
      acc += Math.min(100, now - last);
      last = now;
      let steps = 0;
      while (acc >= STEP && steps < 5) {
        if (!preDone) {
          const p = Math.min(1, (now - preStart) / 700);
          pre.setProgress(p);
          if (p >= 1) {
            preDone = true;
            disposeDisplayTree(pre);
            menuLayer.removeChild(pre);
            app.showMainMenu();
          }
        } else {
          app.tick();
        }
        MovieClip.tickAll();
        acc -= STEP;
        steps++;
      }
      renderer.render(stage);
      requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
  } catch (e) {
    console.error(e);
    err.textContent = String((e && e.stack) || e);
  }
}
boot();
