module Java
  class Method

    # JNI Call Java from C/C++
    # =========================================
    def jni_c_parameters(prefix = "param")
      cparams = Array.new
      java_params.each_with_index do |param, i|
        cparams << "#{java_to_c(param)} #{prefix}#{i}"
      end
      cparams
    end

    def jni_c_return_type
      java_to_c(java_return_type)
    end

    def jni_return_type
      return "" if java_return_type == "void"
      java_to_jni(java_return_type)
    end

    def jni_convert_c_to_jni(prefix = "param")
      conversions = Array.new
      java_params.each_with_index do |param, i|
        case param
        when "java.lang.String"
          conversions << "jstring jni#{prefix}#{i} = env->NewStringUTF(#{prefix}#{i})"
        end
      end
      conversions
    end

    def jni_method_call
      "Call#{is_static? ? "Static" : ""}#{java_return_type.capitalize}Method"
    end

    def jni_method_call_parameters(prefix = "param")
      java_params.enum_for(:each_with_index).map do |param, i|
        case param
        when "java.lang.String" then "jni#{prefix}#{i}"
        else "#{prefix}#{i}"
        end
      end
    end

    # JNI Call C from Java
    # =========================================
    def jni_mangled_name(klass_name, is_override)
      mangled_name = mangle(name)
      mangled_name << "__#{mangle(vm_signature_params)}" if is_override and not vm_signature_params.empty?
      "Java_#{klass_name.gsub(".", "_")}_#{mangled_name}"
    end

    def jni_native_method_parameters(prefix = "param")
      native_method_parameters = ["JNIEnv* env"]
      native_method_parameters << (is_static? ? "jobject caller" : "jclass klass")
      native_method_parameters + java_params.enum_for(:each_with_index).map { |param,i| "#{java_to_jni(param)} #{prefix}#{i}" }
    end

    def jni_convert_jni_to_c(prefix = "param")
      conversions = Array.new
      java_params.each_with_index do |param, i|
        case param
        when "java.lang.String"
          conversions << "const char* c#{prefix}#{i} = env->GetStringUTFChars(#{prefix}#{i}, nullptr /* iscopy */)"
        end
      end
      conversions
    end

    def jni_native_method_converted_parameters(prefix = "param")
      conversions = Array.new
      java_params.each_with_index do |param, i|
        case param
        when "java.lang.String"
          conversions << "c#{prefix}#{i}"
        else
          conversions << "#{prefix}#{i}"
        end
      end
      conversions
    end

    def jni_release_converted_to_c(prefix = "param")
      releases = Array.new
      java_params.each_with_index do |param, i|
        case param
        when "java.lang.String"
          releases << "env->ReleaseStringUTFChars(#{prefix}#{i}, c#{prefix}#{i})"
        end
      end
      releases
    end

    def vm_signature_params
      vm_signature.match(/^\(([^\)]*)\)/)[1]
    end

    def java_params
      java_signature.drop(1)
    end

    def java_return_type
      java_signature.at(0)
    end

    def jni_params
      java_params.map { |java_type| java_to_jni(java_type) }
    end

    def jni_return_value
      java_to_jni(java_return_type)
    end

#private

    def java_signature
      types = vm_signature.scan(/(\[?([ZBCSIJFDV]|L[^;]*;))/).map do |match|
        is_array = match[0].start_with? "["
        val = vm_to_java(match[0])
        if is_array
          val << "[]"
          val[1..-1]
        else
          val
        end
      end
      back = types.pop
      types.unshift(back)
    end

    def vm_to_java(vm_type)
      case vm_type
      when "Z" then "boolean"
      when "B" then "byte"
      when "C" then "char"
      when "S" then "short"
      when "I" then "int"
      when "J" then "long"
      when "F" then "float"
      when "D" then "double"
      when "V" then "void"
      else 
        vm_type.gsub("L", "").gsub(";", "").gsub("/", ".")
      end
    end

    def java_to_c(java_type)
      case java_type
      when "boolean" then "bool"
      when "byte" then "byte"
      when "char" then "char"
      when "short" then "short"
      when "int" then "int"
      when "long" then "long"
      when "float" then "float"
      when "double" then "double"
      when "java.lang.String" then "const char*"
      when "void" then "void"
      else "jobject" end
    end

    def java_to_jni(java_type)
      case java_type
      when "boolean" then "jboolean"
      when "byte" then "jbyte"
      when "char" then "jchar"
      when "short" then "jshort"
      when "int" then "jint"
      when "long" then "jlong"
      when "float" then "jfloat"
      when "double" then "jdouble"
      when "java.lang.String" then "jstring"
      when "void" then raise "Cannot convert `void' to JNI type"
      else "jobject" end
    end

    # See https://docs.oracle.com/javase/7/docs/technotes/guides/jni/spec/design.html Table 2-1)
    def mangle(str)
      mangled_name = str.gsub("_", "_1")
        .gsub(";", "_2")
        .gsub("[", "_3")
        .gsub("/", "_")
      mangled_name.codepoints.map do |codepoint|
        case
        when codepoint <= 0xFF then codepoint.chr
        else "_0#{"%04x" % codepoint}"
        end
      end.join
    end
  end
end
