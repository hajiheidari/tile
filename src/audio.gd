extends Node
## Original synthesized prototype audio; no external recording licenses.
var enabled: bool = true
var rolling: AudioStreamPlayer

func _exit_tree() -> void:
	if is_instance_valid(rolling):
		rolling.stop()
		rolling.stream=null

func _ready() -> void:
	rolling = AudioStreamPlayer.new()
	add_child(rolling)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = 22050
	var bytes := PackedByteArray()
	bytes.resize(44100)
	var rng := RandomNumberGenerator.new()
	rng.seed = 481
	var last: float = 0.0
	for i in range(22050):
		last = lerpf(last,rng.randf_range(-1,1),0.18)
		bytes.encode_s16(i*2,int(last*2500))
	stream.data = bytes
	rolling.stream = stream
	rolling.volume_db = -80
	if DisplayServer.get_name() != "headless":
		rolling.play()

func set_roll(speed: float) -> void:
	if is_instance_valid(rolling):
		rolling.volume_db = linear_to_db(clampf(speed*0.24,0.0001,0.35)) if enabled else -80.0

func hit(speed: float) -> void:
	if not enabled or speed < 0.10:
		return
	var sample := AudioStreamWAV.new()
	sample.format = AudioStreamWAV.FORMAT_16_BITS
	sample.mix_rate = 22050
	var bytes := PackedByteArray()
	bytes.resize(6600)
	for i in range(3300):
		var t: float = float(i)/22050
		var value: float = (sin(TAU*2400*t)+0.40*sin(TAU*3701*t))*exp(-t*45)*minf(speed*0.3,0.8)
		bytes.encode_s16(i*2,int(clampf(value,-1,1)*19000))
	sample.data = bytes
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = sample
	player.finished.connect(player.queue_free)
	player.play()
