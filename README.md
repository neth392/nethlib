## Proper Documentation is a TODO

### Current Status of Major Tools:
1. Attributes: Took a quick break from this, will resume in 1-2 weeks. Current plans:
	1. Get it working for singleplayer - ALMOST DONE
		0. Rework attribute applying logic to allow more control.
		1. Repair WrappedAttribute implementation. WORKING ON NOW.
		2. Further work on optimizations, currently @ 6.5ms/frame w/ 1,000 attributes & 1 effect each. Down from 13ms/frame originally.
	2. Write unit tests using GUT; this will ensure every feature is working as intended. Will post a "release" after this is done.
	3. Add multiplayer support; may not do so for a while, I am not working on MP game currently.
2. JSON Serialization: Mostly done, can be expanded upon in the future. Finishing up the final fixes
after an entire rewrite and moving it to it's own github repo, plan to publish it on Godot's assetlib.
