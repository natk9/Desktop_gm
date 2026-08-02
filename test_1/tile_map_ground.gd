extends TileMapLayer


class_name WaterTileMap

@export_category("水波纹设置")
@export var enable_water_effect: bool = true:
	set(value):
		enable_water_effect = value
		update_effect()

@export_range(0.0, 1.0) var effect_intensity: float = 0.7:
	set(value):
		effect_intensity = value
		update_shader_parameters()

@export_range(0.1, 3.0) var wave_speed: float = 1.5:
	set(value):
		wave_speed = value
		update_shader_parameters()

@export_range(1, 10) var raindrop_count: int = 6:
	set(value):
		raindrop_count = value
		update_shader_parameters()

@export var water_color: Color = Color(0.6, 0.8, 1.0):
	set(value):
		water_color = value
		update_shader_parameters()

@export_category("性能设置")
@export var use_simple_shader: bool = false  # 低端设备使用简化版

var water_material: ShaderMaterial

func _ready():
	if enable_water_effect:
		setup_water_effect()

func setup_water_effect():
	water_material = ShaderMaterial.new()
	
	# 根据性能选择着色器
	if use_simple_shader:
		water_material.shader = create_simple_shader()
	else:
		water_material.shader = create_advanced_shader()
	
	# 应用到整个TileMap
	material = water_material
	
	# 初始化参数
	update_shader_parameters()
	
	print("🌊 水波纹效果已启用")

func create_simple_shader() -> Shader:
	var shader = Shader.new()
	shader.code = """
    shader_type canvas_item;
    uniform float intensity = 0.5;
    uniform float speed = 1.0;
    
    void fragment() {
        vec2 uv = UV;
        float wave = sin(uv.x * 10.0 + TIME * speed) * 0.003 * intensity;
        uv.x += wave;
        COLOR = texture(TEXTURE, uv);
    }
    """
	return shader

func create_advanced_shader() -> Shader:
	var shader = Shader.new()
	shader.code = """
    shader_type canvas_item;
    
    // 所有参数都通过uniform传递
    uniform float intensity = 0.7;
    uniform float speed = 1.5;
    uniform int drop_count = 6;
    uniform vec3 water_color = vec3(0.6, 0.8, 1.0);
    uniform float color_mix = 0.15;
    
    void fragment() {
        vec2 uv = UV;
        vec2 offset = vec2(0.0);
        
        // 基础波浪
        offset.x = sin(uv.x * 12.0 + TIME * speed) * 0.002 * intensity;
        offset.y = sin(uv.y * 8.0 + TIME * speed * 0.7) * 0.001 * intensity;
        
        // 雨滴涟漪
        for(int i = 0; i < drop_count; i++) {
            float fi = float(i);
            float rx = fract(sin(fi * 12.9898) * 43758.5453);
            float ry = fract(cos(fi * 78.233) * 43758.5453);
            vec2 center = vec2(rx, ry);
            
            float dist = distance(uv, center);
            float wave = sin(dist * 30.0 - TIME * speed * 1.8) * exp(-dist * 4.0);
            offset += normalize(uv - center) * wave * 0.004 * intensity;
        }
        
        uv += offset;
        
        vec4 color = texture(TEXTURE, uv);
        color.rgb = mix(color.rgb, water_color, color_mix);
        COLOR = color;
    }
    """
	return shader

func update_shader_parameters():
	if water_material:
		water_material.set_shader_parameter("intensity", effect_intensity)
		water_material.set_shader_parameter("speed", wave_speed)
		water_material.set_shader_parameter("drop_count", raindrop_count)
		water_material.set_shader_parameter("water_color", water_color)

func update_effect():
	if enable_water_effect:
		if not water_material:
			setup_water_effect()
	else:
		# 禁用效果
		material = null

# 方便的外部控制接口
func set_rain_intensity(intensity: float):
	effect_intensity = intensity

func set_storm_mode(enabled: bool):
	if enabled:
		effect_intensity = 0.9
		wave_speed = 2.5
		raindrop_count = 10
	else:
		effect_intensity = 0.5
		wave_speed = 1.2
		raindrop_count = 4

# 调试功能
func print_debug_info():
	print("=== TileMap水波纹信息 ===")
	print("当前材质:", material)
	print("强度:", effect_intensity)
	print("速度:", wave_speed)
	print("雨滴数量:", raindrop_count)
	print("图块总数:", get_used_cells(0).size())
