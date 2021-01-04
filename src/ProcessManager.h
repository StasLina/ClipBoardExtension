#ifndef __PROCESSMANAGER_H__
#define __PROCESSMANAGER_H__

#include <types.h>
#include <string>
#include "IMemoryManager.h"

class WebSocketBase;

class ProcessManager {
#ifdef _WINDOWS
protected:
	static DWORD ParentProcessId(DWORD pid);
#endif //_WINDOWS
public:
	static std::wstring FindTestClient(int64_t port);
	static std::wstring GetProcessList(bool only1c);
	static std::wstring GetProcessInfo(int64_t pid);
	static std::wstring FindProcess(const std::wstring &name);
	static std::wstring OpenWebSocket(WebSocketBase** ws, const std::string& url);
	static std::wstring SendWebSocket(WebSocketBase** ws, const std::string& msg);
	static std::wstring WebSocket(const std::string& url, const std::string& msg);
	static bool ConsoleOut(const std::wstring& text, int64_t encoding);
	static void Sleep(int64_t interval);
	static int64_t ProcessId();
};

#endif //__PROCESSMANAGER_H__
