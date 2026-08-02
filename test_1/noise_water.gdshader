shader_type canvas_item;

// 控制参数
uniform sampler2D ripple_texture;  // 波纹强度图（由交互生成）
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02;
uniform float ripple_speed : hint_range(0.0, 5.0) = 2.0;
uniform float ripple_dampen : hint_range(0.9, 1.0) = 0.995;

// 噪声纹理（用于自然波动）
uniform sampler2D noise_tex;
uniform float time_factor = 0.5;

void fragment() {
    // 获取当前UV
    vec2 uv = UV;
    
    // 从波纹纹理获取当前波纹强度
    vec4 ripple_data = texture(ripple_texture, uv);
    float ripple = ripple_data.r;  // R通道存储波纹强度
    
    // 添加基础噪声波动（可选，让水面有自然运动）
    vec2 noise_uv = uv + TIME * 0.1 * time_factor;
    float noise = texture(noise_tex, noise_uv).r * 0.01;
    
    // 计算扭曲偏移
    // 使用相邻像素计算梯度，模拟水波扩散
    float left = texture(ripple_texture, uv + vec2(-0.001, 0.0)).r;
    float right = texture(ripple_texture, uv + vec2(0.001, 0.0)).r;
    float top = texture(ripple_texture, uv + vec2(0.0, -0.001)).r;
    float bottom = texture(ripple_texture, uv + vec2(0.0, 0.001)).r;
    
    vec2 offset = vec2(left - right, top - bottom);
    
    // 应用扭曲
    uv += offset * distortion_strength + vec2(noise);
    
    // 从SubViewport获取颜色（关键步骤）
    COLOR = texture(TEXTURE, uv);
    
    // 可选：添加水色色调
    COLOR.rgb = mix(COLOR.rgb, vec3(0.3, 0.5, 0.8), 0.1);
}