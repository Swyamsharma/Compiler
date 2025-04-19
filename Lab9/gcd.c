int main() {
  int a;
  int b;
  int temp;
  a = 9;
  b = 6;

  while (b != 0) {
    temp = b;
    b = a % b;
    a = temp;
  }

  return a;
}
