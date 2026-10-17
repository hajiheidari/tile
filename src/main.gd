extends Node3D
const Rules = preload("res://src/rules.gd")
const Terrain = preload("res://src/terrain.gd")
const Marble = preload("res://src/marble.gd")
const Art = preload("res://src/art.gd")
const Locale = preload("res://src/locale.gd")
const Gesture = preload("res://src/gesture.gd")
const Sound = preload("res://src/audio.gd")
const COUNTRIES: Array[String] = ["iran","afghanistan","tajikistan","china","dubai","france","india"]
const CREAM := Color("fff3d9")
const INK := Color("184c50")
const TEAL := Color("197980")
const AIM_CAMERA := Vector3(0,0.70,2.50)
const AIM_TARGET := Vector3(0,0.05,-0.50)
var rules = Rules.new()
var loc = Locale.new()
var art: Node3D
var terrain: StaticBody3D
var camera: Camera3D
var sun: DirectionalLight3D
var world_environment: WorldEnvironment
var marbles: Array = []
var shooters: Array = []
var board: Node3D
var canvas: CanvasLayer
var ui: Control
var hud: Control
var sheet: Control
var gesture: Control
var status: Label
var score_label: Label
var phase: String = "menu"
var selected_mode: String = "square"
var against_ai: bool = true
var selected_location: int = 0
var difficulty: int = 1
var skin: int = 1
var avatar: int = 0
var sound: Node
var haptics: bool = true
var reduced_motion: bool = true
var low_quality: bool = false
var qualifier: bool = true
var qualifier_player: int = 0
var qualifier_shots: int = 0
var first_player: int = 0
var placement_button: Button
var launch_outline: Node3D
var match_seed: int = 0
var settling_time: float = 0.0
var shot_time: float = 0.0
var snapshot: Array[Vector3] = []
var next_action: Callable
var rng := RandomNumberGenerator.new()
var lifecycle: int = 0
var qa: bool = false
var saved_phase: String = ""
var font_main: Font

func _ready() -> void:
	rng.randomize()
	qa = "--qa" in OS.get_cmdline_user_args()
	load_preferences()
	var arabic: FontFile = load("res://assets/fonts/NotoSansArabic.ttf")
	var devanagari: FontFile = load("res://assets/fonts/NotoSansDevanagari.ttf")
	arabic.fallbacks = [devanagari, ThemeDB.fallback_font]
	font_main = arabic
	setup_world()
	setup_ui()
	menu()
	if qa:
		qa_run.call_deferred()

func t(key: String) -> String:
	return loc.text(key)

func save_preferences() -> void:
	var cfg := ConfigFile.new()
	for key in ["language","skin","avatar","difficulty","haptics","reduced_motion","low_quality"]:
		cfg.set_value("settings",key,loc.language if key == "language" else get(key))
	cfg.set_value("settings","sound",sound.enabled)
	cfg.save("user://settings.cfg")

func load_preferences() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		var lang: String = cfg.get_value("settings","language","fa")
		loc.language = lang if lang in ["en","fa","ar","hi"] else "fa"
		for key in ["skin","avatar","difficulty","haptics","reduced_motion","low_quality"]:
			set(key,cfg.get_value("settings",key,get(key)))
		skin = clampi(skin,0,2)
		avatar = clampi(avatar,0,1)
		difficulty = clampi(difficulty,0,2)

func setup_world() -> void:
	world_environment = WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("69b6d8")
	sky_mat.sky_horizon_color = Color("b6d9e6")
	sky_mat.ground_bottom_color = Color("b28b64")
	sky_mat.ground_horizon_color = Color("e0edd6")
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c3d7e4")
	env.ambient_light_energy = 0.28
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	world_environment.environment = env
	add_child(world_environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-43,-32,0)
	sun.light_color = Color("ffe4bc")
	sun.light_energy = 0.62
	sun.shadow_enabled = not low_quality
	sun.shadow_opacity=0.62
	sun.shadow_blur=1.5
	sun.directional_shadow_max_distance = 14
	add_child(sun)
	art = Art.new()
	add_child(art)
	art.build_location(0)
	art.build_hand(skin,avatar)
	art.hand_root.visible = false
	camera = Camera3D.new()
	add_child(camera)
	camera.position = AIM_CAMERA
	camera.look_at(AIM_TARGET)
	camera.fov = 56
	camera.near = 0.02
	camera.far = 40
	sound = Sound.new()
	add_child(sound)
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		sound.enabled = cfg.get_value("settings","sound",true)
	new_board(false)
	get_viewport().msaa_3d=Viewport.MSAA_DISABLED if low_quality else Viewport.MSAA_2X

