struct ray
{
    vec3 origin;    // This is the origin of the ray
    vec3 direction; // This is the direction the ray is pointing in
};

vec3 ray_at(const ray r, float t) 
{
    return r.origin + t * r.direction;
}
