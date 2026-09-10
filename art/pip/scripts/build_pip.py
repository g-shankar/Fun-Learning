"""Build Pip - a cute 3D mascot for a kids' alphabet tracing app.
Run: blender --background --python build_pip.py -- --mode preview
     blender --background --python build_pip.py -- --mode export
"""
import bpy
import math
import sys
import os

# ---------------------------------------------------------------- args
argv = sys.argv
argv = argv[argv.index("--") + 1:] if "--" in argv else []
MODE = "preview"
i = 0
while i < len(argv):
    a = argv[i]
    if a.startswith("mode="):
        MODE = a.split("=", 1)[1]
    elif a == "--mode" and i + 1 < len(argv):
        MODE = argv[i + 1]
        i += 1
    i += 1

OUT_DIR = os.path.dirname(os.path.abspath(__file__)) + "/.."
RENDER_DIR = os.path.join(OUT_DIR, "renders")

# ---------------------------------------------------------------- palette
SKINS = {
    "coral": {"skin": (1.0, 0.40, 0.25),  "belly": (1.0, 0.64, 0.51)},
    "mint":  {"skin": (0.41, 0.81, 0.58), "belly": (0.66, 0.91, 0.75)},
    "sky":   {"skin": (0.41, 0.65, 0.88), "belly": (0.66, 0.80, 0.93)},
}
DEFAULT_SKIN = "coral"

# ---------------------------------------------------------------- helpers
def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for coll in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                 bpy.data.cameras, bpy.data.curves):
        for x in list(coll):
            coll.remove(x)

def mat_principled(name, base_color, roughness=0.55, subsurface=0.35,
                   spec=0.5, metallic=0.0):
    m = bpy.data.materials.new(name=name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    if "Subsurface" in bsdf.inputs:
        bsdf.inputs["Subsurface"].default_value = subsurface
    if "Subsurface Weight" in bsdf.inputs:  # Blender 4.x renamed socket
        bsdf.inputs["Subsurface Weight"].default_value = subsurface
    if "Subsurface Color" in bsdf.inputs:
        # warm lighter tint of base
        bsdf.inputs["Subsurface Color"].default_value = (
            min(1.0, base_color[0] * 0.6 + 0.45),
            min(1.0, base_color[1] * 0.6 + 0.35),
            min(1.0, base_color[2] * 0.6 + 0.30), 1.0)
    bsdf.inputs["Specular IOR Level"].default_value = spec
    bsdf.inputs["Metallic"].default_value = metallic
    return m

def new_sphere(name, radius, location, scale, mat, seg=24, rings=12):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=seg, ring_count=rings, radius=radius, location=location)
    o = bpy.context.active_object
    o.name = name
    o.scale = scale
    sub = o.modifiers.new("Subdiv", "SUBSURF")
    sub.levels = 2
    sub.render_levels = 2
    for p in o.data.polygons:
        p.use_smooth = True
    if mat:
        o.data.materials.append(mat)
    return o