func new_board(for_qualifier: bool) -> void:
	if is_instance_valid(board):
		remove_child(board)
		board.queue_free()
	board = Node3D.new()
	add_child(board)
	terrain = Terrain.new()
	terrain.qualifying = for_qualifier
	terrain.configure(match_seed)
	board.add_child(terrain)
	# Visible boundary: a playing rule, not an invisible collision wall.
	line(Vector3(-1.16,0,1.40),Vector3(1.16,0,1.40),0.003,"b98b5d")
	line(Vector3(-1.16,0,-1.40),Vector3(-1.16,0,1.40),0.003,"b98b5d")
	line(Vector3(1.16,0,-1.40),Vector3(1.16,0,1.40),0.003,"b98b5d")
	line(Vector3(-1.16,0,-1.40),Vector3(1.16,0,-1.40),0.003,"b98b5d")
	if for_qualifier:
		for i in range(48):
			var a: float = i*TAU/48
			var b: float = (i+1)*TAU/48
			line(Vector3(sin(a)*0.09,0,cos(a)*0.09-0.5),Vector3(sin(b)*0.09,0,cos(b)*0.09-0.5),0.003,"f8e8bd")
		line(Vector3(-0.3,0,-0.34),Vector3(0.3,0,-0.34),0.004,"edd2a0")
		line(Vector3(-0.4,0,0.5),Vector3(0.4,0,0.5),0.006,"fff1cd")
	elif selected_mode == "wall":
		var wall := StaticBody3D.new()
		board.add_child(wall)
		wall.position = Vector3(0,0.15,Rules.WALL_Z-0.06)
		art.box(wall,Vector3.ZERO,Vector3(2.3,0.30,0.12),"c48657")
		var cs := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3(2.3,0.30,0.12)
		cs.shape = shape
		wall.add_child(cs)
		var pm := PhysicsMaterial.new()
		pm.bounce = 0.6
		pm.friction = 0.5
		wall.physics_material_override = pm
		for i in range(11):
			art.box(wall,Vector3(-1.0+i*0.2,0.12,0.0),Vector3(0.18,0.08,0.16),"dbab76")
		line(Vector3(-1.1,0,Rules.WALL_Z+Rules.HANDSPAN),Vector3(1.1,0,Rules.WALL_Z+Rules.HANDSPAN),0.004,"e9cf99")
		line(Vector3(-0.8,0,1.0),Vector3(0.8,0,1.0),0.005,"fff1cd")
	else:
		var h: float = Rules.SQUARE_HALF
		line(Vector3(-h,0,-h),Vector3(h,0,-h),0.007,"fff3ce")
		line(Vector3(h,0,-h),Vector3(h,0,h),0.007,"fff3ce")
		line(Vector3(h,0,h),Vector3(-h,0,h),0.007,"fff3ce")
		line(Vector3(-h,0,h),Vector3(-h,0,-h),0.007,"fff3ce")

func line(a: Vector3, b: Vector3, radius: float, color: String) -> void:
	# Short segments follow the actual heightfield, including shallow ruts.
	var count: int = maxi(1,ceili(a.distance_to(b)/0.04))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	var sideways: Vector3 = (b-a).normalized().cross(Vector3.UP)*radius
	for i in range(count+1):
		var p: Vector3 = a.lerp(b,float(i)/count)
		for q in [p-sideways,p+sideways]:
			q.y=terrain.height(q.x,q.z)+0.004
			st.set_normal(Vector3.UP)
			st.add_vertex(q)
	var mesh := MeshInstance3D.new()
	mesh.mesh=st.commit()
	var material := StandardMaterial3D.new()
	material.albedo_color=Color(color)
	material.cull_mode=BaseMaterial3D.CULL_DISABLED
	material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	material.roughness=1
	mesh.material_override=material
	board.add_child(mesh)

