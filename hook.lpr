{$mode delphi}

library hook;

uses
  Windows,
  Messages;

const
  WH_KEYBOARD_LL = 13;
  ALTKEY = 32;
  CTRLKEY = 0;
  WINKEYHELPER = 1;

type
  KBDLLHOOKSTRUCT = record
    vkCode: dword;
    scanCode: dword;
    flags: dword;
    time: dword;
    dwExtraInfo: int64;
  end;

  PKBDLLHOOKSTRUCT = ^KBDLLHOOKSTRUCT;

var
  HookHandle: Cardinal = 0;
  WindowHandle: Cardinal = 0;
  strict: boolean = false;
  enabled: boolean = false;

function KeyboardHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM):
 LRESULT; stdcall;
var
  p: PKBDLLHOOKSTRUCT;
begin
  p:=PKBDLLHOOKSTRUCT(lParam);
  //Strict will block all keys, non-strict will block some shortcuts
  if not(strict) then begin
    if (wParam = WM_KEYDOWN)
    or (wParam = WM_KEYUP)
    or (wParam = WM_SYSKEYDOWN)
    or (wParam = WM_SYSKEYUP) then begin
      if (p.vkCode = VK_F4) and (p.flags = ALTKEY) then begin //Alt+F4
        result:=1;
      end
      else if (p.vkCode = VK_ESCAPE) and (p.flags = ALTKEY) then begin //Alt+Esc
        result:=1;
      end
      else if (p.vkCode = VK_ESCAPE) and (p.flags = CTRLKEY) then begin //Ctrl+Esc
        result:=1;
      end
      else if (p.vkCode = VK_LWIN) and (p.flags = WINKEYHELPER) then begin //WinL
        result:=1;
      end
      else if (p.vkCode = VK_RWIN) and (p.flags = WINKEYHELPER) then begin //WinR
        result:=1;
      end
      else if (p.flags = ALTKEY) then begin //Alt
        result:=1;
      end
      else begin
        result:=CallNextHookEx(HookHandle, nCode, wParam, lParam);
      end;
    end;
  end
  else begin
    if (enabled) then begin
      result:=1;
    end
    else begin
      result:=CallNextHookEx(HookHandle, nCode, wParam, lParam);
    end;
  end;
end;

function InstallHook(Hwnd: Cardinal; strictParam: boolean): Boolean; stdcall;
begin
  Result := False;
  if HookHandle = 0 then begin
    HookHandle := SetWindowsHookEx(WH_KEYBOARD_LL, @KeyboardHookProc,
    HInstance, 0);
    WindowHandle := Hwnd;
    Result := TRUE;
  end;
  if (strictParam) then begin
    strict:=true;
    enabled:=false;
  end
  else begin
    strict:=false;
  end;
end;

function UninstallHook: Boolean; stdcall;
begin
  Result := UnhookWindowsHookEx(HookHandle);
  HookHandle := 0;
end;

function ControlHook(mode: boolean): Boolean; stdcall;
begin
  if (mode) then begin
    enabled:=true;
  end
  else begin
    enabled:=false;
  end;
  result:=true;
end;

exports
  InstallHook,
  UninstallHook,
  ControlHook;
end.
