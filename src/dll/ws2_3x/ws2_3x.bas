#define fbc -dll -Wl "ws2_3x.dll.def" -i ..\..\ -x ..\..\..\bin\dll\ws2_3x.dll

#include "win\winsock2.bi"
#Include "win\ws2tcpip.bi"
#include "includes\win\winsock2_fix.bi"
#include "shared\helper.bas"

extern "windows-ms"
  UndefAllParams()
  #define P1 Family        as _In_  INT
  #define P2 pAddr         as _In_  PVOID
  #define P3 pStringBuf    as _Out_ PSTR
  #define P4 StringBufSize as _In_  size_t
  function fnInetNtopA alias "inet_ntop" (P1, P2, P3, P4) as PCSTR export
    dim ss as SOCKADDR_STORAGE
    dim s as ulong = StringBufSize
    
    ss.ss_family = Family
  
    select case Family
      case AF_INET
        cptr(SOCKADDR_IN  ptr, @ss)->sin_addr  = *cptr(IN_ADDR  ptr, pAddr)
      case AF_INET6:
        cptr(SOCKADDR_IN6 ptr, @ss)->sin6_addr = *cptr(IN6_ADDR ptr, pAddr)
      case else          
        return NULL
    end select
    
    '/* cannot direclty use &StringBufSize because of strict aliasing rules */
    return iif(WSAAddressToStringA(cast(any ptr,@ss), sizeof(ss), NULL, pStringBuf, @s)=0, pStringBuf, NULL)
  end function
  
  UndefAllParams()
  #define P1 Family        as _In_  INT
  #define P2 pAddr         as _In_  PVOID
  #define P3 pStringBuf    as _Out_ PWSTR
  #define P4 StringBufSize as _In_  size_t
  function InetNtopW(P1, P2, P3, P4) as PCWSTR export
    dim ss as SOCKADDR_STORAGE
    dim s as ulong = StringBufSize
    
    ss.ss_family = Family
  
    select case Family
      case AF_INET
        cptr(SOCKADDR_IN  ptr, @ss)->sin_addr  = *cptr(IN_ADDR  ptr, pAddr)
      case AF_INET6:
        cptr(SOCKADDR_IN6 ptr, @ss)->sin6_addr = *cptr(IN6_ADDR ptr, pAddr)
      case else          
        return NULL
    end select
    
    '/* cannot direclty use &StringBufSize because of strict aliasing rules */
    return iif(WSAAddressToStringW(cast(any ptr,@ss), sizeof(ss), NULL, pStringBuf, @s)=0, pStringBuf, NULL)
  end function
  
  UndefAllParams()
  #define P1 Family        as _In_  INT
  #define P2 pszAddrString as _In_  PCSTR
  #define P3 pAddrBuf      as _Out_ PVOID
  function fnInetPtonA alias "inet_pton"(P1, P2, P3) as INT export
    dim as sockaddr_storage ss
    dim as integer size = sizeof(ss)
    dim as zstring*(INET6_ADDRSTRLEN+1) src_copy
    
    src_copy = *pszAddrString  
  
    if WSAStringToAddressA(src_copy, Family, NULL, cast(sockaddr ptr,@ss), @size) = 0 then
      select case Family
      case AF_INET
        *cptr(in_addr ptr,pAddrBuf) = (cptr(sockaddr_in ptr,@ss))->sin_addr
        return 1
      case AF_INET6
        *cptr(in6_addr ptr,pAddrBuf) = (cptr(sockaddr_in6 ptr,@ss))->sin6_addr
        return 1
      end select
    end if  
    
    return 0
  end function
  
  UndefAllParams()
  #define P1 Family        as _In_  INT
  #define P2 pszAddrString as _In_  PCWSTR
  #define P3 pAddrBuf      as _Out_ PVOID
  function InetPtonW(P1, P2, P3) as INT export
    dim as sockaddr_storage ss
    dim as integer size = sizeof(ss)
    dim as wstring*(INET6_ADDRSTRLEN+1) src_copy
  
    src_copy = *pszAddrString  
  
    if WSAStringToAddressW(src_copy, Family, NULL, cast(sockaddr ptr,@ss), @size) = 0 then
      select case Family
      case AF_INET
        *cptr(in_addr ptr,pAddrBuf) = (cptr(sockaddr_in ptr,@ss))->sin_addr
        return 1
      case AF_INET6
        *cptr(in6_addr ptr,pAddrBuf) = (cptr(sockaddr_in6 ptr,@ss))->sin6_addr
        return 1
      end select
    end if  
    return 0
  end function
  
  UndefAllParams()
  #define P1 fdarray as _Inout_ WSAPOLLFD ptr
  #define P2 nfds    as _In_    ULONG
  #define P3 timeout as _In_    INT
  function WSAPoll(P1, P2, P3) as INT export
    DEBUG_MsgNotImpl()
    SetLastError(ERROR_OUT_OF_PAPER)
    return SOCKET_ERROR
  end function
end extern


'do we still need all this stuff below?
#if 0
  #include <stdlib.h>
  #include <string.h>
  #include <stdio.h>
  
  #include <winsock2.h>
  #include <ws2tcpip.h>
  
  
  int inet_pton(int af, const char *src, void *dst)
  {
    struct sockaddr_storage ss;
    int size = sizeof(ss);
    char src_copy[INET6_ADDRSTRLEN+1];
  
    ZeroMemory(&ss, sizeof(ss));
    /* stupid non-const API */
    strncpy (src_copy, src, INET6_ADDRSTRLEN+1);
    src_copy[INET6_ADDRSTRLEN] = 0;
  
    if (WSAStringToAddress(src_copy, af, NULL, (struct sockaddr *)&ss, &size) == 0) {
      switch(af) {
        case AF_INET:
      *(struct in_addr *)dst = ((struct sockaddr_in *)&ss)->sin_addr;
      return 1;
        case AF_INET6:
      *(struct in6_addr *)dst = ((struct sockaddr_in6 *)&ss)->sin6_addr;
      return 1;
      }
    }
    return 0;
  }
  
  const char *inet_ntop(int af, const void *src, char *dst, socklen_t size)
  {
    struct sockaddr_storage ss;
    unsigned long s = size;
  
    ZeroMemory(&ss, sizeof(ss));
    ss.ss_family = af;
  
    switch(af) {
      case AF_INET:
        ((struct sockaddr_in *)&ss)->sin_addr = *(struct in_addr *)src;
        break;
      case AF_INET6:
        ((struct sockaddr_in6 *)&ss)->sin6_addr = *(struct in6_addr *)src;
        break;
      default:
        return NULL;
    }
    /* cannot direclty use &size because of strict aliasing rules */
    return (WSAAddressToString((struct sockaddr *)&ss, sizeof(ss), NULL, dst, &s) == 0)?
            dst : NULL;
  }
  '???? whre this go??? omfg :P
  ''/* cannot direclty use &size because of strict aliasing rules */
  'return iif(WSAAddressToString(cast(any ptr,@ss), sizeof(ss), NULL, dst, @s) = 0 , dst , NULL )
#endif  

#include "shared\defaultmain.bas"