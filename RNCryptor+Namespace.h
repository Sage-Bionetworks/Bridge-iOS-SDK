// Namespaced Header

#ifndef __NS_SYMBOL
// We need to have multiple levels of macros here so that __NAMESPACE_PREFIX_ is
// properly replaced by the time we concatenate the namespace prefix.
#define __NS_REWRITE(ns, symbol) ns ## _ ## symbol
#define __NS_BRIDGE(ns, symbol) __NS_REWRITE(ns, symbol)
#define __NS_SYMBOL(symbol) __NS_BRIDGE(SBB, symbol)
#endif


// Classes
#ifndef RNCryptor
#define RNCryptor __NS_SYMBOL(RNCryptor)
#endif

#ifndef RNCryptorEngine
#define RNCryptorEngine __NS_SYMBOL(RNCryptorEngine)
#endif

#ifndef RNDecryptor
#define RNDecryptor __NS_SYMBOL(RNDecryptor)
#endif

#ifndef RNEncryptor
#define RNEncryptor __NS_SYMBOL(RNEncryptor)
#endif

// Functions
// Externs
#ifndef kRNCryptorErrorDomain
#define kRNCryptorErrorDomain __NS_SYMBOL(kRNCryptorErrorDomain)
#endif

#ifndef kRNCryptorFileVersion
#define kRNCryptorFileVersion __NS_SYMBOL(kRNCryptorFileVersion)
#endif

