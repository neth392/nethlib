## Quick & simple functions for playing [AudioStream]s.
extends Node

## Instantiates a new [AudioStreamPlayer] of the [param stream] and instantly
## plays it one time, a fire-and-forget function.[br]
## After the stream is finished, the [AudioStreamPlayer] is removed from the scene tree & deleted.[br]
## [param audio_bus_index] The index of the audio bus, useful to use an enum and store
## the indexes as the enum values.[br]
## [param from_position] Plays the audio from this position, in seconds.
func play(stream: AudioStream, audio_bus_index: int, from_position: float = 0.0) -> void:
	assert(stream != null, "audio_stream is null")
	
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	audio_stream_player.bus = AudioServer.get_bus_name(audio_bus_index)
	add_child(audio_stream_player)
	audio_stream_player.stream = stream
	audio_stream_player.play(from_position)
	await audio_stream_player.finished
	audio_stream_player.queue_free()
