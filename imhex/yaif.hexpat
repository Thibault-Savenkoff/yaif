#pragma description YAIF image (Yet Another Image Format), see FORMAT.md
#pragma MIME image/x-yaif
#pragma magic [ 89 59 41 49 46 0D 0A 1A 0A ] @ 0x00
#pragma endian big

import std.mem;

// Like PNG, but the chunk TYPE comes first, then the length: type, length, data, CRC-32 (of type + data).

struct header_t {
    u8 highBitByte;
    char signature[4];
    char dosLineEnding[2];
    char dosEOF;
    char unixLineEnding;
};

enum Flags : u8 {
    None = 0,
    Animated = 4,
    RawSensor = 8,
    AnimatedRaw = 12
};

enum Level : u8 {
    Palette = 0,
    Predictive1 = 1,
    Predictive2 = 2,
    Predictive3 = 3,
    Predictive4 = 4,
    Wavelet = 5,
    RawSensorFrame = 6
};

// A coded region: level, parameter, then the arithmetic-coded stream.
struct region_t<auto Size> {
    Level level [[comment("0 palette, 1-4 predictive, 5 wavelet (lossy photos), 6 RAW sensor")]];
    u8 param [[comment("levels 1-4: eps (0 = lossless); level 5: quality, +128 = current steps")]];
    u8 stream[Size - 2];
};

struct ihdr_t {
    u32 width [[comment("1-65535")]];
    u32 height [[comment("1-65535")]];
    u8 bitsPerSample [[comment("8 image, 16 RAW sensor frame")]];
    u8 planes [[comment("3 RGB, 4 RGBA, 1 RAW CFA")]];
    u8 version [[comment("format version, 2")]];
    Flags flags;
};

struct anim_t {
    u32 frames [[comment("total number of frames")]];
    u16 delayMs;
    u16 loopCount [[comment("0 = forever")]];
};

struct prev_t<auto Size> {
    u16 width;
    u16 height;
    u8 planes;
    region_t<Size - 5> region;
};

struct gmap_t<auto Size> {
    u16 width;
    u16 height;
    u8 planes;
    u16 isoLength;
    u8 iso[isoLength] [[comment("ISO 21496-1 gain map metadata")]];
    region_t<Size - 7 - isoLength> region;
};

struct fdlt_t<auto Size> {
    u32 x0;
    u32 y0;
    u32 w;
    u32 h [[comment("w = h = 0: identical to the previous frame")]];
    if (w != 0 && h != 0) {
        region_t<Size - 16> region;
    }
};

// kind: a PNG chunk type (eXIf, iCCP, tEXt...) or a JPEG segment (APP0-APPF, COM)
struct mdat_t<auto Size> {
    char kind[4];
    u8 payload[Size - 4];
};

struct rawh_t<auto Size> {
    u8 version;
    u8 params[Size - 1] [[comment("LibRaw structures: CFA, black/white levels, matrices, white balance")]];
};

struct chunk_t {
    char type[4] [[color("17BECF")]];
    u32 length;

    #define IHDR_k "IHDR"
    #define MDAT_k "MDAT"
    #define ANIM_k "ANIM"
    #define PREV_k "PREV"
    #define GMAP_k "GMAP"
    #define FDAT_k "FDAT"
    #define FDLT_k "FDLT"
    #define RAWH_k "RAWH"
    #define LIVE_k "LIVE"

    if (type == IHDR_k) {
        ihdr_t ihdr [[comment("Image header")]];
    } else if (type == MDAT_k) {
        mdat_t<length> mdat [[comment("Metadata block (EXIF, ICC, XMP, ...)")]];
    } else if (type == ANIM_k) {
        anim_t anim [[comment("Animation control")]];
    } else if (type == PREV_k) {
        prev_t<length> prev [[comment("Thumbnail, long side 512 px")]];
    } else if (type == GMAP_k) {
        gmap_t<length> gmap [[comment("HDR gain map")]];
    } else if (type == FDAT_k) {
        region_t<length> fdat [[comment("First (or only) frame")]];
    } else if (type == FDLT_k) {
        fdlt_t<length> fdlt [[comment("Next animation frame: changed rectangle")]];
    } else if (type == RAWH_k) {
        rawh_t<length> rawh [[comment("RAW sensor parameters")]];
    } else if (type == LIVE_k) {
        u8 movie[length] [[comment("Live Photo video (.mov)")]];
    } else {
        u8 data[length];   // IEND (empty), or a type added later: readers skip what they do not know
    }

    u32 crc;
} [[name(chunkName(this))]];

fn chunkName(ref chunk_t chunk) {
    return chunk.type;
};

struct Yaif {
    header_t header [[comment("YAIF file signature"), name("Signature")]];
    chunk_t chunks[while(!std::mem::eof())] [[name("Chunks")]];
};

Yaif YAIF @ 0x00;
