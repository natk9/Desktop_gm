extends Node2D

@onready var subviewport = $WaterRippleViewport
@onready var ripple_display = $RippleDisplay
@onready var ripple_generator = $RippleGenerator

func _ready():
	# 等待一帧确保纹理就绪
	await get_tree().process_frame

	if material:
		material.set_shader_parameter("ripple_texture", ripple_generator.get_ripple_texture())
		
	#	 创建Godot内置的噪声纹理
	var noise_texture = NoiseTexture2D.new()

	# 选择噪声类型
	noise_texture.noise = FastNoiseLite.new()  # 或 SimplexNoise, GradientNoise

	# 配置噪声参数
	noise_texture.noise.seed = randi()  # 随机种子
	noise_texture.noise.frequency = 0.1  # 频率（值越小纹理越平滑）
	noise_texture.width = 512
	noise_texture.height = 512

	# 应用到着色器
	var material = $Sprite.material as ShaderMaterial
	material.set_shader_parameter("noise_tex", noise_texture)


func _input(event):
	# 鼠标/触摸交互创建波纹
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = event.position
		ripple_generator.create_ripple(mouse_pos, 1.0)
	
	if event is InputEventScreenTouch and event.pressed:
		var touch_pos = event.position
		ripple_generator.create_ripple(touch_pos, 0.7)

func _process(delta):
	# 更新波纹显示的大小匹配视口
	var viewport_size = get_viewport().size
	ripple_display.size = viewport_size
	subviewport.size = viewport_size
