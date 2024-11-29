#define MATERIAL_LAMBERT 0
#define MATERIAL_METAL 1
#define MATERIAL_DIELECTRIC 2

struct material 
{
    int type;
    vec3 albedo;
    float fuzz; // fuzz for metal, refraction index for dielectric
};

float reflectance(float cosine, float refraction_index) {
    // Use Schlick's approximation for reflectance.
    float r0 = (1.0 - refraction_index) / (1.0 + refraction_index);
    r0 = r0 * r0;
    return r0 + (1.0 - r0) * pow((1.0 - cosine), 5.0);
}
