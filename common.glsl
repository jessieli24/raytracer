/*
 * Ray Tracing in One Weekend basecode for Dartmouth CS 77/177
 * by Wojciech Jarosz, 2019
 * 
 * Updated by Jessie Li, Fall 2024 with:
 *      degrees_to_radians
 *      sample_square
 *      random_unit_vector, random_on_hemisphere
 *      linear_to_gamma
 *      near_zero
 */

#define EPSILON 1e-3
#define MAX_FLOAT 3.402823466e+38
#define MAX_RECURSION 10
#define PI 3.1415926535897932384626433832795

//
// Hash functions by Nimitz:
// https://www.shadertoy.com/view/Xt3cDn
//

float g_seed = 0.;

uint base_hash(uvec2 p)
{
    p = 1103515245U * ((p >> 1U) ^ (p.yx));
    uint h32 = 1103515245U * ((p.x) ^ (p.y >> 3U));
    return h32 ^ (h32 >> 16);
}

void init_rand(in vec2 frag_coord, in float time)
{
    g_seed = float(base_hash(floatBitsToUint(frag_coord))) / float(0xffffffffU) + time;
}

float rand1(inout float seed)
{
    uint n = base_hash(floatBitsToUint(vec2(seed += .1, seed += .1)));
    return float(n) / float(0xffffffffU);
}

vec2 rand2(inout float seed)
{
    uint n = base_hash(floatBitsToUint(vec2(seed += .1, seed += .1)));
    uvec2 rz = uvec2(n, n * 48271U);
    return vec2(rz.xy & uvec2(0x7fffffffU)) / float(0x7fffffff);
}

vec3 rand3(inout float seed)
{
    uint n = base_hash(floatBitsToUint(vec2(seed += .1, seed += .1)));
    uvec3 rz = uvec3(n, n * 16807U, n * 48271U);
    return vec3(rz & uvec3(0x7fffffffU)) / float(0x7fffffff);
}

vec2 random_in_unit_disk(inout float seed)
{
    vec2 h = rand2(seed) * vec2(1., 6.28318530718);
    float phi = h.y;
    float r = sqrt(h.x);
    return r * vec2(sin(phi), cos(phi));
}

vec3 random_in_unit_sphere(inout float seed)
{
    vec3 h = rand3(seed) * vec3(2., 6.28318530718, 1.) - vec3(1, 0, 0);
    float phi = h.y;
    float r = pow(h.z, 1. / 3.);
    return r * vec3(sqrt(1. - h.x * h.x) * vec2(sin(phi), cos(phi)), h.x);
}

float degrees_to_radians(float degrees) {
    return degrees * PI / 180.0;
}

/*
 * Returns the vector to a random point in the [-.5,-.5]-[+.5,+.5] unit square.
 */
vec3 sample_square(inout float seed) {
    vec2 random_vector = rand2(seed) - 0.5;
    return vec3(random_vector, 0);
}

vec3 random_unit_vector(inout float seed)
{
    return normalize(random_in_unit_sphere(seed));
}

vec3 random_on_hemisphere(inout float seed, const vec3 normal)
{
    vec3 on_unit_sphere = random_unit_vector(seed);
    
    if (dot(on_unit_sphere, normal) > 0.0) // In the same hemisphere as the normal
        return on_unit_sphere;
    
    return -on_unit_sphere;
}

vec3 linear_to_gamma(vec3 linear_vector)
{
    return pow(max(linear_vector, 0.0), vec3(1.0/2.2));
}

bool near_zero(vec3 v) 
{
    // Return true if the vector is close to zero in all dimensions.
    float s = 1e-8;
    return (abs(v.x) < s) && (abs(v.y) < s) && (abs(v.z) < s);
}
