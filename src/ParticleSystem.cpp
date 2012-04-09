#include "ParticleSystem.h"
float calculate_variation(float inner, float outer, float var)
{
    float low = inner - (outer/2.0f)*var;
    float high = inner + (outer/2.0f)*var;
    float r = (rand() / (float(RAND_MAX)+1));
    return low*(1-r)+high*r;
}

ParticleSystem::ParticleSystem(lua_State *l) : pStart(0), pLast(0), pEnd(0), active(true), emissionRate(0),
emitCounter(0), lifetime(-1), life(0), particleLifeMin(0), particleLifeMax(0),
direction(0), spread(0), relative(false), speedMin(0), speedMax(0), gravityMin(0),
gravityMax(0), radialAccelerationMin(0), radialAccelerationMax(0),
tangentialAccelerationMin(0), tangentialAccelerationMax(0),
sizeStart(1), sizeEnd(1), sizeVariation(0), rotationMin(0), rotationMax(0),
spinStart(0), spinEnd(0), spinVariation(0){
    // setup the image and the particle buffers
    this->sprite = 	Lunar<bludSprite>::check(l, 1);
    this->sheet = Lunar<bludSpriteSheet>::check(l, 2);
    offsetX = sprite->ani.w*0.5f;
    offsetY = sprite->ani.h*0.5f;
    memset(colorStart, 255, 4);
    memset(colorEnd, 255, 4);
    setBufferSize(luaL_checknumber(l, 3));
};

ParticleSystem::~ParticleSystem()
{    
    if(pStart != 0)
        delete [] pStart;
};

void ParticleSystem::setBufferSize(unsigned int size){
    // delete previous data
    delete [] pStart;
    pLast = pStart = new particle[size];
    pEnd = pStart + size;    
}
void ParticleSystem::add()
{
    if(isFull()) return;
    
    float min,max;
    
    min = particleLifeMin;
    max = particleLifeMax;
    if(min == max)
        pLast->life = min;
    else
        pLast->life = (rand() / (float(RAND_MAX)+1)) * (max - min) + min;
    pLast->lifetime = pLast->life;
    
    pLast->position[0] = position.x;
    pLast->position[1] = position.y;
    
    min = direction - spread/2.0f;
    max = direction + spread/2.0f;
    pLast->direction = (rand() / (float(RAND_MAX)+1)) * (max - min) + min;
    
    min = speedMin;
    max = speedMax;
    float speed = (rand() / (float(RAND_MAX)+1)) * (max - min) + min;
    pLast->speed = ofVec2f(cos(pLast->direction), sin(pLast->direction));
    pLast->speed *= speed;
    
    min = gravityMin;
    max = gravityMax;
    pLast->gravity = (rand() / (float(RAND_MAX)+1)) * (max - min) + min;
    
    min = radialAccelerationMin;
    max = radialAccelerationMax;
    pLast->radialAcceleration = (rand() / (float(RAND_MAX)+1)) * (max - min) + min;
    
    min = tangentialAccelerationMin;
    max = tangentialAccelerationMax;
    pLast->tangentialAcceleration = (rand() / (float(RAND_MAX)+1)) * (max - min) + min;
    
    pLast->sizeStart = calculate_variation(sizeStart, sizeEnd, sizeVariation);
    pLast->sizeEnd = calculate_variation(sizeEnd, sizeStart, sizeVariation);
    pLast->size = pLast->sizeStart;
    
    min = rotationMin;
    max = rotationMax;
    pLast->spinStart = calculate_variation(spinStart, spinEnd, spinVariation);
    pLast->spinEnd = calculate_variation(spinEnd, spinStart, spinVariation);
    pLast->rotation = (rand() / (float(RAND_MAX)+1)) * (max - min) + min;;
    
    pLast->color[0] = (float)colorStart[0] / 255;
    pLast->color[1] = (float)colorStart[1] / 255;
    pLast->color[2] = (float)colorStart[2] / 255;
    pLast->color[3] = (float)colorStart[3] / 255;
    
    pLast++;
}

void ParticleSystem::remove(particle * p)
{
    if(!isEmpty())
    {
        *p = *(--pLast);
    }
}
bool ParticleSystem::isEmpty()
{
    return pStart == pLast;
}
bool ParticleSystem::isFull()
{
    return pLast == pEnd;
}