# ---------------------------------------------------------------- build Pip
def build_pip(skin_name):
    clear_scene()
    pal = SKINS[skin_name]

    skin = mat_principled("Skin", pal["skin"], roughness=0.55, subsurface=0.35)
    belly_m = mat_principled("Belly", pal["belly"], roughness=0.6, subsurface=0.3)
    white = mat_principled("EyeWhite", (1, 1, 1), roughness=0.12, subsurface=0.0, spec=0.9)
    dark = mat_principled("Pupil", (0.09, 0.07, 0.06), roughness=0.08, subsurface=0.0, spec=1.0)
    mouth_m = mat_principled("Mouth", (0.55, 0.32, 0.24), roughness=0.5, subsurface=0.1)
    blush_m = mat_principled("Blush", (1.0, 0.55, 0.55), roughness=0.7, subsurface=0.4)
    glint = mat_principled("Glint", (1, 1, 1), roughness=0.0, subsurface=0.0, spec=1.0)

    parts = []

    # body - soft pear blob
    body = new_sphere("Body", 1.0, (0, 0, 1.15), (1.0, 0.92, 1.05), skin)
    parts.append(body)

    # belly patch
    belly = new_sphere("Belly", 1.0, (0, 0.60, 0.80), (0.60, 0.34, 0.76), belly_m)
    parts.append(belly)

    # eyes
    for side in (-1, 1):
        x = 0.37 * side
        sclera = new_sphere("Sclera", 0.30, (x, 0.70, 1.62), (1.0, 0.72, 1.12), white)
        pupil = new_sphere("Pupil", 0.125, (x + 0.02 * side, 0.90, 1.68),
                           (1.0, 0.7, 1.0), dark, seg=20, rings=10)
        hl = new_sphere("Glint", 0.045, (x + 0.06 * side, 0.965, 1.745),
                        (1, 1, 1), glint, seg=12, rings=8)
        parts += [sclera, pupil, hl]

    # smile - smooth arc sampled from a circle (9 points, no cusps)
    bpy.ops.curve.primitive_bezier_curve_add(location=(0, 0.90, 1.34))
    smile = bpy.context.active_object
    smile.name = "Smile"
    spline = smile.data.splines[0]
    spline.bezier_points.add(7)  # 9 points total
    r = 0.34
    for i, bp in enumerate(spline.bezier_points):
        theta = math.radians(200 + (140 * i / 8))  # 200..340 deg
        bp.co = (r * math.cos(theta), 0, r * math.sin(theta))
        bp.handle_left_type = "AUTO"
        bp.handle_right_type = "AUTO"
        # taper the smile toward the corners
        edge = abs(i - 4) / 4.0  # 0 center .. 1 ends
        bp.radius = 1.0 - 0.55 * edge
    smile.data.bevel_depth = 0.042
    smile.data.bevel_resolution = 4
    smile.data.fill_mode = "FULL"
    bpy.ops.object.select_all(action="DESELECT")
    smile.select_set(True)
    bpy.context.view_layer.objects.active = smile
    bpy.ops.object.convert(target="MESH")
    smile = bpy.context.active_object
    smile.name = "Smile"
    sub = smile.modifiers.new("Subdiv", "SUBSURF")
    sub.levels = 2
    sub.render_levels = 2
    for p in smile.data.polygons:
        p.use_smooth = True
    smile.data.materials.append(mouth_m)
    parts.append(smile)

    # blush cheeks
    for side in (-1, 1):
        b = new_sphere("Blush", 0.13, (0.60 * side, 0.76, 1.26),
                       (1.0, 0.35, 0.75), blush_m, seg=20, rings=10)
        parts.append(b)

    # stubby arms
    for side in (-1, 1):
        a = new_sphere("Arm", 1.0, (1.02 * side, 0.02, 1.02),
                       (0.16, 0.16, 0.42), skin)
        a.rotation_euler = (0, -0.45 * side, 0)
        parts.append(a)

    # feet
    for side in (-1, 1):
        f = new_sphere("Foot", 1.0, (0.40 * side, 0.10, 0.18),
                       (0.32, 0.40, 0.20), skin)
        parts.append(f)

    # hair tuft - 3 little spikes
    tuft_mat = skin
    for i, (dx, tilt) in enumerate([(-0.15, 0.5), (0.0, 0.0), (0.15, -0.5)]):
        bpy.ops.mesh.primitive_cone_add(
            radius1=0.10, radius2=0.015, depth=0.42,
            location=(dx, -0.02, 2.30),
            rotation=(0.12, tilt, 0))
        t = bpy.context.active_object
        t.name = f"Tuft{i}"
        sub = t.modifiers.new("Subdiv", "SUBSURF")
        sub.levels = 2
        sub.render_levels = 2
        for p in t.data.polygons:
            p.use_smooth = True
        t.data.materials.append(tuft_mat)
        parts.append(t)

    return {"parts": parts, "mats": {"skin": skin, "belly": belly_m}}

# ---------------------------------------------------------------- studio
# EEVEE can't run headless here (no EGL/GPU), so everything is Cycles on CPU.
# Preview = small/fast for iteration; final = full quality for judgment shots.
STUDIO_SAMPLES = 24
STUDIO_RES = 512

