// procedural_rain_system.gdshader
shader_type canvas_item;

// ⭐ 雨滴池系统参数
#define MAX_DROPS 20

// 雨滴属性
uniform float drop_strength = 0.007;
uniform float min_speed = 1.5;
uniform float max_speed = 2.5;
uniform float drop_radius = 0.1;

// ⭐ 雨滴生成控制
uniform float rain_intensity : hint_range(0.0, 1.0) = 0.7;  // 雨量强度
uniform float spawn_rate = 2.0;  // 每秒生成几个雨滴

// 时间控制
uniform float global_time_scale = 1.0;

// 随机种子
uniform float seed = 13579.0;


// ⭐ 伪随机数生成函数
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// ⭐ 噪声函数（用于自然变化）
float noise(vec2 p) {
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u * u * (3.0 - 2.0 * u);
    
    float res = mix(
        mix(random(ip), random(ip + vec2(1.0, 0.0)), u.x),
        mix(random(ip + vec2(0.0, 1.0)), random(ip + vec2(1.0, 1.0)), u.x),
        u.y
    );
    return res;
}

void fragment() {
	
    vec2 uv = UV;
    float current_time = TIME * global_time_scale;
    vec2 total_offset = vec2(0.0);
    
    // ⭐ 计算可见雨滴数量（根据雨量强度）
    int visible_drops = int(float(MAX_DROPS) * rain_intensity);
    
    for(int i = 0; i < MAX_DROPS; i++) {
        if (i >= visible_drops) break;
        
        float fi = float(i);
        
        // ⭐ 生成确定性但看起来随机的雨滴模式
        vec2 drop_seed = vec2(fi * 0.618, seed);
        
        // 雨滴位置
        float rx = noise(drop_seed * 1.234);
        float ry = noise(drop_seed * 2.345);
        vec2 drop_center = vec2(rx, ry);
        
        // ⭐ 每个雨滴有不同的速度和开始时间
        float drop_speed = mix(min_speed, max_speed, noise(drop_seed * 3.456));
        float drop_start_offset = noise(drop_seed * 4.567) * 10.0;  // 时间偏移
        
        // 计算此雨滴的本地时间
        float drop_local_time = current_time + drop_start_offset;
        
        // ⭐ 脉冲式雨滴（模拟实际的雨滴下落间隔）
        float spawn_interval = 1.0 / spawn_rate;
        float drop_phase = mod(drop_local_time, spawn_interval * 5.0) / spawn_interval;
        
        // 只在下落阶段显示
        if (drop_phase > 1.0) continue;
        
        // 计算距离
        float dist = distance(uv, drop_center);
        
        // ⭐ 雨滴影响范围
        if (dist > drop_radius) continue;
        
        // ⭐ 计算涟漪波（带相位偏移）
        float normalized_dist = dist / drop_radius;
        float wave_phase = normalized_dist * 20.0 - drop_phase * drop_speed * 15.0;
        
        // ⭐ 复杂波形（多个频率叠加）
        float wave1 = sin(wave_phase);
        float wave2 = sin(wave_phase * 2.0 + 0.5) * 0.3;
        float wave3 = sin(wave_phase * 0.5 + 1.2) * 0.2;
        float combined_wave = (wave1 + wave2 + wave3) / 1.5;
        
        // ⭐ 形状衰减（中心强，边缘弱）
        float shape = 1.0 - smoothstep(0.0, drop_radius, dist);
        float attenuation = shape * shape * (3.0 - 2.0 * shape);
        
        // 计算法线
        vec2 normal = normalize(uv - drop_center);
        
        // 累加偏移（强度随雨量变化）
        total_offset += normal * combined_wave * attenuation * drop_strength * rain_intensity;
    }
    
    // ⭐ 添加背景微小波动
    float background_wave = sin(uv.x * 8.0 + current_time * 0.3) * 0.0005;
    background_wave += sin(uv.y * 6.0 + current_time * 0.4) * 0.0003;
    
    total_offset.x += background_wave;
    total_offset.y += background_wave * 0.7;
    
    // 应用扭曲
    uv += total_offset;
    
    // 采样纹理
    vec4 color = texture(TEXTURE, uv);
    
    // ⭐ 根据雨量调整颜色
    color.rgb = mix(color.rgb, vec3(0.5, 0.7, 0.9), rain_intensity * 0.2);
    
    // ⭐ 添加雨滴涟漪的高光
    float highlight = length(total_offset) * 20.0;
    color.rgb += vec3(0.1, 0.15, 0.2) * highlight;
    
    COLOR = color;
}