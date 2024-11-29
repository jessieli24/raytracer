#iChannel0 "file://self"

#include "hittable_list.glsl"

struct camera 
{
    float image_width;    // Rendered image width in pixel count
    float image_height;   // Rendered image height
    float aspect_ratio;   // Ratio of image width over height
    vec3  center;         // Camera center

    float vfov;           // Vertical view angle (field of view)
    vec3 lookfrom;        // Point camera is looking from
    vec3 lookat;          // Point camera is looking at
    vec3 vup;             // Camera-relative "up" direction
    vec3 u, v, w;         // Camera frame basis vectors

    float focal_length;
    float viewport_height;
    float viewport_width;

    vec3 pixel_delta_u;
    vec3 pixel_delta_v;
    vec3 pixel00_loc;

    float samples_per_pixel;
    float pixel_samples_scale;

    float defocus_angle;    // Variation angle of rays through each pixel
    float focus_dist;       // Distance from camera lookfrom point to plane of perfect focus
    vec3 defocus_disk_u;    // Defocus disk horizontal radius
    vec3 defocus_disk_v;    // Defocus disk vertical radius
};

void initialize(inout camera c) 
{
    c.image_width = iResolution.x;
    c.image_height = iResolution.y;
    c.aspect_ratio = iResolution.x / iResolution.y; 

    c.vfov = 20.0;
    c.lookfrom = vec3(13.0, 2.0, 3.0);
    c.lookat = vec3(0.0);
    c.vup = vec3(0, 1.0, 0);

    c.defocus_angle = 0.6;
    c.focus_dist = 10.0;
    c.center = c.lookfrom;

    float theta = degrees_to_radians(c.vfov);
    float h = tan(theta / 2.0);
    c.viewport_height = 2.0 * h * c.focus_dist;
    c.viewport_width = c.viewport_height * c.aspect_ratio;

    // u,v,w unit basis vectors for the camera coordinate frame
    c.w = normalize(c.lookfrom - c.lookat);
    c.u = normalize(cross(c.vup, c.w));
    c.v = cross(c.w, c.u);

    vec3 viewport_u = c.viewport_width * c.u;   // viewport horizontal edge
    vec3 viewport_v = c.viewport_height * c.v;  // viewport vertical edge

    c.pixel_delta_u = viewport_u / c.image_width;
    c.pixel_delta_v = viewport_v / c.image_height;

    vec3 viewport_upper_left = c.center - (c.focus_dist * c.w) - viewport_u/2.0 - viewport_v/2.0;
    c.pixel00_loc = viewport_upper_left + 0.5 * (c.pixel_delta_u + c.pixel_delta_v);

    // camera defocus disk basis vectors
    float defocus_radius = c.focus_dist * tan(degrees_to_radians(c.defocus_angle / 2.0));
    c.defocus_disk_u = c.u * defocus_radius;
    c.defocus_disk_v = c.v * defocus_radius;

    c.samples_per_pixel = 100.0;
    c.pixel_samples_scale = 1.0 / c.samples_per_pixel;
}

vec3 defocus_disk_sample(camera c) 
{
    // random point in the camera defocus disk
    vec2 p = random_in_unit_disk(g_seed);
    return c.center + (p.x * c.defocus_disk_u) + (p.y * c.defocus_disk_v);
}

/*
 * Construct a camera ray originating from the origin and directed at randomly sampled
 * point around the pixel location i, j.
 */
ray get_ray(inout camera c, vec2 uv) 
{
    vec3 offset = sample_square(g_seed);

    // uv in image coordinates
    vec3 pixel_sample = c.pixel00_loc 
        + (uv.x + offset.x) * c.pixel_delta_u
        + (uv.y + offset.y) * c.pixel_delta_v;

    vec3 ray_origin = (c.defocus_angle <= 0.0) ? c.center : defocus_disk_sample(c);
    vec3 ray_direction = pixel_sample - ray_origin;

    return ray(ray_origin, ray_direction);
}

vec3 ray_color(ray r, const hittable_list world) 
{
    vec3 color = vec3(1.0);

    for (int i = 0; i < MAX_RECURSION; i++) {
        hit_record rec;
        
        bool hit = hittable_list_hit(world, r, interval(0.001, MAX_FLOAT), rec);

        if (hit) {
            ray scattered;
            vec3 attenuation;
            
            bool scatter = material_scatter(rec.mat, r, rec, attenuation, scattered);
            if (scatter) {
                color *= attenuation;  
                r = scattered;
                continue;
            } else {
                return vec3(0.0, 0.0, 0.0);
            }
        } 

        vec3 unit_direction = normalize(r.direction);
        float t = 0.5 * (unit_direction.y + 1.0);
        color *= (1.0 - t) * vec3(1.0, 1.0, 1.0) + t * vec3(0.5, 0.7, 1.0);
        return color;
    }

    return vec3(0.0);
}

vec4 render(camera c, const hittable_list world) 
{
    initialize(c);
    vec2 uv = gl_FragCoord.xy;

    init_rand(gl_FragCoord.xy, iTime);
    ray r = get_ray(c, uv);

    vec3 final_color = ray_color(r, world);
    return vec4(final_color, 1.0);
}
