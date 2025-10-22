shader_type canvas_item;

uniform float speed_x = 0.001;
uniform float speed_y = 0.002;
uniform float scroll_offset = 0.0;

void vertex() {
    UV.x += speed_x * scroll_offset;
	UV.y += speed_y * scroll_offset;
}