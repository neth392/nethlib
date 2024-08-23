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
@export var spawner: MultiplayerSpawner
@export var clear_string_button: Button 

@onready var resource_button: Button = $ServerUI/VBoxContainer/Resource

var synced_node: MpTestNodeToSync
var server_id: int = 1

var _resource_sync: ResourceSync:
	set(value):
		_resource_sync = value
		print("RESOURCE SYNC SET: " + str(multiplayer.multiplayer_peer.get_unique_id()))

func _ready() -> void:
	host_button.pressed.connect(host)
	join_button.pressed.connect(join)
	spawn_button.pressed.connect(_spawn_pressed)
	add_to_string_button.pressed.connect(_add_to_string_pressed)
	spawner.spawned.connect(_spawned)
	clear_string_button.pressed.connect(_clear_string_pressed)
	resource_button.pressed.connect(_on_resource_pressed)


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
	synced_node = scene_to_spawn.instantiate() as MpTestNodeToSync
	sync_nodes.add_child(synced_node, true)
	synced_node.test_sync_string = "Start: "


@rpc("authority", "call_local")
func _kill_spawn_button() -> void:
	spawn_button.queue_free()


func _spawned(node: Node) -> void:
	print("SPAWNED: " + node.name)
	synced_node = node as MpTestNodeToSync


func _add_to_string_pressed() -> void:
	if synced_node == null:
		print("NO NODE!")
		return
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		print("NOT CONNECTED!")
		return
	if multiplayer.is_server():
		# Add something to the string so I can see if it replicates
		synced_node.test_sync_string += str(synced_node.test_sync_string.length())
	else:
		synced_node.set_test_sync_string.rpc_id(1, synced_node.test_sync_string + str(synced_node.test_sync_string.length()))


func _clear_string_pressed() -> void:
	if synced_node == null:
		print("NO NODE!")
		return
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		print("NOT CONNECTED!")
		return
	if multiplayer.is_server():
		# Add something to the string so I can see if it replicates
		synced_node.test_sync_string = ""
	else:
		synced_node.set_test_sync_string.rpc_id(1, "")


func _on_resource_pressed() -> void:
	if multiplayer.multiplayer_peer.get_unique_id() != 1:
		print("Not host!")
		return
	
	var resource: ResourceSync = ResourceSync.new()
	resource.my_array = [7, 7, 7]
	resource.my_string = "a synchronized string"
	set_resource.rpc(resource)
	

@rpc("call_local")
func set_resource(resource: ResourceSync) -> void:
	_resource_sync = resource
