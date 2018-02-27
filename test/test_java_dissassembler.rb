require 'pp'
require 'minitest/autorun'
require 'java_dissassembler'
require 'java_dissassembler/erb_helper'

class JavaDissassemblerTest < Minitest::Test

  def test_invalid_class_file
    assert_raises do 
      Java::Dissassembler::dissassemble("\xBA\xBE\xCA\xFE")
    end
  end

  def test_dissassemble_constant_pool
    Java::Dissassembler::dissassemble_file("test/fixtures/Test1.class")
    File.open "test/fixtures/Test1.class", "rb" do |file|
      Java::Dissassembler::dissassemble(file.read)
    end
  end

  def test_dissassemble_fields
    klass = Java::Dissassembler::dissassemble_file("test/fixtures/Test1.class")
    field = klass.fields.find { |field| field.name == "FLOAT_PI" }
    
    expected_field = Java::Field.new(Java::Field::ACC_STATIC | Java::Field::ACC_FINAL | Java::Field::ACC_PROTECTED, "FLOAT_PI", "F", [])
    assert_match(/No visible difference/, diff(expected_field, field), diff(expected_field, field))
  end

  def test_dissassemble_annotations
    klass = Java::Dissassembler::dissassemble_file("test/fixtures/Test2.class")
  end

  def test_dissassemble_methods
    klass = Java::Dissassembler::dissassemble_file("test/fixtures/Test2.class")
    method = klass.methods.find { |method| method.name == "foo" }
    
    # Note: @Override annotation is RetentionPolicy.COMPILE, so it doesn't exist in .class file
    expected_method = Java::Method.new(Java::Field::ACC_PUBLIC, "foo", "()V", [])
    assert_match(/No visible difference/, diff(expected_method, method), diff(expected_method, method))

    # Note: @Override annotation is RetentionPolicy.COMPILE, so it doesn't exist in .class file
    method = klass.methods.find { |method| method.name == "main" }
    expected_method = Java::Method.new(Java::Field::ACC_PUBLIC | Java::Field::ACC_STATIC, "main", "([Ljava/lang/String;)V", [{"LMyAnnotation;" => ["value", "FooBar"]}])
    assert_match(/No visible difference/, diff(expected_method, method), diff(expected_method, method))

    assert(method.has_annotation?("LMyAnnotation;"))
  end

  def class_dissassemble_flags
    klass = Java::Dissassembler::dissassemble_file("test/fixtures/Test2.class")
    assert(!klass.is_public?)
  end

  def test_jni_name_mangling
    klass = Java::Dissassembler::dissassemble_file("test/fixtures/Test3.class")
    expected = %w{Java_Test3_foo___3Ljava_lang_String_2I Java_Test3_foo___3Ljava_lang_String_2F Java_Test3_bar_03148_0314a_03145_03186}
    actual = klass.methods.select { |method| method.is_native? }.map do |method|
      method.jni_mangled_name("Test3", true)
    end
    assert_equal(expected, actual)
  end
end
