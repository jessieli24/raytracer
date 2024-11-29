#define MAX_FLOAT 3.402823466e+38

struct interval
{
    float min, max;
};

float size(interval i) 
{
    return i.max - i.min;
}

bool contains(interval i, float x)
{
    return i.min <= x && x <= i.max;
}

bool surrounds(interval i, float x) {
    return i.min < x && x < i.max;
}

float iclamp(interval i, float x)
{
    return x < i.min ? i.min : (x > i.max ? i.max : x);
}

const interval interval_empty = interval(+MAX_FLOAT, -MAX_FLOAT);
const interval interval_universe = interval(-MAX_FLOAT, +MAX_FLOAT);
