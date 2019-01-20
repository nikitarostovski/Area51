vec2 CRTCurveUV(vec2 uv) {
    uv = uv * 2.0 - 1.0;
    vec2 offset = abs(uv.yx) / vec2(10, 10);
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5;
    return uv;
}

vec4 DrawVignette(vec4 color, vec2 uv) {
    float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
    vignette = clamp(pow(16.0 * vignette, 0.05), 0.0, 1.0);
    color *= vignette;
    return color;
}

void main() {
    vec4 col = texture2D(u_texture, v_tex_coord);
    
    vec2 pixel_pos = vec2(v_tex_coord.x * size.x, v_tex_coord.y * size.y);
    
    float ppx = pixel_pos.x;
    float ppy = pixel_pos.y;
    
    float pxm = mod(ppx, 3.0);
    float pym = mod(ppy, 3.0);
    
    
    float otherVerts = 0.75;
    
    if (pxm < 1.0) {
        col = vec4(col.r, col.g * otherVerts, col.b * otherVerts, col.a);
    } else if (pxm < 2.0) {
        col = vec4(col.r * otherVerts, col.g, col.b * otherVerts, col.a);
    } else if (pxm < 3.0) {
        col = vec4(col.r * otherVerts, col.g * otherVerts, col.b, col.a);
    }
    
    if (pym < 1.0) {
        float scanline = 0.7;
        col = vec4(col.r * scanline, col.g * scanline, col.b * scanline, col.a);
    }
    
    float brightness = 30.0;
    float contrast = 3.0;
    
    col += brightness / 255.0;
    col = col - contrast * (col - 1.0) * col *(col - 0.5);
    
    
    
    col = DrawVignette(col, v_tex_coord);
    vec2 crtUV = CRTCurveUV(v_tex_coord);
    if (crtUV.x < 0.0 || crtUV.x > 1.0 || crtUV.y < 0.0 || crtUV.y > 1.0) {
        col = vec4(0.0,0.0,0.0,1.0);
    }
    col.a = 1.0;
    
    gl_FragColor = col;
}