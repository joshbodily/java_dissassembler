class Test1 {
  // Takes up two entries in Constant Pool Table
  private static final long LONG_FOO = 1000;
  private static final double DOUBLE_PI = 3.14159;

  // Properly convert to IEEE-754 float
  protected static final float FLOAT_PI = 3.14159f;

  // Need to parse "modified" UTF-8
  public static String EMOJI_STRING = "😀";
  private final String OTHER_STRING = "\u0801";
  protected final String NKO_TWO_STRING = "߂";
  public String NULL_UNICODE_BYTE_STRING = "\u0000";
}
