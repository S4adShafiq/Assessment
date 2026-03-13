void main() {
  const maxSafeInt = 9007199254740991;
  int i = 0;
  while (true) {
    String name = 'UserDraft$i';
    int hash = _hash(name);
    if (hash.abs() <= maxSafeInt) {
      print('Found safe name: $name with hash $hash');
      break;
    }
    i++;
  }
}

int _hash(String str) {
  int hash = 0xcbf29ce484222325;
  for (var i = 0; i < str.length; i++) {
    hash ^= str.codeUnitAt(i);
    hash *= 0x100000001b3;
  }
  return hash;
}
