#include "ray.glsl"
#include "material.glsl"
#include "../common.glsl"

struct hit_record 
{
    vec3 p;
    vec3 normal;
    float t;
    bool front_face;
    material mat;
};

void set_face_normal(inout hit_record rec, const ray r, const vec3 outward_normal) {
    // Sets the hit record normal vector.
    // NOTE: the parameter `outward_normal` is assumed to have unit length.

    rec.front_face = dot(r.direction, outward_normal) < 0.0;
    rec.normal = rec.front_face ? outward_normal : -outward_normal;
}

bool material_scatter(in material m, in ray r_in, inout hit_record rec, out vec3 attenuation, out ray scattered)
{
    switch (m.type) {
    case MATERIAL_LAMBERT:
        vec3 scatter_direction = normalize(rec.normal + random_unit_vector(g_seed));

        // Catch degenerate scatter direction
        if (near_zero(scatter_direction)) {
            scatter_direction = rec.normal;
        }

        scattered = ray(rec.p, scatter_direction);
        attenuation = m.albedo;
        return true;
    
    case MATERIAL_METAL:
        vec3 reflected = normalize(reflect(r_in.direction, rec.normal));
        reflected = reflected + (m.fuzz * random_unit_vector(g_seed));
        scattered = ray(rec.p, reflected);
        attenuation = m.albedo;
        return dot(scattered.direction, rec.normal) > 0.0;

    case MATERIAL_DIELECTRIC:
        attenuation = vec3(1.0);
        float ri = rec.front_face ? (1.0 / m.fuzz) : m.fuzz;

        vec3 unit_direction = normalize(r_in.direction);

        float cos_theta = min(dot(-unit_direction, rec.normal), 1.0);
        float sin_theta = sqrt(1.0 - cos_theta * cos_theta);

        bool cannot_refract = ri * sin_theta > 1.0;
        vec3 direction;

        if (cannot_refract || reflectance(cos_theta, ri) > rand1(g_seed))
            direction = reflect(unit_direction, rec.normal);
        else
            direction = refract(unit_direction, rec.normal, ri);

        scattered = ray(rec.p, direction);
        return true;
    }

    return false;
}
