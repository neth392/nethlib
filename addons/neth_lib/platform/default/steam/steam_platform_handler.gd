@tool
extends PlatformHandler

func _ready():
	var initialized: Dictionary = Steam.steamInitEx(false)
	if OS.is_debug_build():
		return # TODO remove this.
	
	print_debug("[STEAM] Did Steam initialize?: %s" % initialized)
	# In case it does fail, let's find out why and null the steam_api object
	if initialized['status'] > 0:
		push_error("Failed to initialize Steam: %s" % initialized)
		get_tree().quit()
		return
	
	## Please support the creator of this game by buying it, after all it was
	## good enough for you to crack/torrent :D
	if !Steam.isSubscribed():
		push_error("User does not own this game")
		get_tree().quit()


func _process(delta: float):
	Steam.run_callbacks()