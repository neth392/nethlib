class_name MultiplayerTest extends Node

const IP_ADDRESS: String = "localhost"
const PORT: int = 25565

@export var server_ui: CanvasLayer
@export var join_button: Button
@export var host_button: Button

func _ready() -> void:
	host_button.pressed.connect(host)
	join_button.pressed.connect(join)


func host() -> void:
	print("host()")
	join_button.queue_free()
	host_button.queue_free()
	var server_peer: MultiplayerPeer = ENetMultiplayerPeer.new()
	server_peer.create_server(PORT)
	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func join() -> void:
	print("join()")
	join_button.queue_free()
	host_button.queue_free()
	var client_peer: MultiplayerPeer = ENetMultiplayerPeer.new()
	var result: Error = client_peer.create_client(IP_ADDRESS, PORT)
	if result != OK:
		print("ERROR: %s" % result)
		return
	
	multiplayer.multiplayer_peer = client_peer


func _on_peer_connected(id: int) -> void:
	print("Peer connected: %s" % id)

func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected: %s" % id)
