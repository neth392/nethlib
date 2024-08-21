class_name MultiplayerTest extends Node

const IP_ADDRESS: String = "localhost"
const PORT: int = 25565

@export var host_label: Label
@export var server_ui: CanvasLayer
@export var join_button: Button
@export var host_button: Button
@export var spawn_button: Button
@export var scene_to_spawn: PackedScene
@export var sync_nodes: Node
@export var add_to_string_button: Button

@onready var synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

func _ready() -> void:
	host_button.pressed.connect(host)
	join_button.pressed.connect(join)
	spawn_button.pressed.connect(_spawn_pressed)


func host() -> void:
	print("host()")
	host_label.text = "HOST"
	join_button.queue_free()
	host_button.queue_free()
	var server_peer: MultiplayerPeer = ENetMultiplayerPeer.new()
	server_peer.create_server(PORT)
	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func join() -> void:
	print("join()")
	host_label.text = "CLIENT"
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


func _spawn_pressed() -> void:
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		print("_spawn_pressed: NOT CONNECTED")
		return
	if !is_multiplayer_authority():
		print("_spawn_pressed: NOT AUTHORITY")
		return
	_kill_spawn_button.rpc()
	print("_spawn_pressed: IS AUTHORITY")
	var node: MpTestNodeToSync = scene_to_spawn.instantiate() as MpTestNodeToSync
	sync_nodes.add_child(node, true)
	
	synchronizer.root_path = node.get_path()
	synchronizer.replication_config.add_property(":test_sync_string")
	node.test_sync_string = "Changed!"


@rpc("authority", "call_local")
func _kill_spawn_button() -> void:
	spawn_button.queue_free()
