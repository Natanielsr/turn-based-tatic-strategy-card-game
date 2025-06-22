shader_type canvas_item;

// Cor do outline para aliados (azul)
uniform vec4 ally_color : source_color = vec4(0.0, 0.5, 1.0, 1.0);
// Cor do outline para inimigos (vermelho)
uniform vec4 enemy_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

// Cor do outline
uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
// Largura do outline
uniform float outline_width : hint_range(0.0, 10.0) = 2.0;

uniform bool is_ally = true;

void fragment() {
    // Verifica os pixels vizinhos
    float alpha = 0.0;
    for (float x = -outline_width; x <= outline_width; x++) {
        for (float y = -outline_width; y <= outline_width; y++) {
            // Ignora o pixel central para evitar outline interno
            if (x != 0.0 || y != 0.0) {
                alpha += texture(TEXTURE, UV + vec2(x, y) * TEXTURE_PIXEL_SIZE).a;
            }
        }
    }

    // Cor original do pixel
    vec4 original_color = texture(TEXTURE, UV);

    // Se o pixel atual é transparente mas tem pixels opacos ao redor, aplica o outline
    if (original_color.a == 0.0 && alpha > 0.0) {
		 // Escolhe a cor baseado em is_ally
       if (is_ally) {
            COLOR = ally_color;
        } else {
            COLOR = enemy_color;
        }
    } else {
        COLOR = original_color;
    }
}