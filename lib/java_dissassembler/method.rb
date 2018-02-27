module Java
  class Method < Annotatable
    attr_reader :flags, :name, :vm_signature

    ACC_PUBLIC       = 0x0001 # Declared public; may be accessed from outside its package.
    ACC_PRIVATE      = 0x0002 # Declared private; accessible only within the defining class.
    ACC_PROTECTED    = 0x0004 # Declared protected; may be accessed within subclasses.
    ACC_STATIC       = 0x0008 # Declared static.
    ACC_FINAL        = 0x0010 # Declared final; must not be overridden (§5.4.5).
    ACC_SYNCHRONIZED = 0x0020 # Declared synchronized; invocation is wrapped by a monitor use.
    ACC_BRIDGE       = 0x0040 # A bridge method, generated by the compiler.
    ACC_VARARGS      = 0x0080 # Declared with variable number of arguments.
    ACC_NATIVE       = 0x0100 # Declared native; implemented in a language other than Java.
    ACC_ABSTRACT     = 0x0400 # Declared abstract; no implementation is provided.
    ACC_STRICT       = 0x0800 # Declared strictfp; floating-point mode is FP-strict.
    ACC_SYNTHETIC    = 0x1000 # Declared synthetic; not present in the source code.

    def initialize(flags, name, vm_signature, annotations)
      super(annotations)
      @flags = flags
      @name = name
      @vm_signature = vm_signature
      #java_signature = vm_signature.scan(/\[?[ZBCSIJFDV]|\[?L[^\;]*;/).map { |m| vm_to_java(m) }
    end

    def is_public?
      (@flags & ACC_PUBLIC) != 0
    end

    def is_private?
      (@flags & ACC_PRIVATE) != 0
    end

    def is_protected?
      (@flags & ACC_PROTECTED) != 0
    end

    def is_static?
      (@flags & ACC_STATIC) != 0
    end

    def is_final?
      (@flags & ACC_FINAL) != 0
    end

    def is_synchronized?
      (@flags & ACC_SYNCHRONIZED) != 0
    end

    def is_bridge?
      (@flags & ACC_BRIDGE) != 0
    end

    def is_varargs?
      (@flags & ACC_VARARGS) != 0
    end

    def is_native?
      (@flags & ACC_NATIVE) != 0
    end

    def is_abstract?
      (@flags & ACC_ABSTRACT) != 0
    end

    def is_strict?
      (@flags & ACC_STRICT) != 0
    end

    def is_synthetic?
      (@flags & ACC_SYNTHETIC) != 0
    end

  #private
  #  def vm_to_java(vm_type)
  #    suffix = vm_type =~ /^\[/ ? "[]" : ""
  #    case vm_type
  #    when "V" then "void"
  #    when "Z" then "boolean"
  #    when "B" then "byte"
  #    when "C" then "char"
  #    when "S" then "short"
  #    when "I" then "int"
  #    when "J" then "long"
  #    when "F" then "float"
  #    when "D" then "double"
  #    else vm_type.gsub(/[L;]/, "").gsub("/", ".")
  #    end + suffix
  #  end
  end
end
