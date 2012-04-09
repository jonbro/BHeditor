// a particle system.
// based on the love2d system
#pragma once

#include "ofVec2f.h"
#include "bludSpriteSheet.h"
#include "lua.hpp"


struct particle
{
    float lifetime;
    float life;
    
    float position[2];
    float direction;
    
    ofVec2f speed;
    float gravity;
    float radialAcceleration;
    float tangentialAcceleration;
    
    float size;
    float sizeStart;
    float sizeEnd;
    
    float rotation;
    float spinStart;
    float spinEnd;
    
    float color[4];
};


class ParticleSystem
{
public:
    static const char className[];
	static Lunar<ParticleSystem>::RegType methods[];

    // lua accessible functions
    ParticleSystem(lua_State *l);
    ~ParticleSystem();
    int draw(lua_State *l);
    int update(lua_State *l);
    int start(lua_State *l){ start(); return 1;};
    int stop(lua_State *l){ stop(); return 1;};
    int setEmissionRate(lua_State *l)
	{
		emissionRate = luaL_checknumber(l, 1); return 1;
	}
	int setLifetime(lua_State *l)
	{
		this->life = lifetime = luaL_checknumber(l, 1); return 1;
	}
    
	int setParticleLife(lua_State *l)
	{
        float min = luaL_checknumber(l, 1);
        float max = luaL_checknumber(l, 2);
		particleLifeMin = min;
		if(max == 0)
			particleLifeMax = min;
		else
			particleLifeMax = max;
        return 1;
	}
	int setPosition(lua_State *l)
	{
		position = ofVec2f(luaL_checknumber(l, 1), luaL_checknumber(l, 2));
        return 1;
	}
	int setDirection(lua_State *l)
	{
		this->direction = luaL_checknumber(l, 1);
        return 1;
	}
	int setSpread(lua_State *l)
	{
		this->spread = luaL_checknumber(l, 1);
        return 1;
	}
	int setRelativeDirection(lua_State *l)
	{
		this->relative = luaL_checknumber(l, 1);
        return 1;
	}
	int setSpeed(lua_State *l)
	{
        if (lua_isnumber(l, 2)) {
            this->speedMin = luaL_checknumber(l, 1);
            this->speedMax = luaL_checknumber(l, 2);
		}else{
            this->speedMin = this->speedMax = luaL_checknumber(l, 1);        
        }
        return 1;
	}
	int setGravity(lua_State *l)
	{
        if (lua_isnumber(l, 2)) {
            this->gravityMin = luaL_checknumber(l, 1);
            this->gravityMax = luaL_checknumber(l, 2);
		}else{
            this->gravityMin = this->gravityMax = luaL_checknumber(l, 1);        
        }
        return 1;
	}	
    int setSize(lua_State *l)
	{
        if (lua_isnumber(l, 3)) {
            this->sizeStart = luaL_checknumber(l, 1);
            this->sizeEnd = luaL_checknumber(l, 2);
            this->sizeVariation = luaL_checknumber(l, 2);
        }else if (lua_isnumber(l, 2)) {
            this->sizeStart = luaL_checknumber(l, 1);
            this->sizeEnd = luaL_checknumber(l, 2);
		}else{
            this->sizeEnd = this->sizeStart = luaL_checknumber(l, 1);
        }
        return 1;
	}
	int setSpin(lua_State *l)
	{
        if (lua_isnumber(l, 3)) {
            this->spinStart = luaL_checknumber(l, 1);
            this->spinEnd = luaL_checknumber(l, 2);
            this->spinVariation = luaL_checknumber(l, 2);
        }else if (lua_isnumber(l, 2)) {
            this->spinStart = luaL_checknumber(l, 1);
            this->spinEnd = luaL_checknumber(l, 2);
		}else{
            this->spinEnd = this->spinStart = luaL_checknumber(l, 1);
        }
        return 1;
	}
    int setRotation(lua_State *l)
	{
        rotationMin = luaL_checknumber(l, 1);
        rotationMax = luaL_checknumber(l, 2);
        return 1;
	}
    int setTangentialAcceleration(lua_State *l)
	{
        if (lua_isnumber(l, 2)) {
            this->tangentialAccelerationMin = luaL_checknumber(l, 1);
            this->tangentialAccelerationMax = luaL_checknumber(l, 2);
		}else{
            this->tangentialAccelerationMin = this->tangentialAccelerationMax = luaL_checknumber(l, 1);
        }
        return 1;
	}
	int setStartColor(lua_State *l)
	{
		int r = 255;
		if (lua_isnumber(l, 1)) {
			r = luaL_checknumber(l, 1);
		}
		int g = 255;
		if (lua_isnumber(l, 2)) {
			g = luaL_checknumber(l, 2);
		}
		int b = 255;
		if (lua_isnumber(l, 3)) {
			b = luaL_checknumber(l, 3);
		}
		int alpha = 255;
		if (lua_isnumber(l, 4)) {
			alpha = luaL_checknumber(l, 4);
		}
        colorStart[0] = r;
        colorStart[1] = g;
        colorStart[2] = b;
        colorStart[3] = alpha;
        return 1;
	}
    
