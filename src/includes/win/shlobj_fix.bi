#undef KNOWN_FOLDER_FLAG

type KNOWN_FOLDER_FLAG as long
enum
  KF_FLAG_DEFAULT = &h00000000
  KF_FLAG_NO_APPCONTAINER_REDIRECTION = &h00010000
  KF_FLAG_CREATE = &h00008000
  KF_FLAG_DONT_VERIFY = &h00004000
  KF_FLAG_DONT_UNEXPAND = &h00002000
  KF_FLAG_NO_ALIAS = &h00001000
  KF_FLAG_INIT = &h00000800
  KF_FLAG_DEFAULT_PATH = &h00000400
  KF_FLAG_NOT_PARENT_RELATIVE = &h00000200
  KF_FLAG_SIMPLE_IDLIST = &h00000100
  KF_FLAG_ALIAS_ONLY = &h80000000
end enum