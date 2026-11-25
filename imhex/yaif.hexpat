#pragma author YAIF
#pragma description YAIF image (.yaif), see FORMAT.md
#pragma magic [ 89 59 41 49 46 0D 0A 1A 0A ] @ 0x00
#pragma endian big

#include <std/mem.pat>

// ImHex pattern for YAIF: signature, then chunks (type, length, data, CRC-32) until the end of the file.
// Chunk order differs from PNG: the TYPE comes first, then the length. FORMAT.md describes every field.

enum Flags : u8 {
    None = 0,
    Animated = 4,
    RawSensor = 8,
    AnimatedRaw = 12
};

// A coded region: level (0 palette, 1-4 predictive, 5 wavelet, 6 RAW) and a parameter, then the stream.
struct Region<auto Size> {
    u8 level;
    u8 param [[comment("levels 1-4: eps; level 5: quality (+128 = current steps)")]];
    u8 stream[Size - 2];
};

struct Ihdr {
    u32 width;
    u32 height;
    u8 bitsPerSample;
    u8 planes [[comment("3 RGB, 4 RGBA, 1 RAW")]];
    u8 version;
    Flags flags;
};

struct Anim {
    u32 frames;
    u16 delayMs;
    u16 loopCount [[comment("0 = forever")]];
};

struct Prev<auto Size> {
    u16 width;
    u16 height;
    u8 planes;
    Region<Size - 5> region;
};

struct Gmap<auto Size> {
    u16 width;
    u16 height;
    u8 planes;
    u16 isoLength;
    u8 iso[isoLength] [[comment("ISO 21496-1 metadata")]];
    Region<Size - 7 - isoLength> region;
};

struct Fdlt<auto Size> {
    u32 x0;
    u32 y0;
    u32 w;
    u32 h;
    if (w != 0 && h != 0) {
        Region<Size - 16> region;
    }
};

// kind: a PNG chunk type (eXIf, iCCP, tEXt...) or a JPEG segment (APP0-APPF, COM)
struct Mdat<auto Size> {
    char kind[4];
    u8 payload[Size - 4];
};

struct Chunk {
    char type[4];
    u32 length;
    if (type == "IHDR") {
        Ihdr data;
    } else if (type == "ANIM") {
        Anim data;
    } else if (type == "PREV") {
        Prev<length> data;
    } else if (type == "GMAP") {
        Gmap<length> data;
    } else if (type == "FDAT") {
        Region<length> data;
    } else if (type == "FDLT") {
        Fdlt<length> data;
    } else if (type == "MDAT") {
        Mdat<length> data;
    } else if (type == "RAWH") {
        u8 version;
        u8 params[length - 1];
    } else {
        // LIVE (the .mov file), IEND, or a type added later: readers skip what they do not know
        u8 data[length];
    }
    u32 crc [[comment("CRC-32 of type + data, not of length")]];
};

u8 signature[9] @ 0x00;
Chunk chunks[while(!std::mem::eof())] @ 0x09;
