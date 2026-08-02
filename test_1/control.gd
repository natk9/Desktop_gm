extends Control
class_name RippleGenerator

# 波纹参数
@export var ripple_strength := 0.5
@export var ripple_radius := 50.0
@export var ripple_falloff := 0.9

var ripple_image: Image
var ripple_image_prev: Image
var ripple_texture: ImageTexture

func _ready():
	# 创建波纹纹理（与屏幕同大）
	var viewport_size = get_viewport().size
	ripple_image = Image.create(viewport_size.x, viewport_size.y, false, Image.FORMAT_RF)
	ripple_image_prev = Image.create(viewport_size.x, viewport_size.y, false, Image.FORMAT_RF)
	ripple_texture = ImageTexture.create_from_image(ripple_image)
	
	# 初始化为黑色（无波纹）
	ripple_image.fill(Color.BLACK)
	ripple_image_prev.fill(Color.BLACK)
	ripple_texture.update(ripple_image)

func _process(delta):
	update_ripples(delta)

func create_ripple(position: Vector2, strength: float = 1.0):
	# 在指定位置创建波纹
	var radius = ripple_radius * strength
	var center_x = int(position.x)
	var center_y = int(position.y)
	
	for y in range(-radius, radius):
		for x in range(-radius, radius):
			var dist = sqrt(x*x + y*y)
			if dist <= radius:
				var ix = center_x + x
				var iy = center_y + y
				
				# 边界检查
				if ix >= 0 and ix < ripple_image.get_width() and iy >= 0 and iy < ripple_image.get_height():
					# 计算波纹强度（高斯衰减）
					var intensity = exp(-dist * dist / (radius * radius * 0.5))
					intensity *= ripple_strength * strength
					
					# 设置波纹值
					ripple_image.set_pixel(ix, iy, Color(intensity, 0, 0))

func update_ripples(delta: float):
	# 波纹物理模拟（简化版）
	var temp = ripple_image_prev
	ripple_image_prev = ripple_image
	ripple_image = temp
	
	# 应用波动方程（简化）
	for y in range(1, ripple_image.get_height() - 1):
		for x in range(1, ripple_image.get_width() - 1):
			# 获取周围像素的波纹值
			var left = ripple_image_prev.get_pixel(x-1, y).r
			var right = ripple_image_prev.get_pixel(x+1, y).r
			var top = ripple_image_prev.get_pixel(x, y-1).r
			var bottom = ripple_image_prev.get_pixel(x, y+1).r
			
			# 简单波动传播
			var new_value = (left + right + top + bottom) / 2.0
			new_value -= ripple_image.get_pixel(x, y).r
			new_value *= ripple_falloff  # 阻尼衰减
			
			ripple_image.set_pixel(x, y, Color(new_value, 0, 0))
	
	# 更新纹理
	ripple_texture.update(ripple_image)

func get_ripple_texture() -> Texture2D:
	return ripple_texture
