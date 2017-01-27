// Namespaced Header

#ifndef __NS_SYMBOL
// We need to have multiple levels of macros here so that __NAMESPACE_PREFIX_ is
// properly replaced by the time we concatenate the namespace prefix.
#define __NS_REWRITE(ns, symbol) ns ## _ ## symbol
#define __NS_BRIDGE(ns, symbol) __NS_REWRITE(ns, symbol)
#define __NS_SYMBOL(symbol) __NS_BRIDGE(SBB, symbol)
#endif


// Classes
#ifndef ZZAESDecryptInputStream
#define ZZAESDecryptInputStream __NS_SYMBOL(ZZAESDecryptInputStream)
#endif

#ifndef ZZArchive
#define ZZArchive __NS_SYMBOL(ZZArchive)
#endif

#ifndef ZZArchiveEntry
#define ZZArchiveEntry __NS_SYMBOL(ZZArchiveEntry)
#endif

#ifndef ZZDataChannel
#define ZZDataChannel __NS_SYMBOL(ZZDataChannel)
#endif

#ifndef ZZDataChannelOutput
#define ZZDataChannelOutput __NS_SYMBOL(ZZDataChannelOutput)
#endif

#ifndef ZZDeflateOutputStream
#define ZZDeflateOutputStream __NS_SYMBOL(ZZDeflateOutputStream)
#endif

#ifndef ZZFileChannel
#define ZZFileChannel __NS_SYMBOL(ZZFileChannel)
#endif

#ifndef ZZFileChannelOutput
#define ZZFileChannelOutput __NS_SYMBOL(ZZFileChannelOutput)
#endif

#ifndef ZZInflateInputStream
#define ZZInflateInputStream __NS_SYMBOL(ZZInflateInputStream)
#endif

#ifndef ZZNewArchiveEntry
#define ZZNewArchiveEntry __NS_SYMBOL(ZZNewArchiveEntry)
#endif

#ifndef ZZNewArchiveEntryWriter
#define ZZNewArchiveEntryWriter __NS_SYMBOL(ZZNewArchiveEntryWriter)
#endif

#ifndef ZZOldArchiveEntry
#define ZZOldArchiveEntry __NS_SYMBOL(ZZOldArchiveEntry)
#endif

#ifndef ZZOldArchiveEntryWriter
#define ZZOldArchiveEntryWriter __NS_SYMBOL(ZZOldArchiveEntryWriter)
#endif

#ifndef ZZStandardDecryptInputStream
#define ZZStandardDecryptInputStream __NS_SYMBOL(ZZStandardDecryptInputStream)
#endif

#ifndef ZZStoreOutputStream
#define ZZStoreOutputStream __NS_SYMBOL(ZZStoreOutputStream)
#endif

// Functions
#ifndef ZZGeneralPurposeBitFlag
#define ZZGeneralPurposeBitFlag __NS_SYMBOL(ZZGeneralPurposeBitFlag)
#endif

#ifndef ZZCentralFileHeader
#define ZZCentralFileHeader __NS_SYMBOL(ZZCentralFileHeader)
#endif

#ifndef ZZLocalFileHeader
#define ZZLocalFileHeader __NS_SYMBOL(ZZLocalFileHeader)
#endif

#ifndef ZZStandardCryptoEngine
#define ZZStandardCryptoEngine __NS_SYMBOL(ZZStandardCryptoEngine)
#endif

#ifndef getSaltLength
#define getSaltLength __NS_SYMBOL(getSaltLength)
#endif

#ifndef getKeyLength
#define getKeyLength __NS_SYMBOL(getKeyLength)
#endif

#ifndef getMacLength
#define getMacLength __NS_SYMBOL(getMacLength)
#endif

#ifndef ZZScopeGuard
#define ZZScopeGuard __NS_SYMBOL(ZZScopeGuard)
#endif

#ifndef ZZDataProvider
#define ZZDataProvider __NS_SYMBOL(ZZDataProvider)
#endif

#ifndef ZZExtraField
#define ZZExtraField __NS_SYMBOL(ZZExtraField)
#endif

// Externs
#ifndef ZZChannelOutput
#define ZZChannelOutput __NS_SYMBOL(ZZChannelOutput)
#endif

#ifndef ZZChannel
#define ZZChannel __NS_SYMBOL(ZZChannel)
#endif

#ifndef ZZArchiveEntryWriter
#define ZZArchiveEntryWriter __NS_SYMBOL(ZZArchiveEntryWriter)
#endif

#ifndef ZipZapVersionString
#define ZipZapVersionString __NS_SYMBOL(ZipZapVersionString)
#endif

#ifndef ZipZapVersionNumber
#define ZipZapVersionNumber __NS_SYMBOL(ZipZapVersionNumber)
#endif

#ifndef ZZOpenOptionsCreateIfMissingKey
#define ZZOpenOptionsCreateIfMissingKey __NS_SYMBOL(ZZOpenOptionsCreateIfMissingKey)
#endif

#ifndef ZZErrorDomain
#define ZZErrorDomain __NS_SYMBOL(ZZErrorDomain)
#endif

#ifndef ZZEntryIndexKey
#define ZZEntryIndexKey __NS_SYMBOL(ZZEntryIndexKey)
#endif

