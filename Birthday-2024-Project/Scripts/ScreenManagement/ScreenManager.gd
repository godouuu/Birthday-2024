class_name ScreenManager
extends Node

@export var popupRoot : CanvasLayer
@export var fade_duration: float = 1.5

var lastScreen : String
var _screenStack : Array[Node]
#var tween = get_tree().create_tween()
#@onready var colorRect: ColorRect = $TransitionLayer/AnimationPlayer/ColorRect
@onready var transition = $TransitionLayer/AnimationPlayer
#@onready var shaderMaterial: ShaderMaterial = colorRect.material

func GoToScreen(screen : PackedScene, data : Dictionary, doTransition: bool):
	if(doTransition):
		transition.play("page_flip")
		await transition.animation_finished
	var newScreen = screen.instantiate()
	var screenLogic : ScreenLogic = newScreen as ScreenLogic
	
	if screenLogic.clearScreenStack:
		while _screenStack.size() > 0:
			_closeTopScreen()
	
	screenLogic.screenManager = self
	screenLogic.transitionData = data
	popupRoot.add_child(newScreen)
	_screenStack.push_back(newScreen)
	screenLogic.ScreenEnter.emit()
	#if(doTransition): 
		#transition.play("page_flip")
		#await transition.animation_finished

func IsTopScreen(screen : ScreenLogic) -> bool:
	var topScreen : ScreenLogic = _screenStack.back() as ScreenLogic
	return screen == topScreen
	
func CloseTopScreen(data : Dictionary):
	if _screenStack.size() == 1:
		printerr("ERROR: cannot close last screen")
		return
	_closeTopScreen()
	var topScreen : ScreenLogic = _screenStack.back() as ScreenLogic
	topScreen.transitionData = data
	topScreen.ScreenEnter.emit()

func ShowSettings():
	GoToScreen(load("res://MainScenes/settings_popup.tscn"), {}, false)

func ShowConfirmationPopup(title : String, body : String, confirm : String = "Confirm", cancel : String = "Cancel"):
	var popupParameters = {}
	popupParameters[ConfirmationPopupController.TITLE_KEY] = title
	popupParameters[ConfirmationPopupController.BODY_KEY] = body
	popupParameters[ConfirmationPopupController.CONFIRM_KEY] = confirm
	popupParameters[ConfirmationPopupController.CANCEL_KEY] = cancel
	GoToScreen(load("res://MainScenes/confirmation_popup.tscn"), popupParameters, false)

func _ready():	
	#shaderMaterial.set_shader_param("invert", true)
	#shaderMaterial.set_shader_param("progress", 0)
	#tween.tween_method(_set_progress, 0, 1, fade_duration)
	#tween.tween_property(colorRect, "visible", "hide", fade_duration)
	#tween.play()
	GoToScreen(load("res://MainScenes/splash_screen.tscn"), {}, true)

func _closeTopScreen():
	var oldScreen : Node = _screenStack.pop_back()
	var screenLogic : ScreenLogic = oldScreen as ScreenLogic
	screenLogic.ScreenExit.emit()
	lastScreen = oldScreen.name
	oldScreen.queue_free()

#func wipeTransition():
		#colorRect.show()
		#shaderMaterial.set_shader_param("invert", false)
		#shaderMaterial.set_shader_param("progress", 0)
		#tween.tween_method(_set_progress, 0, 1, fade_duration)
		#tween.play()
		#await tween.finished
	#
#func _set_progress(progress: float) -> void:
	#shaderMaterial.set_shader_param("progress", progress)
	
