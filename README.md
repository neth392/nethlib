## Proper Documentation is a TODO

### Current Status of Major Tools:
1. Attributes: Took a quick break from this, will resume in 1-2 weeks. Current plans:
	1. Get it working for singleplayer - ALMOST DONE
		0. Rework attribute applying logic to allow more control.
		1. Repair WrappedAttribute implementation. WORKING ON NOW.
		2. Further work on optimizations, currently @ 6.5ms/frame w/ 1,000 attributes & 1 effect each. Down from 13ms/frame originally.
	2. Write unit tests using GUT; this will ensure every feature is working as intended. Will post a "release" after this is done.
	3. Add multiplayer support; may not do so for a while, I am not working on MP game currently.
2. JSON Serialization: Rewrote the entire codebase to make it much more efficient, there is a serializer for EVERY native type now.
Currently designing a UI that will integrate directly with the editor to allow configuring json serialization on a per-node basis, much like
how MultiplayerSynchronizer is set up, but instead of a seperate node it'll be stored in Object metadata.