void ParticleSystem::start()
{
    active = true;
}
void ParticleSystem::stop()
{
    active = false;
    life = lifetime;
    emitCounter = 0;
}
int ParticleSystem::update(lua_State *l)
{
    float dt = luaL_checknumber(l, 1);
    // Traverse all particles and update.
    particle * p = pStart;
    
    // Make some more particles.
    if(active)
    {
        float rate = 1.0f / emissionRate; // the amount of time between each particle emit
        emitCounter += dt;
        while(emitCounter > rate)
        {
            add();
            emitCounter -= rate;
        }
        /*int particles = (int)(emissionRate * dt);
         for(int i = 0; i != particles; i++)
         add();*/
        
        life -= dt;
        if(lifetime != -1 && life < 0)
            stop();
    }
    
    while(p != pLast)
    {
        // Decrease lifespan.
        p->life -= dt;
        
        if(p->life > 0)
        {
            
            // Temp variables.
            ofVec2f radial, tangential, gravity(0, p->gravity);
            ofVec2f ppos(p->position[0], p->position[1]);
            
            // Get vector from particle center to particle.
            radial = ppos - position;
            radial.normalize();
            tangential = radial;
            
            // Resize radial acceleration.
            radial *= p->radialAcceleration;
            
            // Calculate tangential acceleration.
            {
                float a = tangential.x;
                tangential.x = -tangential.y;
                tangential.y = a;
            }
            
            // Resize tangential.
            tangential *= p->tangentialAcceleration;
            
            // Update position.
            p->speed += (radial+tangential+gravity)*dt;
            
            // Modify position.
            ppos += p->speed * dt;
            
            p->position[0] = ppos.x;
            p->position[1] = ppos.y;
            
            const float t = p->life / p->lifetime;
            
            // Change size.
            p->size = p->sizeEnd - ((p->sizeEnd - p->sizeStart) * t);
            
            // Rotate.
            p->rotation += (p->spinStart*(1-t) + p->spinEnd*t)*dt;
            
            // Update color.
            p->color[0] = (float)(colorEnd[0]*(1.0f-t) + colorStart[0] * t)/255.0f;
            p->color[1] = (float)(colorEnd[1]*(1.0f-t) + colorStart[1] * t)/255.0f;
            p->color[2] = (float)(colorEnd[2]*(1.0f-t) + colorStart[2] * t)/255.0f;
            p->color[3] = (float)(colorEnd[3]*(1.0f-t) + colorStart[3] * t)/255.0f;
            
            // Next particle.
            p++;
        }
        else
        {
            remove(p);
            
            if(p >= pLast)
                return 0;
        } // else
    } // while
    return 1;
}
int ParticleSystem::draw(lua_State *l){
    int scrollx = 0;
    if (lua_isnumber(l, 1)) {
        scrollx = luaL_checknumber(l, 1);
    }
    int scrolly = 0;
    if (lua_isnumber(l, 2)) {
        scrolly = luaL_checknumber(l, 2);
    }
    float zoom = 0;
    if (lua_isnumber(l, 3)) {
        zoom = luaL_checknumber(l, 3)-1;
    }
    
    particle * p = pStart;
    while(p != pLast)
    {
        // translate the positions based on the camera
        int x = (p->position[0] - (scrollx*1) - 0)*(1+zoom*1) + 0;
        int y = (p->position[1] - (scrolly*1) - 0)*(1+zoom*1) + 0;
        // eventually will need to translate these positions based on the camera
        sheet->spriteRenderer->addCenterRotatedTile(&sprite->ani, x, y, 2, 1, F_NONE, p->size*(1+zoom), ofRadToDeg(p->rotation), p->color[0]*255.0,p->color[1]*255.0,p->color[2]*255.0,p->color[3]*255.0);
        p++;
    }

    return 1;
}
const char ParticleSystem::className[] = "ParticleSystem";

Lunar<ParticleSystem>::RegType ParticleSystem::methods[] = {
	method(ParticleSystem, update),
	method(ParticleSystem, draw),
    method(ParticleSystem, start),
    method(ParticleSystem, stop),
    
    method(ParticleSystem, setEmissionRate),
    method(ParticleSystem, setLifetime),
    method(ParticleSystem, setParticleLife),
    method(ParticleSystem, setPosition),
    method(ParticleSystem, setDirection),
    method(ParticleSystem, setSpread),
    method(ParticleSystem, setRelativeDirection),
    method(ParticleSystem, setSpeed),
    method(ParticleSystem, setGravity),
    method(ParticleSystem, setSpin),
    method(ParticleSystem, setSize),
    method(ParticleSystem, setRotation),
    method(ParticleSystem, setTangentialAcceleration),

    method(ParticleSystem, setStartColor),
    method(ParticleSystem, setEndColor),
    
	{0,0}
};
