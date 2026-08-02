// 简化的屏幕空间波纹
shader_type canvas_item;

uniform float time_scale = 1.0;
uniform float wave_speed = 2.0;
uniform float wave_height = 0.01;

void fragment() {
    vec2 uv = UV;
    
    // 使用正弦波创建基础波纹
    float wave1 = sin(uv.x * 20.0 + TIME * wave_speed) * 0.005;
    float wave2 = sin(uv.y * 15.0 + TIME * wave_speed * 0.7) * 0.003;
    float wave3 = sin((uv.x + uv.y) * 25.0 + TIME * wave_speed * 1.3) * 0.004;
    
    uv += vec2(wave1 + wave3, wave2 + wave3) * wave_height;
    
    COLOR = texture(TEXTURE, uv);
}