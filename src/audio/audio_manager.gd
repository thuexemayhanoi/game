extends Node
## Autoload (MOTO HOP): original procedural audio, generated at runtime as
## short PCM tones — no external files, no licensed audio. Fully optional:
## the game plays normally muted or when audio is unavailable.

const SAMPLE_RATE := 22050

var _players: Array[AudioStreamPlayer] = []
var _muted := false

func _ready() -> void:
	for i in range(6):
		var p := AudioStreamPlayer.new()
		p.name = "Player" + str(i)
		add_child(p)
		_players.append(p)
	EventBus.mute_changed.connect(set_muted)
	EventBus.button_clicked.connect(func() -> void: play_click())
	AudioServer.set_bus_mute(0, false)

func set_muted(muted: bool) -> void:
	_muted = muted
	for p in _players:
		p.stop()

func is_muted() -> bool:
	return _muted

func play_hop() -> void:
	_play_tone(660.0, 0.09, 0.35, 1.5)

func play_score() -> void:
	_play_tone(880.0, 0.08, 0.3, 1.0)
	_play_tone(1174.0, 0.08, 0.25, 1.0, 0.06)

func play_crash() -> void:
	_play_noise(0.25, 0.4)

func play_click() -> void:
	_play_tone(1200.0, 0.05, 0.25, 1.0)

func play_milestone() -> void:
	_play_tone(784.0, 0.1, 0.3, 1.0)
	_play_tone(988.0, 0.1, 0.3, 1.0, 0.09)
	_play_tone(1318.0, 0.14, 0.3, 1.0, 0.18)

func _next_player() -> AudioStreamPlayer:
	for p in _players:
		if not p.playing:
			return p
	return _players[0]

func _play_tone(freq: float, duration: float, volume: float, pitch_end_scale: float = 1.0,
		delay: float = 0.0) -> void:
	if _muted:
		return
	var stream := _make_tone(freq, duration, volume, pitch_end_scale)
	if delay > 0.0:
		var timer := get_tree().create_timer(delay)
		timer.timeout.connect(func() -> void:
			if not _muted:
				_next_player().stream = stream
				_next_player().play())
		return
	_next_player().stream = stream
	_next_player().play()

func _play_noise(duration: float, volume: float) -> void:
	if _muted:
		return
	_next_player().stream = _make_noise(duration, volume)
	_next_player().play()

static func _make_tone(freq: float, duration: float, volume: float, pitch_end_scale: float) -> AudioStreamWAV:
	var frames := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(frames * 2)
	var phase := 0.0
	for i in range(frames):
		var t := float(i) / frames
		var f := lerpf(freq, freq * pitch_end_scale, t)
		phase += TAU * f / SAMPLE_RATE
		var env := sin(PI * t)  # smooth fade in/out
		var s := int(clampf(sin(phase) * env * volume, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = data
	return wav

static func _make_noise(duration: float, volume: float) -> AudioStreamWAV:
	var frames := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(frames * 2)
	for i in range(frames):
		var t := float(i) / frames
		var env := (1.0 - t) * (1.0 - t)
		var s := int(clampf(randf_range(-1.0, 1.0) * env * volume, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = data
	return wav
