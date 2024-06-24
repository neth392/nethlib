## Executes [Platform] specific code after the platform is considered active.[br]
## The handler is only added as a child of the [PlatformManager] when the
## [PlatformDetector] deems the platform is active. So platform-specific code
## can safely be written here, and functions such as [method Node._ready] will
## only execute if the platform is active.
@tool
class_name PlatformHandler extends Node
