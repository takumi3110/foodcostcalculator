extension StringEx on String {
  bool isValidEmail() {
    return RegExp(
      // ＠の前に数字か文字か+か_か-があり、ドットが2連続しない。＠の後は文字があり、ドットの後に2文字以上の単語がある。
      r'^[a-zA-Z0-9_+-]+(\.[a-zA-Z0-9_+-]+)*@([a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.)+[a-zA-Z]{2,}$'
    ).hasMatch(this);
  }

  bool isValidPassword() {
    return RegExp(
      // 少なくとも1つの大文字か記号が入っている
      r'^(?=.*[A-Z\W]).{6,}$'
    ).hasMatch(this);
  }

}