	int setEndColor(lua_State *l)
	{
		int r = 255;
		if (lua_isnumber(l, 1)) {
			r = luaL_checknumber(l, 1);
		}
		int g = 255;
		if (lua_isnumber(l, 2)) {
			g = luaL_checknumber(l, 2);
		}
		int b = 255;
		if (lua_isnumber(l, 3)) {
			b = luaL_checknumber(l, 3);
		}
		int alpha = 255;
		if (lua_isnumber(l, 4)) {
			alpha = luaL_checknumber(l, 4);
		}
        colorEnd[0] = r;
        colorEnd[1] = g;
        colorEnd[2] = b;
        colorEnd[3] = alpha;
        return 1;
	}    
    // support functions
    void setBufferSize(unsigned int size);
    void start();
    void stop();
    bool isEmpty();
    bool isFull();
protected:
    
    // The max amount of particles.
    unsigned int bufferSize;
    
    // Pointer to the first particle.
    particle * pStart;
    
    // Pointer to the next available free space.
    particle * pLast;
    
    // Pointer to the end of the memory allocation.
    particle * pEnd;
    
    // The sprite to be drawn.
    bludSprite * sprite;
    bludSpriteSheet * sheet;
    // Whether the particle emitter is active.
    bool active;
    
    // The emission rate (particles/sec).
    int emissionRate;
    
    // Used to determine when a particle should be emitted.
    float emitCounter;
    
    // The relative position of the particle emitter.
    ofVec2f position;
    
    // The lifetime of the particle emitter (-1 means infinite) and the life it has left.
    float lifetime;
    float life;
    
    // The particle life.
    float particleLifeMin;
    float particleLifeMax;
    
    // The direction (and spread) the particles will be emitted in. Measured in radians.
    float direction;
    float spread;
    
    // Whether the direction should be relative to the emitter's movement.
    bool relative;
    
    // The speed.
    float speedMin;
    float speedMax;
    
    // Acceleration towards the bottom of the screen
    float gravityMin;
    float gravityMax;
    
    // Acceleration towards the emitter's center
    float radialAccelerationMin;
    float radialAccelerationMax;
    
    // Acceleration perpendicular to the particle's direction.
    float tangentialAccelerationMin;
    float tangentialAccelerationMax;
    
    // Size.
    float sizeStart;
    float sizeEnd;
    float sizeVariation;
    
    // Rotation
    float rotationMin;
    float rotationMax;
    
    // Spin.
    float spinStart;
    float spinEnd;
    float spinVariation;
    
    // Offsets
    float offsetX;
    float offsetY;
    
    // Color.
    unsigned char colorStart[4];
    unsigned char colorEnd[4];
    
    void add();
    void remove(particle * p);
    
};