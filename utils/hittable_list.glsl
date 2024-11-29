#include "sphere.glsl"

#define MAX_LENGTH 50

struct hittable_list
{
    sphere objects[MAX_LENGTH];
    int count;
};

void hittable_list_clear(inout hittable_list h) 
{
    h.count = 0;
}

void hittable_list_add(inout hittable_list h, sphere object) 
{
    if (h.count < MAX_LENGTH) {
        h.objects[h.count] = object;
        h.count += 1;
    }
}

bool hittable_list_hit(const hittable_list h, const ray r, interval ray_t, inout hit_record rec) 
{
    hit_record temp_rec;
    bool hit_anything = false;
    float closest_so_far = ray_t.max;

    for (int i = 0; i < h.count; i++) {
        if (sphere_hit(h.objects[i], r, interval(ray_t.min, closest_so_far), temp_rec)) {
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec = temp_rec;
        }
    }

    return hit_anything;
}
