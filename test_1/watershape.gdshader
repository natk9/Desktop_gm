shader_type canvas_item;

uniform float threshold : hint_range(0.0, 1.0) = 0.5;
uniform float edge_width : hint_range(0.0, 0.2) = 0.01;

// 新增透明度控制参数
uniform float water_alpha : hint_range(0.0, 1.0) = 0.7; // 积水透明度
uniform float edge_alpha : hint_range(0.0, 1.0) = 1.0;  // 白色边缘透明度

uniform sampler2D flow_noise : repeat_enable;
uniform vec2 flow_dir = vec2(0.15, 0.0);
uniform float flow_speed = 0.9;
uniform float edge_wobble = 0.03;

void fragment() {
    // 静态水域轮廓（不动）
    float n_base = texture(TEXTURE, UV).r;

    // 流动噪波（只用来扰动阈值）
    vec2 flow_uv = fract(UV + flow_dir * TIME * flow_speed);
    float n_flow = texture(flow_noise, flow_uv).r;

    // 扰动阈值，而不是 mask
    float wobble = (n_flow - 0.5) * edge_wobble;

    float outer = step(threshold + wobble, n_base);
    float inner = step(threshold + edge_width + wobble, n_base);
    float edge  = outer - inner;

    // 使用新参数控制透明度
    vec4 water_color = vec4(0.0, 0.0, 0.0, water_alpha); // 积水
    vec4 edge_color  = vec4(1.0, 1.0, 1.0, edge_alpha);  // 白色边缘

    vec4 col = vec4(0.0);
    col += water_color * inner;
    col += edge_color  * edge;

    COLOR = col;
}