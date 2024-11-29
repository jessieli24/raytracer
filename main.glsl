#iChannel1 "file://self"

#include "utils/camera.glsl"

void main()
{
    material ground_material = material(MATERIAL_LAMBERT, vec3(0.5), 0.0);

    hittable_list world;
    hittable_list_add(world, sphere(vec3(0.0, -1000.0, 0.0), 1000.0, ground_material));

    float quantity = 2.0;
    for (float a = -quantity; a < quantity; a++) {
        for (float b = -quantity; b < quantity; b++) {
            material sphere_material = material(MATERIAL_LAMBERT, vec3(0.5), 0.0);

            float choose_mat = rand1(g_seed);
            vec3 center = vec3(a + 0.9 * rand1(g_seed), 0.2, b + 0.9 * rand1(g_seed));

            if (distance(center, vec3(4.0, 0.2, 0.0)) > 0.9) {
                material sphere_material;

                if (choose_mat < 0.8) {
                    // diffuse
                    vec3 albedo = rand3(g_seed) * rand3(g_seed);
                    sphere_material = material(MATERIAL_LAMBERT, albedo, 0.0);

                } else if (choose_mat < 0.95) {
                    // metal
                    vec3 albedo = rand3(g_seed) * 0.5 + 0.5; // [0.5, 1]
                    float fuzz = rand1(g_seed) * 0.5;
                    sphere_material = material(MATERIAL_METAL, albedo, fuzz);

                } else {
                    // glass
                    sphere_material = material(MATERIAL_DIELECTRIC, vec3(0.0), 1.5);
                }

                hittable_list_add(world, sphere(center, 0.2, sphere_material));
            }
        }
    }

    material material1 = material(MATERIAL_DIELECTRIC, vec3(0.0), 1.5);
    hittable_list_add(world, sphere(vec3(0.0, 1.0, 0.0), 1.0, material1));

    material material2 = material(MATERIAL_LAMBERT, vec3(0.4, 0.2, 0.1), 0.0);
    hittable_list_add(world, sphere(vec3(-4.0, 1.0, 0.0), 1.0, material2));

    material material3 = material(MATERIAL_METAL, vec3(0.7, 0.6, 0.5), 0.0);
    hittable_list_add(world, sphere(vec3(4.0, 1.0, 0.0), 1.0, material3));

    camera cam;
    
    // color
    vec4 current_color = render(cam, world);
    vec3 new_color = linear_to_gamma(current_color.xyz);

    vec2 uv_texel = gl_FragCoord.xy / iResolution.xy;
    vec3 previous_color = texture(iChannel1, uv_texel).rgb;

    float frames = float(iFrame);
    vec3 average_color = (new_color + previous_color * (frames - 1.0)) / (iFrame > 0 ? frames : 1.0);

    gl_FragColor = vec4(average_color, 1.0);
}
