// Description: 
// By Sarah Dean
// Email: sdean12@sdean12.org
// WWW:   http://www.FreeOTFE.org/
//
// -----------------------------------------------------------------------------
//


#ifndef _FreeOTFECypherAES_ltc_H
#define _FreeOTFECypherAES_ltc_H   1

#include "FreeOTFEPlatform.h"

#ifdef FOTFE_PDA
#include <objbase.h>  // Required before iniguid.h
#endif
// initguid.h required to initialize DEFINE_GUIDs 
//  - MUST BE INCLUDED EXACTLY ONCE IN THE EXECUTABLE
#include <initguid.h>  

// =========================================================================
// Const definitions

// These values are in DECIMAL
#define DRIVER_CYPHER_IMPL_VERSION_MAJOR     03
#define DRIVER_CYPHER_IMPL_VERSION_MINOR     00
#define DRIVER_CYPHER_IMPL_VERSION_BUILD   0000

#define DRIVER_CYPHER_IMPL_VERSION  (                                      \
                         (DRIVER_CYPHER_IMPL_VERSION_MAJOR * 0x01000000) + \
                         (DRIVER_CYPHER_IMPL_VERSION_MINOR * 0x00010000) + \
                         (DRIVER_CYPHER_IMPL_VERSION_BUILD * 0x00000001)   \
                        )


#define CYPHERS_SUPPORTED   9

// NOTE: ASCII, not WCHAR
#define DRIVER_TITLE                 "AES (libtomcrypt library)"
DEFINE_GUID(DRIVER_GUID,         0x00000000L, 0x0000, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01);

// NOTE: ASCII, not WCHAR
#define DRIVER_CIPHER_TITLE_AES_128_CBC  "AES"
DEFINE_GUID(CIPHER_GUID_AES_128_CBC, 0x00000000L, 0x0000, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x02);

#define DRIVER_CIPHER_TITLE_AES_192_CBC  "AES"
DEFINE_GUID(CIPHER_GUID_AES_192_CBC, 0x00000000L, 0x0000, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x03);

#define DRIVER_CIPHER_TITLE_AES_256_CBC  "AES"
DEFINE_GUID(CIPHER_GUID_AES_256_CBC, 0x00000000L, 0x0000, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x04);

#define DRIVER_CIPHER_TITLE_AES_128_LRW  "AES"
DEFINE_GUID(CIPHER_GUID_AES_128_LRW, 0x00000000L, 0x0000, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x02);

#define DRIVER_CIPHER_TITLE_AES_192_LRW  "AES"
DEFINE_GUID(CIPHER_GUID_AES_192_LRW, 0x00000000L, 0x0000, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x03);

#define DRIVER_CIPHER_TITLE_AES_256_LRW  "AES"
DEFINE_GUID(CIPHER_GUID_AES_256_LRW, 0x00000000L, 0x0000, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x04);

#define DRIVER_CIPHER_TITLE_AES_128_XTS  "AES"
DEFINE_GUID(CIPHER_GUID_AES_128_XTS, 0x00000000L, 0x0000, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x02);

#define DRIVER_CIPHER_TITLE_AES_192_XTS  "AES"
DEFINE_GUID(CIPHER_GUID_AES_192_XTS, 0x00000000L, 0x0000, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03);

#define DRIVER_CIPHER_TITLE_AES_256_XTS  "AES"
DEFINE_GUID(CIPHER_GUID_AES_256_XTS, 0x00000000L, 0x0000, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x04);



// =========================================================================
// Various internal functions

NTSTATUS
InitLTCCypher(
    OUT  int *cipher
);

// =========================================================================

#endif

