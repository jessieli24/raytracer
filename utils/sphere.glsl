#include "hittable.glsl"
#include "interval.glsl"

struct sphere 
{
    vec3 center;
    float radius;
    material mat;
};

float hit_sphere(vec3 center, float radius, const ray r) 
{
    vec3 oc = center - r.origin;
    float a = dot(r.direction, r.direction);
    float h = dot(r.direction, oc);
    float b = -2.0 * dot(r.direction, oc);
    float c = dot(oc, oc) - radius * radius;
    float discriminant = h * h - a * c;

    if (discriminant < 0.0) {
        return -1.0;
    } 

    return h - sqrt(discriminant) / a;
}

bool sphere_hit(const sphere s, const ray r, interval ray_t, out hit_record rec) 
{
    vec3 oc = s.center - r.origin;
    float a = dot(r.direction, r.direction);
    float h = dot(r.direction, oc);
    float b = -2.0 * dot(r.direction, oc);
    float c = dot(oc, oc) - s.radius * s.radius;
    float discriminant = h * h - a * c;

    if (discriminant < 0.0) {
        return false;
    } 

    float sqrtd = sqrt(discriminant);

    // Find the nearest root that lies in the acceptable range.
    float root = (h - sqrtd) / a;
    if (!surrounds(ray_t, root)) {
        root = (h + sqrtd) / a;
        if (!surrounds(ray_t, root))
            return false;
    }

    rec.t = root;
    rec.p = ray_at(r, rec.t);
    vec3 outward_normal = (rec.p - s.center) / s.radius;
    set_face_normal(rec, r, outward_normal);
    rec.mat = s.mat;
    
    return true;
}