def setup_studio():
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = STUDIO_SAMPLES
    scene.cycles.use_denoising = True
    scene.cycles.denoiser = "OPENIMAGEDENOISE"
    scene.render.resolution_x = STUDIO_RES
    scene.render.resolution_y = STUDIO_RES
    scene.render.resolution_percentage = 100
    scene.render.film_transparent = False

    world = bpy.context.scene.world
    world.use_nodes = True
    bg = world.node_tree.nodes.get("Background")
    bg.inputs["Color"].default_value = (0.94, 0.92, 0.88, 1.0)
    bg.inputs["Strength"].default_value = 0.85

    def area_light(name, loc, energy, size, color=(1, 1, 1)):
        bpy.ops.object.light_add(type="AREA", location=loc)
        l = bpy.context.active_object
        l.name = name
        l.data.energy = energy
        l.data.size = size
        l.data.color = color
        return l

    area_light("Key", (4.5, 5.0, 6.5), 700, 4.0, (1.0, 0.97, 0.93))
    area_light("Fill", (-5.0, 4.0, 3.0), 320, 5.0, (0.93, 0.96, 1.0))
    area_light("Rim", (-1.5, -6.0, 5.5), 650, 3.0, (1.0, 0.95, 0.88))

    bpy.ops.mesh.primitive_plane_add(size=30, location=(0, 0, -0.02))
    ground = bpy.context.active_object
    ground.name = "Ground"
    ground.is_shadow_catcher = True

def add_camera(name, location, target):
    bpy.ops.object.empty_add(location=target)
    tgt = bpy.context.active_object
    tgt.name = name + "_Target"
    bpy.ops.object.camera_add(location=location)
    cam = bpy.context.active_object
    cam.name = name
    cam.data.lens = 50
    con = cam.constraints.new("TRACK_TO")
    con.target = tgt
    con.track_axis = "TRACK_NEGATIVE_Z"
    con.up_axis = "UP_Y"
    return cam

def render_view(path, cam_location, cam_target):
    scene = bpy.context.scene
    cam = add_camera("Cam", cam_location, cam_target)
    scene.camera = cam
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    # cleanup cam + target
    bpy.data.objects.remove(cam, do_unlink=True)

# ---------------------------------------------------------------- run
def do_preview_renders(suffix=""):
    os.makedirs(RENDER_DIR, exist_ok=True)
    render_view(os.path.join(RENDER_DIR, f"pip_34{suffix}.png"),
                (3.1, 4.8, 2.3), (0, 0, 1.15))
    render_view(os.path.join(RENDER_DIR, f"pip_front{suffix}.png"),
                (0, 5.4, 1.7), (0, 0, 1.20))
    render_view(os.path.join(RENDER_DIR, f"pip_face{suffix}.png"),
                (0.85, 2.7, 2.0), (0, 0.35, 1.55))

if MODE == "preview":
    build_pip(DEFAULT_SKIN)
    setup_studio()
    do_preview_renders()
    print("PREVIEW RENDERS DONE")

elif MODE == "final":
    STUDIO_SAMPLES = 64
    STUDIO_RES = 1024
    build_pip(DEFAULT_SKIN)
    setup_studio()
    do_preview_renders(suffix="_final")
    print("FINAL RENDERS DONE")

elif MODE == "export":
    for skin_name in SKINS:
        info = build_pip(skin_name)
        # lighten subdivision for mobile GLB
        for o in info["parts"]:
            for m in o.modifiers:
                if m.type == "SUBSURF":
                    m.levels = 1
                    m.render_levels = 1
        bpy.ops.object.select_all(action="SELECT")
        bpy.context.view_layer.objects.active = info["parts"][0]
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
        # drop studio-only objects from export: keep meshes only
        bpy.ops.object.select_all(action="DESELECT")
        for o in info["parts"]:
            o.select_set(True)
        suffix = "" if skin_name == DEFAULT_SKIN else f"_{skin_name}"
        out = os.path.join(OUT_DIR, f"pip{suffix}.glb")
        bpy.ops.export_scene.gltf(
            filepath=out, export_format="GLB",
            use_selection=True, export_apply=True,
            export_materials="EXPORT",
            export_cameras=False, export_lights=False)
        print("EXPORTED", out)
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT_DIR, "pip.blend"))
    print("BLEND SAVED")
