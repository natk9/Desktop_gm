# simple_water_ripple.gd
extends Sprite2D

# 噪声纹理参数
@export_category("噪声设置")
@export var noise_seed: int = 42
@export var noise_frequency: float = 0.03
@export var noise_octaves: int = 3
@export var texture_size: Vector2i = Vector2i(256, 256)

# 波纹参数
@export_category("波纹效果")
@export var ripple_strength: float = 0.01
@export var ripple_speed: float = 1.0
@export var ripple_frequency: float = 15.0

# 颜色参数
@export_category("颜色调整")
@export var water_color: Color = Color(0.7, 0.85, 1.0)
@export var color_strength: float = 0.15
@export var brightness: float = 1.0

# 私有变量
var noise_texture: NoiseTexture2D
var shader_material: ShaderMaterial

func _ready():
	setup_water_ripple()

func setup_water_ripple():
	# 1. 创建噪声纹理
	create_noise_texture()
	
	# 2. 创建着色器材质
	create_shader_material()
	
	# 3. 应用到自身
	material = shader_material

func create_noise_texture():
	noise_texture = NoiseTexture2D.new()
	var noise = FastNoiseLite.new()
	
	# 配置噪声
	noise.seed = noise_seed
	noise.frequency = noise_frequency
	noise.fractal_octaves = noise_octaves
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	# 配置纹理
	noise_texture.noise = noise
	noise_texture.width = texture_size.x
	noise_texture.height = texture_size.y
	
	print("噪声纹理创建完成: ", texture_size.x, "x", texture_size.y)

func create_shader_material():
	shader_material = ShaderMaterial.new()
	
	# 创建着色器代码
	var shader_code = """
    shader_type canvas_item;

    // 自动生成的参数
    uniform sampler2D noise_tex;
    uniform float ripple_strength = 0.01;
    uniform float ripple_speed = 1.0;
    uniform float ripple_frequency = 15.0;
    uniform vec3 water_color = vec3(0.7, 0.85, 1.0);
    uniform float color_strength = 0.15;
    uniform float brightness = 1.0;

    void fragment() {
        vec2 uv = UV;
        
        // 采样噪声纹理
        vec2 noise_uv = uv * 3.0;
        noise_uv.x += TIME * ripple_speed * 0.1;
        noise_uv.y += TIME * ripple_speed * 0.07;
        
        float noise = texture(noise_tex, noise_uv).r;
        
        // 创建基础波纹
        float wave = sin(uv.x * ripple_frequency + TIME * ripple_speed) * 0.5 + 0.5;
        
        // 混合噪声和波纹
        float combined = mix(noise, wave, 0.3);
        
        // 应用偏移
        vec2 offset = vec2(
            (combined - 0.5) * ripple_strength,
            sin(uv.y * 8.0 + TIME * 0.8) * ripple_strength * 0.3
        );
        
        // 采样原始纹理
        vec4 color = texture(TEXTURE, uv + offset);
        
        // 调整颜色
        color.rgb *= brightness;
        color.rgb = mix(color.rgb, water_color, color_strength * (1.0 - color.a));
        
        COLOR = color;
    }
    """
	
	# 创建着色器
	var shader = Shader.new()
	shader.code = shader_code
	shader_material.shader = shader
	
	# 设置参数
	update_shader_parameters()

func update_shader_parameters():
	if shader_material:
		# 连接噪声纹理
		shader_material.set_shader_parameter("noise_tex", noise_texture)
		
		# 传递参数
		shader_material.set_shader_parameter("ripple_strength", ripple_strength)
		shader_material.set_shader_parameter("ripple_speed", ripple_speed)
		shader_material.set_shader_parameter("ripple_frequency", ripple_frequency)
		shader_material.set_shader_parameter("water_color", water_color)
		shader_material.set_shader_parameter("color_strength", color_strength)
		shader_material.set_shader_parameter("brightness", brightness)

# 编辑器中的实时更新
func _process(delta):
	if Engine.is_editor_hint():
		update_shader_parameters()

# 重新生成噪声纹理
func regenerate_noise():
	if noise_texture:
		noise_texture.noise.seed = noise_seed
		noise_texture.noise.frequency = noise_frequency
		noise_texture.noise.fractal_octaves = noise_octaves
		noise_texture.update_now()

# 保存为独立资源
func save_as_resource(path: String = "res://water_material.tres"):
	if shader_material:
		ResourceSaver.save(shader_material, path)
		print("材质已保存到: ", path)

# 预设：平静水面
func apply_calm_preset():
	ripple_strength = 0.008
	ripple_speed = 0.5
	ripple_frequency = 12.0
	water_color = Color(0.8, 0.9, 1.0)
	color_strength = 0.1
	update_shader_parameters()

# 预设：流动河水
func apply_river_preset():
	ripple_strength = 0.015
	ripple_speed = 0.8
	ripple_frequency = 20.0
	water_color = Color(0.6, 0.8, 1.0)
	color_strength = 0.2
	update_shader_parameters()

# 预设：海浪
func apply_ocean_preset():
	ripple_strength = 0.02
	ripple_speed = 1.2
	ripple_frequency = 8.0
	water_color = Color(0.3, 0.5, 0.8)
	color_strength = 0.25
	noise_frequency = 0.01
	regenerate_noise()
	update_shader_parameters()
