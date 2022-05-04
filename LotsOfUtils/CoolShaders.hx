class CoolShaders {

    public static final WAVES = '
        varying vec2 vTexCoord;
        uniform sampler2D uImage0;
        uniform float uTime;
        void main()
        {
            float amplitude = 0.01;
            float speed = 0.003;
            float twirliness = 4.0;
        
            vec2 tc = vTexCoord;
            vec2 p = -1.0 + 2.0 * tc;
            float len = length(p);
            vec2 uv = tc + (p / len) * cos(len * twirliness - uTime * speed) * amplitude;
            vec3 col = texture2D(uImage0, uv).xyz;
            gl_FragColor = vec4(col, 1.0);
        }
    ';

}