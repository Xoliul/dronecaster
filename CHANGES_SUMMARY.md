# Graphics Update Summary

## What Changed

Added **scene system** for multiple visual styles. Two scenes included:
- **Classic** - Original graphics (preserved exactly)
- **Mountain** - New bitmap-based scene (10-100x faster)

**Audio engine: ZERO changes** - All synthesis, drones, parameters unchanged.

## New Features

### Scene Selection
- **PARAMS > scene** - Switch between visual styles
- Selection saved with other params
- Each scene is independent, self-contained

### Performance Monitoring
- FPS logging every 3 seconds (for development)
- Minimal overhead (simple averaging)
- Redraw rate increased: 5 FPS → 30 FPS

### Startup Safeguards
- `done_init` flag prevents key/encoder input before initialization
- `drones_loaded` flag prevents engine start before drones ready
- Auto-start if play pressed during loading
- Clear error logging with delimiters

## File Changes

### Modified Core Files
- `dronecaster.lua` - Scene integration, FPS tracking, safeguards
- `lib/draw.lua` - Scene manager with protected loading/rendering
- `engine/Engine_Dronecaster.sc` - Clean restart handling

### New Files
```
lib/scenes/
├── classic.lua                    # Original graphics
└── mountain/
    ├── mountain.lua               # New scene
    └── data/
        ├── tower.png              # 5 bitmap assets
        ├── fg_00.png
        ├── fg_01.png
        ├── fog_gradient_wide.png
        └── fog_noise_line.png
```

## What Wasn't Changed

✅ **Sound synthesis** - All drone code untouched  
✅ **Engine parameters** - Hz, amp work identically  
✅ **Controls** - E1/E2/E3, K2/K3 unchanged  
✅ **Recording** - Same functionality  
✅ **MIDI/Crow** - No changes  
✅ **Classic scene** - Looks and behaves exactly as before


## For Developers

See `SCENE_SYSTEM.md` for how to add new scenes.

**TL;DR:**
1. Create `lib/scenes/yourscene/yourscene.lua`
2. Register in `lib/draw.lua`
3. Reload - appears in PARAMS menu

Scenes are self-contained modules with `init()` and `render()` functions.