func panel_style(color: Color = CREAM, border: Color = Color("d9b988")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(18)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 15
	style.content_margin_bottom = 15
	return style

func setup_ui() -> void:
	canvas = CanvasLayer.new()
	add_child(canvas)
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var theme := Theme.new()
	theme.default_font = font_main
	theme.default_font_size = 22
	theme.set_color("font_color","Label",INK)
	theme.set_stylebox("normal","Button",panel_style())
	theme.set_stylebox("hover","Button",panel_style(Color("f9dfb3")))
	theme.set_stylebox("pressed","Button",panel_style(Color("d9cba8")))
	theme.set_color("font_color","Button",INK)
	theme.set_color("font_hover_color","Button",INK)
	theme.set_color("font_pressed_color","Button",INK)
	ui.theme = theme
	canvas.add_child(ui)
	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(hud)
	gesture = Gesture.new()
	ui.add_child(gesture)
	gesture.shot.connect(human_shot)
	gesture.place_requested.connect(place_shooter)
	gesture.drag_changed.connect(func(power: float):
		if is_instance_valid(art.thumb):
			art.thumb.rotation.x = -power*0.4
			if phase=="aim" and power>0.02 and not shooters.is_empty():
				var direction: Vector3=direction_from_screen((gesture.origin-gesture.pointer).normalized())
				art.hand_root.rotation.y=atan2(-direction.x,-direction.z)
			elif power==0 and phase=="aim":
				art.hand_root.rotation.y=0
	)
	sheet = Control.new()
	sheet.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sheet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(sheet)

func clear_sheet() -> void:
	for child in sheet.get_children():
		sheet.remove_child(child)
		child.queue_free()
	sheet.layout_direction = Control.LAYOUT_DIRECTION_RTL if loc.rtl() else Control.LAYOUT_DIRECTION_LTR

func label(parent: Node, text: String, font_size: int = 22) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size",font_size)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(l)
	return l

func button(parent: Node, text: String, action: Callable, accent: bool = false) -> Button:
	var b := Button.new()
	b.text = text
	b.clip_text = true
	b.custom_minimum_size.y = 64
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if accent:
		b.add_theme_stylebox_override("normal",panel_style(TEAL,TEAL.lightened(0.25)))
		b.add_theme_color_override("font_color",CREAM)
	b.pressed.connect(action)
	parent.add_child(b)
	return b

func vertical(parent: Node, separation: int = 13) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation",separation)
	parent.add_child(v)
	return v

func center_card() -> VBoxContainer:
	clear_sheet()
	var dim := ColorRect.new()
	dim.color = Color(0.035,0.10,0.11,0.53)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sheet.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sheet.add_child(center)
	var card := PanelContainer.new()
	card.custom_minimum_size.x = 620
	card.add_theme_stylebox_override("panel",panel_style())
	center.add_child(card)
	return vertical(card,14)

func menu() -> void:
	lifecycle += 1
	phase = "menu"
	gesture.enabled = false
	gesture.abort()
	art.hand_root.visible = false
	hud.visible = false
	clear_marbles()
	new_board(false)
	clear_sheet()
	var overlay := ColorRect.new()
	overlay.color = Color(0.98,0.94,0.84,0.92)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sheet.add_child(overlay)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right","top","bottom"]:
		margin.add_theme_constant_override("margin_"+side,28)
	sheet.add_child(margin)
	var scroll := ScrollContainer.new()
	margin.add_child(scroll)
	var v: VBoxContainer = vertical(scroll,13)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label(v,"ESPADNA",16)
	label(v,t("title"),44)
	label(v,t("subtitle"),20)
	var langs := HBoxContainer.new()
	langs.add_theme_constant_override("separation",8)
	v.add_child(langs)
	for code in ["en","fa","ar","hi"]:
		var names: Dictionary = {"en":"EN","fa":"فارسی","ar":"العربية","hi":"हिन्दी"}
		button(langs,names[code],func(): loc.language=code; save_preferences(); menu(),loc.language==code)
	label(v,t("destination"),24)
	if selected_location == 0:
		var hero := TextureRect.new()
		hero.texture=load("res://assets/isfahan-menu.png")
		hero.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		hero.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
		hero.custom_minimum_size.y=215
		hero.mouse_filter=Control.MOUSE_FILTER_IGNORE
		v.add_child(hero)
	var location := OptionButton.new()
	location.fit_to_longest_item=false
	location.clip_text=true
	location.custom_minimum_size.y = 62
	location.add_theme_stylebox_override("normal",panel_style())
	location.add_theme_stylebox_override("hover",panel_style(Color("f9dfb3")))
	location.add_theme_stylebox_override("pressed",panel_style(Color("e7d3ab")))
	for key in COUNTRIES:
		location.add_item(t(key))
	location.select(selected_location)
	v.add_child(location)
	location.item_selected.connect(func(index: int): selected_location=index; art.build_location(index); menu())
	# Only the validated dirt location is playable in the first slice.
	if selected_location != 0:
		label(v,t("later"),20)
		button(v,t("back"),func(): selected_location=0; art.build_location(0); menu())
	else:
		label(v,t("surface"),18)
		var modes := HBoxContainer.new()
		modes.add_theme_constant_override("separation",10)
		v.add_child(modes)
		for mode in ["wall","square"]:
			button(modes,t(mode),func(): selected_mode=mode; menu(),selected_mode==mode)
		label(v,t(selected_mode+"_rule"),18)
		button(v,t("practice"),func(): against_ai=true; menu(),against_ai)
		button(v,t("local"),func(): against_ai=false; menu(),not against_ai)
		if against_ai:
			var levels := HBoxContainer.new()
			levels.add_theme_constant_override("separation",8)
			v.add_child(levels)
			for i in range(3):
				button(levels,t(["easy","medium","hard"][i]),func(): difficulty=i; save_preferences(); menu(),difficulty==i)
		button(v,t("start"),start_qualifier,true)
	button(v,t("settings"),settings)
	label(v,t("online"),17)
	label(v,t("prototype"),16)

func settings() -> void:
	var v: VBoxContainer = center_card()
	label(v,t("settings"),30)
	for key in ["sound","haptics","reduced_motion","low_quality"]:
		var check := CheckButton.new()
		check.text = t({"reduced_motion":"motion","low_quality":"quality"}.get(key,key))
		check.button_pressed = sound.enabled if key == "sound" else get(key)
		check.toggled.connect(func(value: bool):
			if key == "sound": sound.enabled=value
			else: set(key,value)
			sun.shadow_enabled = not low_quality
			get_viewport().msaa_3d=Viewport.MSAA_DISABLED if low_quality else Viewport.MSAA_2X
			save_preferences()
		)
		v.add_child(check)
	label(v,t("avatar"),22)
	var hands := HBoxContainer.new()
	v.add_child(hands)
	for i in range(2):
		button(hands,t(["boy","girl"][i]),func(): avatar=i; art.build_hand(skin,avatar); art.hand_root.visible=false; save_preferences(); settings(),avatar==i)
	label(v,t("skin"),22)
	var tones := HBoxContainer.new()
	v.add_child(tones)
	for i in range(3):
		button(tones,t("tone"+str(i+1)),func(): skin=i; art.build_hand(skin,avatar); art.hand_root.visible=false; save_preferences(); settings(),skin==i)
	button(v,t("back"),menu,true)

func clear_marbles() -> void:
	for m in marbles:
		if is_instance_valid(m):
			remove_child(m)
			m.queue_free()
	marbles.clear()
	shooters.clear()

func spawn(pos: Vector3, color: Color, id: int = -1) -> RigidBody3D:
	var marble = Marble.new()
	marble.ground = terrain
	marble.tint = color
	marble.marble_id = id
	marble.is_target = id >= 0
	marble.position = Vector3(pos.x,terrain.height(pos.x,pos.z)+Rules.RADIUS+0.002,pos.z)
	add_child(marble)
	marbles.append(marble)
	marble.impact.connect(sound.hit)
	return marble

func spawn_shooters(z: float) -> void:
	shooters.append(spawn(Vector3(-0.10,0,z),Color("07a9d1")))
	shooters.append(spawn(Vector3(0.10,0,z),Color("e78b46")))
	# Both marbles remain dynamic: even an opponent waiting for a turn can be displaced.

func start_qualifier() -> void:
	match_seed = randi_range(1,2147483646)
	lifecycle += 1
	rules.start(selected_mode,first_player)
	qualifier = true
	qualifier_player = first_player
	qualifier_shots = 0
	clear_marbles()
	new_board(true)
	spawn_shooters(0.5)
	hud.visible = true
	var v: VBoxContainer = center_card()
	label(v,t("qualifier"),29)
	label(v,t("qualifier_rule"),21)
	button(v,t("ready"),prepare_turn,true)

func start_match(first: int) -> void:
	if match_seed == 0: match_seed = randi_range(1,2147483646)
	qualifier = false
	hud.visible = true
	rules.start(selected_mode,first)
	clear_marbles()
	new_board(false)
	spawn_shooters(1.0 if selected_mode=="wall" else 0.94)
	if selected_mode == "square":
		var colors: Array[String] = ["e9533f","1eafc3","f7be35","6dad55","e99a4e","774fc1"]
		for i in range(6):
			spawn(Vector3(-0.16+(i%3)*0.16,0,-0.12+(i/3)*0.24),Color(colors[i]),i)
	prepare_turn()

func player() -> int:
	return qualifier_player if qualifier else rules.current

func player_name(p: int) -> String:
	return t("computer") if against_ai and p==1 else t("you" if p==0 else "other")

func prepare_turn() -> void:
	if not qualifier and rules.finished:
		match_result()
		return
	clear_sheet()
	camera.position=AIM_CAMERA
	camera.look_at(AIM_TARGET)
	phase = "aim"
	gesture.placing=false
	settling_time = 0
	shot_time = 0
	var shooter: RigidBody3D = shooters[player()]
	var turn_token: int = lifecycle
	# Square uses a fresh marked launch position each turn; wall has one shot per round.
	if not qualifier and selected_mode=="square":
		shooter.teleport(Vector3(-0.10 if player()==0 else 0.10,terrain.height(-0.10 if player()==0 else 0.10,0.94)+Rules.RADIUS+0.002,0.94))
		shooter.freeze = false
		await get_tree().physics_frame
		await get_tree().physics_frame
		if turn_token != lifecycle:
			return
	for marble in marbles: marble.freeze=true
	art.hand_root.position = Vector3(shooter.position.x,terrain.height(shooter.position.x,shooter.position.z),shooter.position.z)
	art.hand_root.rotation.y=0
	art.hand_root.visible = true
	art.thumb.rotation.x = 0
	update_hud()
	gesture.enabled = not (against_ai and player()==1)
	gesture.power_text = t("power")
	gesture.cancel_text = t("cancel")
	gesture.queue_redraw()
	if against_ai and player()==1:
		var token: int = lifecycle
		await get_tree().create_timer(0.8).timeout
		if token==lifecycle and phase=="aim":
			ai_shot()

func update_hud() -> void:
	for c in hud.get_children():
		hud.remove_child(c)
		c.queue_free()
	hud.layout_direction = Control.LAYOUT_DIRECTION_RTL if loc.rtl() else Control.LAYOUT_DIRECTION_LTR
	var top := PanelContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left=20
	top.offset_right=-20
	top.offset_top=22
	var top_style: StyleBoxFlat=panel_style(Color(1.0,0.953,0.85,0.96))
	top_style.content_margin_top=5
	top_style.content_margin_bottom=5
	top.add_theme_stylebox_override("panel",top_style)
	hud.add_child(top)
	var v: VBoxContainer = vertical(top,2)
	label(v,t("qualifier") if qualifier else t(selected_mode),22)
	score_label = label(v,player_name(0)+"   "+str(rules.scores[0])+"      :      "+str(rules.scores[1])+"   "+player_name(1),21)
	if not qualifier and selected_mode=="wall":
		label(v,t("round")+" "+str(rules.round_number)+" / 5",17)
	label(v,t("turn")+" · "+player_name(player()),16)
	var pause_button: Button = button(hud,"II",pause_game)
	pause_button.position = Vector2(640,155)
	pause_button.size = Vector2(60,64)
	var status_bg:=PanelContainer.new()
	status_bg.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	status_bg.offset_left=24
	status_bg.offset_right=-24
	status_bg.offset_top=-88
	status_bg.offset_bottom=-24
	status_bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
	status_bg.add_theme_stylebox_override("panel",panel_style(Color(0.07,0.25,0.27,0.90),Color(0.25,0.49,0.49,0.5)))
	hud.add_child(status_bg)
	placement_button=button(hud,t("place"),toggle_placement)
	placement_button.position=Vector2(225,1055)
	placement_button.size=Vector2(270,48)
	placement_button.visible=not(against_ai and player()==1)
	status=label(status_bg,t("aim"),18)
	status.add_theme_color_override("font_color",CREAM)

func launch_bounds() -> Rect2:
	return Rect2(-0.65,0.48 if qualifier else 0.72,1.30,0.04 if qualifier else 0.35)

func toggle_placement() -> void:
	if phase!="aim": return
	gesture.abort()
	gesture.placing=not gesture.placing
	placement_button.text=t("done_place") if gesture.placing else t("place")
	status.text=t("place_help") if gesture.placing else t("aim")
	if is_instance_valid(launch_outline): launch_outline.queue_free()
	launch_outline=Node3D.new()
	board.add_child(launch_outline)
	var bounds: Rect2=launch_bounds()
	var corners: Array[Vector2]=[bounds.position,Vector2(bounds.end.x,bounds.position.y),bounds.end,Vector2(bounds.position.x,bounds.end.y)]
	for i in range(4):
		var a: Vector2=corners[i]
		var b: Vector2=corners[(i+1)%4]
		for j in range(20):
			var u: Vector2=a.lerp(b,float(j)/20)
			var v: Vector2=a.lerp(b,float(j+1)/20)
			var segment:=MeshInstance3D.new()
			var mesh:=CylinderMesh.new()
			mesh.top_radius=0.002
			mesh.bottom_radius=0.002
			var start:=Vector3(u.x,terrain.height(u.x,u.y)+0.003,u.y)
			var end:=Vector3(v.x,terrain.height(v.x,v.y)+0.003,v.y)
			mesh.height=start.distance_to(end)
			segment.mesh=mesh
			segment.position=(start+end)/2
			segment.quaternion=Quaternion(Vector3.UP,(end-start).normalized())
			var material:=StandardMaterial3D.new()
			material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
			material.albedo_color=Color("5de5d5")
			segment.material_override=material
			launch_outline.add_child(segment)
	launch_outline.visible=gesture.placing

func place_shooter(screen: Vector2) -> void:
	if phase!="aim" or not gesture.placing or (against_ai and player()==1): return
	var hit: Variant=Plane(Vector3.UP,0).intersects_ray(camera.project_ray_origin(screen),camera.project_ray_normal(screen))
	if not hit is Vector3: return
	var point: Vector2=Vector2(hit.x,hit.z)
	# The qualifying line is narrow: accept a finger-sized hit zone and snap
	# back to the one-metre line so placement cannot shorten the attempt.
	if qualifier and absf(point.y-0.5)<0.12: point.y=0.5
	if not launch_bounds().has_point(point): return
	var pos:=Vector3(point.x,terrain.height(point.x,point.y)+Rules.RADIUS+0.002,point.y)
	for marble in marbles:
		if marble!=shooters[player()] and marble.position.distance_to(pos)<Rules.RADIUS*2.2: return
	var shooter: RigidBody3D=shooters[player()]
	shooter.freeze=true
	shooter.position=pos
	shooter.reset_position=pos
	shooter.pending_reset=false
	shooter.linear_velocity=Vector3.ZERO
	shooter.angular_velocity=Vector3.ZERO
	art.hand_root.position=Vector3(pos.x,terrain.height(pos.x,pos.z),pos.z)

func human_shot(vector: Vector2, power: float) -> void:
	if phase != "aim" or (against_ai and player()==1):
		return
	shoot(direction_from_screen(vector),power)

func direction_from_screen(vector: Vector2) -> Vector3:
	# The visible guide is in screen space. Unproject it onto the launch plane so
	# diagonal shots follow the guide even with a low, perspective aiming camera.
	var shooter: RigidBody3D=shooters[player()]
	var screen_start: Vector2=camera.unproject_position(shooter.global_position)
	var screen_target: Vector2=screen_start+vector.normalized()*150.0
	var plane:=Plane(Vector3.UP,shooter.global_position.y)
	var intersection: Variant=plane.intersects_ray(camera.project_ray_origin(screen_target),camera.project_ray_normal(screen_target))
	if intersection is Vector3:
		var direction: Vector3=intersection-shooter.global_position
		direction.y=0
		return direction.normalized()
	return Vector3(vector.x,0,vector.y).normalized()

func shoot(direction: Vector3, power: float) -> void:
	if phase != "aim" or not is_finite(power) or not direction.is_finite():
		return
	phase = "release"
	gesture.enabled=false
	gesture.placing=false
	if is_instance_valid(launch_outline): launch_outline.visible=false
	gesture.abort()
	art.hand_root.rotation.y=atan2(-direction.x,-direction.z)
	snapshot.clear()
	for m in marbles:
		snapshot.append(m.position)
	var shooter: RigidBody3D = shooters[player()]
	var speed: float = lerpf(0.2,Rules.MAX_SHOT_SPEED,clampf(power,0,1))
	var impulse: Vector3 = Vector3(direction.x,0,direction.z).normalized()*speed*shooter.mass
	var token: int = lifecycle
	art.shot_animation(func():
		if token != lifecycle: return
		for marble in marbles: marble.freeze=false
		shooter.sleeping=false
		shooter.apply_central_impulse(impulse)
		phase="rolling"
		shot_time=0
		settling_time=0
		if haptics and OS.has_feature("mobile"):
			Input.vibrate_handheld(22)
		status.text=t("settling")
	)
	await get_tree().create_timer(0.3).timeout
	if token==lifecycle:
		art.hand_root.visible=false

func ai_shot() -> void:
	var shooter: RigidBody3D = shooters[player()]
	var target: Vector3 = Vector3(0,0,-0.5 if qualifier else Rules.WALL_Z+Rules.RADIUS+0.04)
	if not qualifier and selected_mode=="square":
		var best: float = INF
		for m in marbles:
			if m.is_target:
				var cost: float = shooter.position.distance_to(m.position)
				if cost < best:
					best=cost
					target=m.position
	elif not qualifier and difficulty==2:
		# Hard difficulty may aim through a nearby opponent to displace it.
		var opponent: RigidBody3D = shooters[1-player()]
		if opponent.position.z < 0.2 and opponent.position.x < 0.5:
			target=opponent.position
	var delta: Vector3 = target-shooter.position
	delta.y=0
	var direction: Vector3 = delta.normalized()
	var distance: float = delta.length()
	# Integrate known resistance along the intended path; not hidden trajectory control.
	var resistance: float = 0.0
	var samples: int = [4,12,24][difficulty]
	for i in range(samples):
		var pos: Vector3 = shooter.position.lerp(target,float(i)/samples)
		resistance += 0.34*terrain.softness(pos.x,pos.z)/samples
	var rolling_compensation: float=1.14 if not qualifier and selected_mode=="square" else 1.50
	var speed: float = sqrt(2.0*resistance*distance)*rolling_compensation
	if not qualifier and selected_mode=="square":
		speed += [0.4,0.7,0.95][difficulty]
	var error: float = [0.15,0.055,0.018][difficulty]
	direction = direction.rotated(Vector3.UP,rng.randf_range(-error,error))
	speed *= rng.randf_range(1-error,1+error)
	shoot(direction,clampf((speed-0.2)/(Rules.MAX_SHOT_SPEED-0.2),0.0,1.0))

func _process(dt: float) -> void:
	if phase=="aim" and not shooters.is_empty():
		var m: RigidBody3D = shooters[player()]
		gesture.shooter_screen = camera.unproject_position(m.global_position)
		gesture.queue_redraw()
	elif phase=="rolling" and not reduced_motion:
		var follow_x: float = clampf(shooters[player()].position.x*0.12,-0.10,0.10)
		camera.position.x=lerpf(camera.position.x,follow_x,minf(dt*2,1))

func _physics_process(dt: float) -> void:
	if phase != "rolling":
		sound.set_roll(0)
		return
	shot_time+=dt
	var fastest: float = 0
	var invalid: bool = false
	for m in marbles:
		fastest=maxf(fastest,m.linear_velocity.length())
		if Rules.out_of_bounds(m.position):
			invalid=true
	sound.set_roll(fastest)
	settling_time = settling_time+dt if fastest < 0.025 else 0.0
	if invalid or shot_time>14:
		finish_shot(true)
	elif settling_time>0.65 and shot_time>0.8:
		finish_shot(false)

func finish_shot(recover: bool) -> void:
	phase="resolving"
	var token: int = lifecycle
	sound.set_roll(0)
	if recover:
		for i in range(marbles.size()):
			marbles[i].teleport(snapshot[i])
		await get_tree().physics_frame
		await get_tree().physics_frame
	if token != lifecycle:
		return
	phase="result"
	if qualifier:
		qualifier_shots+=1
		if qualifier_shots<2:
			qualifier_player=1-qualifier_player
			turn_handoff(t("recovery") if recover else "",prepare_turn)
			return
		var distances: Array[float] = []
		for m in shooters:
			distances.append(maxf(0.0,Vector2(m.position.x,m.position.z+0.5).length()-0.09-Rules.RADIUS))
		var tied: bool = absf(distances[0]-distances[1])<=Rules.TIE_TOLERANCE
		var first: int = 0 if distances[0]<distances[1] else 1
		var detail: String = t("draw") if tied else player_name(first)+" · "+t("qualifier")
		var v: VBoxContainer = center_card()
		label(v,detail,28)
		for p in range(2):
			label(v,player_name(p)+" · "+str(snappedf(distances[p]*100,0.1))+" "+t("cm"),21)
		button(v,t("next"),func():
			if tied:
				first_player=1-first_player
				start_qualifier()
			else: start_match(first)
		,true)
		return
	if selected_mode=="wall":
		var result: Dictionary = rules.finish_wall_shot([shooters[0].position,shooters[1].position])
		if result.is_empty():
			match_result()
			return
		if result.round_complete:
			var v: VBoxContainer = center_card()
			label(v,t("round")+" "+str(result.round),28)
			for p in range(2):
				label(v,player_name(p)+" · "+str(snappedf(result.distances[p]*100,0.1))+" "+t("cm")+" · +"+str(result.points[p])+" "+t("points"),21)
			if recover: label(v,t("recovery"),18)
			button(v,t("next"),func():
				if rules.finished: match_result()
				else: reset_wall_round(); turn_handoff("",prepare_turn)
			,true)
		else:
			turn_handoff(t("recovery") if recover else "",prepare_turn)
	else:
		var ids: Array[int] = []
		var remove: Array = []
		if not recover:
			for m in marbles:
				if m.is_target and Rules.completely_outside_square(m.position):
					ids.append(m.marble_id)
					remove.append(m)
		for m in remove:
			marbles.erase(m)
			m.queue_free()
		var left: int = 0
		for m in marbles:
			if m.is_target: left+=1
		var gained: int = rules.finish_square_shot(ids,left)
		if rules.finished:
			match_result()
		else:
			turn_handoff(t("recovery") if recover else "+"+str(gained)+" "+t("points"),prepare_turn)

func reset_wall_round() -> void:
	for i in range(2):
		var x: float = -0.10 if i==0 else 0.10
		shooters[i].teleport(Vector3(x,terrain.height(x,1.0)+Rules.RADIUS+0.002,1.0))
		shooters[i].freeze=false

func turn_handoff(detail: String, action: Callable) -> void:
	phase="handoff"
	var v: VBoxContainer = center_card()
	label(v,player_name(player()),30)
	label(v,t("handoff") if not against_ai else t("turn"),23)
	if not detail.is_empty(): label(v,detail,19)
	button(v,t("ready"),action,true)
	if against_ai and player()==1:
		var token: int = lifecycle
		await get_tree().create_timer(0.7).timeout
		if token==lifecycle and phase=="handoff":
			action.call()

func match_result() -> void:
	phase="finished"
	gesture.enabled=false
	var v: VBoxContainer = center_card()
	label(v,t("draw") if rules.winner<0 else t("won")+" · "+player_name(rules.winner),32)
	label(v,str(rules.scores[0])+" : "+str(rules.scores[1]),42)
	button(v,t("again"),start_qualifier,true)
	button(v,t("home"),menu)

func pause_game() -> void:
	if phase not in ["aim","rolling"]:
		return
	saved_phase=phase
	phase="paused"
	gesture.enabled=false
	gesture.abort()
	get_tree().paused=true
	sheet.process_mode=Node.PROCESS_MODE_ALWAYS
	var v: VBoxContainer = center_card()
	label(v,t("pause"),30)
	button(v,t("resume"),func():
		get_tree().paused=false
		phase=saved_phase
		clear_sheet()
		gesture.enabled=phase=="aim" and not(against_ai and player()==1)
	,true)
	button(v,t("home"),func(): get_tree().paused=false; menu())

func qa_run() -> void:
	# Native render smoke captures use the same scenes, not a separate mockup.
	loc.language="en"
	menu()
	await get_tree().create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://build/qa-menu.png")
	against_ai=false
	start_match(0)
	await get_tree().create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://build/qa-square.png")
	human_shot(Vector2(0,-1),0.45)
	await get_tree().create_timer(10).timeout
	print("QA square phase=",phase," shots=",rules.total_shots)
	selected_mode="wall"
	start_match(0)
	await get_tree().create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://build/qa-wall.png")
	loc.language="fa"
	menu()
	await get_tree().create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://build/qa-fa.png")
	for code in ["ar","hi"]:
		loc.language=code
		menu()
		await get_tree().create_timer(0.25).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://build/qa-"+code+".png")
	get_tree().quit()
