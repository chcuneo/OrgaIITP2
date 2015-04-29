/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Funciones para transformar entre RGB y HSL                              */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"

// HSV = Hue, Saturation, Value
// HSL = Hue, Saturation, Lightness
// HSB = Hue, Saturation, Brightness

void rgbTOhsl(uint8_t *src, float *dst) {
  int r = (int)src[1];
  int g = (int)src[2];
  int b = (int)src[3];
  int cmax = max(b,g,r);
  int cmin = min(b,g,r);
  float d = (float)(cmax -cmin);
  float h,l,s;
  if ( cmax == cmin ) {
    h = 0.0f;
  } else if ( cmax == r ) {
    h = 60.0f*((float)(g-b)/d + 6.0f);
  } else if ( cmax == g ) {
    h = 60.0f*((float)(b-r)/d + 2.0f);
  } else if ( cmax == b ) {
    h = 60.0f*((float)(r-g)/d + 4.0f);
  }
  h = h>=360.0f ? h-360.0f : h;
  l = (float)(cmax+cmin)/510.0f;
  if ( cmax == cmin ) {
    s = 0.0f;
  } else {
    s = d/(1.0f-fabs(2.0f*l-1.0f))/255.0001f;
  }
  dst[0] = (float)src[0];
  dst[1] = h;
  dst[2] = s;
  dst[3] = l;
//  printf("1: %f 2: %f 3 : %f \n", dst[1], dst[2], dst[3]);

}

void hslTOrgb(float *src, uint8_t *dst) {
  float h = src[1];
  float s = src[2];
  float l = src[3];
  float c = (1.0f - fabs(2.0f*l-1.0f)) * s;
  float x = c * (1.0f - fabs( fmod(h/60.0f,2.0f) - 1.0f ) );
  float m = l - c/2.0f;
  float r,g,b;
  if( 0.0f<=h && h<60.0f ) {
    r=c;    b=x;    g=0.0f;
  } else if(  60.0f<=h && h<120.0f ) {
    r=x;    b=c;    g=0.0f;
  } else if( 120.0f<=h && h<180.0f ) {
    r=0.0f; b=c;    g=x;
  } else if( 180.0f<=h && h<240.0f ) {
    r=0.0f; b=x;    g=c;
  } else if( 240.0f<=h && h<300.0f ) {
    r=x;    b=0.0f; g=c;
  } else if( 300.0f<=h && h<360.0f ) {
    r=c;    b=0.0f; g=x;
  }
  dst[0]=(int)src[0];
  dst[1]=(r+m)*255.0f;
  dst[2]=(b+m)*255.0f;
  dst[3]=(g+m)*255.0f;
}

int max(int a, int b, int c) {
  if( a > b )
    if( a > c )
      return a; // a>b a>c
    else
      return c; // c>a>b 
  else
    if( b > c )
      return b; // b>a b>c
    else
      return c; // c>b>a
}

int min(int a, int b, int c) {
  if( a < b )
    if( a < c )
      return a; // a<b a<c
    else
      return c; // c<a<b
  else
    if( b < c )
      return b; // b<a b<c
    else
      return c; // c<b<a
}

void rgbTOhsl2(uint8_t *src, float *dst) {
  printf("sizeof(float): %i puntero: %p",sizeof(float), src);
  int i;
  for(i=0; i<3; i++){
    int r = (int)(src+1) [1];
    int g = (int)(src+1) [2];
    int b = (int)(src+1) [3];
    //printf("r: %i g: %i b: %i num: %i \n", r, g, b, i);
    int cmax = max(b,g,r);
    int cmin = min(b,g,r);
    float d = (float)(cmax -cmin);
    float h,l,s;
    if ( cmax == cmin ) {
      h = 0.0f;
    } else if ( cmax == r ) {
      h = 60.0f*((float)(g-b)/d + 6.0f);
    } else if ( cmax == g ) {
      h = 60.0f*((float)(b-r)/d + 2.0f);
    } else if ( cmax == b ) {
      h = 60.0f*((float)(r-g)/d + 4.0f);
    }
    h = h>=360.0f ? h-360.0f : h;
    l = (float)(cmax+cmin)/510.0f;
    if ( cmax == cmin ) {
      s = 0.0f;
    } else {
      s = d/(1.0f-fabs(2.0f*l-1.0f))/255.0001f;
    }
    (dst+i) [0] = (float)(src+i)[0];
    (dst+i) [1] = h;
    (dst+i) [2] = s;
    (dst+i) [3] = l;
  }
}

void hslTOrgb2(float *src, uint8_t *dst) {
  int i;
  for(i=0; i<3; i++){
    float h = (src+i) [1];
    float s = (src+i) [2];
    float l = (src+i) [3];
    float c = (1.0f - fabs(2.0f*l-1.0f)) * s;
    float x = c * (1.0f - fabs( fmod(h/60.0f,2.0f) - 1.0f ) );
    float m = l - c/2.0f;
    float r,g,b;
    if( 0.0f<=h && h<60.0f ) {
      r=c;    b=x;    g=0.0f;
    } else if(  60.0f<=h && h<120.0f ) {
      r=x;    b=c;    g=0.0f;
    } else if( 120.0f<=h && h<180.0f ) {
      r=0.0f; b=c;    g=x;
    } else if( 180.0f<=h && h<240.0f ) {
      r=0.0f; b=x;    g=c;
    } else if( 240.0f<=h && h<300.0f ) {
      r=x;    b=0.0f; g=c;
    } else if( 300.0f<=h && h<360.0f ) {
      r=c;    b=0.0f; g=x;
    }
    (dst+i) [0]=(int)(src+i) [0];
    (dst+i) [1]=(r+m)*255.0f;
    (dst+i) [2]=(b+m)*255.0f;
    (dst+i) [3]=(g+m)*255.0f;
    //printf("r: %i g: %i b: %i num: %i \n", (dst+i) [1], (dst+i) [2], (dst+i) [3], i);
  }
}