module Java
  class Class < Annotatable
    attr_reader :flags, :this_klass, :super_klass, :interfaces, :fields, :methods

    ACC_PUBLIC      = 0x0001  # Declared public; may be accessed from outside its package.
    ACC_FINAL       = 0x0010  # Declared final; no subclasses allowed.
    ACC_SUPER       = 0x0020  # Treat superclass methods specially when invoked by the invokespecial instruction.
    ACC_INTERFACE   = 0x0200  # Is an interface, not a class.
    ACC_ABSTRACT    = 0x0400  # Declared abstract; must not be instantiated.
    ACC_SYNTHETIC   = 0x1000  # Declared synthetic; not present in the source code.
    ACC_ANNOTATION  = 0x2000  # Declared as an annotation type.
    ACC_ENUM        = 0x4000  # Declared as an enum type.

    def initialize(major, minor, flags, this_klass, super_klass, interfaces, fields, methods, annotations)
      super(annotations)
      @major = major
      @minor = minor
      @flags = flags
      @this_klass = this_klass
      @super_klass = super_klass
      @interfaces = interfaces
      @fields = fields
      @methods = methods
    end

    def is_public?
      (@flags & ACC_PUBLIC) != 0
    end

    def is_final?
      (@flags & ACC_FINAL) != 0
    end

    def is_super?
      (@flags & ACC_SUPER) != 0
    end

    def is_interface?
      (@flags & ACC_INTERFACE) != 0
    end

    def is_abstract?
      (@flags & ACC_ABSTRACT) != 0
    end

    def is_synthetic?
      (@flags & ACC_SYNTHETIC) != 0
    end

    def is_annotation?
      (@flags & ACC_ANNOTATION) != 0
    end

    def is_enum?
      (@flags & ACC_ENUM) != 0
    end

    def java_version
      case @major
      when 46 then "1.2"
      when 47 then "1.3"
      when 48 then "1.4"
      when 49 then "5"
      when 50 then "6"
      when 51 then "7"
      when 52 then "8"
      when 53 then "9"
      end
    end
  end
end
